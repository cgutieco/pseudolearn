use crate::ApiError;
use crate::event_codec::{canonical_value, decode_event, serialization_failure, validate_source};
use crate::execution_resource::usage;
use pseudolearn_vm::TraceClass;
use serde_json::{Value, json};

const HEADER_SIZE: usize = 16;
const WIRE_SIGNATURE: &[u8; 4] = b"PLEV";
const WIRE_VERSION: u16 = 1;
const WIRE_RESERVED: u16 = 0;

pub(super) fn encode_binary(events: &[Value]) -> Result<Vec<u8>, ApiError> {
    let mut classes = Vec::with_capacity(events.len());
    let mut lines = Vec::with_capacity(events.len());
    let mut depths = Vec::with_capacity(events.len());
    let mut offsets = Vec::with_capacity(events.len());
    let mut pool = Vec::new();
    for event in events {
        let decoded = decode_event(event)?;
        let fields = event.as_object().ok_or_else(|| usage("invalid event"))?;
        let record = canonical_value(json!({
            "data": fields.get("data").cloned().unwrap_or(Value::Null),
            "source": fields.get("source").cloned().unwrap_or(Value::Null),
        }));
        offsets.push(u32::try_from(pool.len()).map_err(|_| usage("event pool is too large"))?);
        classes.push(decoded.class.to_u8());
        lines.push(decoded.line);
        depths.push(decoded.depth);
        let mut record_bytes = serde_json::to_vec(&record).map_err(serialization_failure)?;
        pool.append(&mut record_bytes);
    }
    let event_count = u64::try_from(events.len()).map_err(|_| usage("too many events"))?;
    let pool_length = u32::try_from(pool.len()).map_err(|_| usage("event pool is too large"))?;
    let mut encoded = Vec::new();
    encoded.extend_from_slice(WIRE_SIGNATURE);
    encoded.extend_from_slice(&WIRE_VERSION.to_le_bytes());
    encoded.extend_from_slice(&WIRE_RESERVED.to_le_bytes());
    encoded.extend_from_slice(&event_count.to_le_bytes());
    encoded.extend_from_slice(&classes);
    append_words(&lines, &mut encoded);
    append_words(&depths, &mut encoded);
    append_words(&offsets, &mut encoded);
    encoded.extend_from_slice(&pool_length.to_le_bytes());
    encoded.extend_from_slice(&pool);
    Ok(encoded)
}

fn append_words(values: &[u32], output: &mut Vec<u8>) {
    for value in values {
        output.extend_from_slice(&value.to_le_bytes());
    }
}

pub(super) fn decode_binary(bytes: &[u8]) -> Result<Vec<Value>, ApiError> {
    validate_header(bytes)?;
    let event_count =
        usize::try_from(read_u64_at(bytes, 8)?).map_err(|_| usage("event count is too large"))?;
    let layout = WireLayout::new(event_count)?;
    let pool_length = usize::try_from(read_u32_at(bytes, layout.pool_length_start)?)
        .map_err(|_| usage("event pool is too large"))?;
    let expected_length = layout
        .pool_start
        .checked_add(pool_length)
        .ok_or_else(|| usage("event pool is too large"))?;
    if bytes.len() != expected_length {
        return Err(usage("event batch length mismatch"));
    }
    let pool_bytes = bytes
        .get(layout.pool_start..)
        .ok_or_else(|| usage("invalid event pool"))?;
    let pool = std::str::from_utf8(pool_bytes).map_err(|_| usage("invalid event pool"))?;
    decode_records(bytes, pool, &layout)
}

struct WireLayout {
    event_count: usize,
    classes_start: usize,
    lines_start: usize,
    depths_start: usize,
    offsets_start: usize,
    pool_length_start: usize,
    pool_start: usize,
}

impl WireLayout {
    fn new(event_count: usize) -> Result<Self, ApiError> {
        let word_bytes = event_count
            .checked_mul(4)
            .ok_or_else(|| usage("event count is too large"))?;
        let classes_start = HEADER_SIZE;
        let lines_start = classes_start
            .checked_add(event_count)
            .ok_or_else(|| usage("event count is too large"))?;
        let depths_start = lines_start
            .checked_add(word_bytes)
            .ok_or_else(|| usage("event count is too large"))?;
        let offsets_start = depths_start
            .checked_add(word_bytes)
            .ok_or_else(|| usage("event count is too large"))?;
        let pool_length_start = offsets_start
            .checked_add(word_bytes)
            .ok_or_else(|| usage("event count is too large"))?;
        let pool_start = pool_length_start
            .checked_add(4)
            .ok_or_else(|| usage("event count is too large"))?;
        Ok(Self {
            event_count,
            classes_start,
            lines_start,
            depths_start,
            offsets_start,
            pool_length_start,
            pool_start,
        })
    }
}

fn validate_header(bytes: &[u8]) -> Result<(), ApiError> {
    if bytes.get(0..4) != Some(WIRE_SIGNATURE.as_slice()) {
        return Err(usage("invalid wire signature"));
    }
    if read_u16_at(bytes, 4)? != WIRE_VERSION {
        return Err(usage("unsupported wire version"));
    }
    if read_u16_at(bytes, 6)? != WIRE_RESERVED {
        return Err(usage("invalid reserved header"));
    }
    Ok(())
}

fn decode_records(bytes: &[u8], pool: &str, layout: &WireLayout) -> Result<Vec<Value>, ApiError> {
    let mut events = Vec::with_capacity(layout.event_count);
    for index in 0..layout.event_count {
        let class_offset = layout
            .classes_start
            .checked_add(index)
            .ok_or_else(|| usage("event count is too large"))?;
        let class_byte = *bytes
            .get(class_offset)
            .ok_or_else(|| usage("truncated event classes"))?;
        let class = TraceClass::from_u8(class_byte).ok_or_else(|| usage("invalid event class"))?;
        let line = read_word_column(bytes, layout.lines_start, index)?;
        let depth = read_word_column(bytes, layout.depths_start, index)?;
        let record = read_pool_record(bytes, pool, layout, index)?;
        events.push(event_from_record(class, line, depth, record)?);
    }
    Ok(events)
}

fn read_pool_record(
    bytes: &[u8],
    pool: &str,
    layout: &WireLayout,
    index: usize,
) -> Result<Value, ApiError> {
    let offset = usize::try_from(read_word_column(bytes, layout.offsets_start, index)?)
        .map_err(|_| usage("invalid event offset"))?;
    let next_index = index
        .checked_add(1)
        .ok_or_else(|| usage("event count is too large"))?;
    let end = if next_index < layout.event_count {
        usize::try_from(read_word_column(bytes, layout.offsets_start, next_index)?)
            .map_err(|_| usage("invalid event offset"))?
    } else {
        pool.len()
    };
    if (index == 0 && offset != 0) || offset >= end {
        return Err(usage("invalid event offsets"));
    }
    let record = pool
        .get(offset..end)
        .ok_or_else(|| usage("invalid event pool boundary"))?;
    serde_json::from_str(record).map_err(|error| usage(&error.to_string()))
}

fn event_from_record(
    class: TraceClass,
    line: u32,
    depth: u32,
    record: Value,
) -> Result<Value, ApiError> {
    let fields = record
        .as_object()
        .ok_or_else(|| usage("invalid event record"))?;
    let event_payload = fields
        .get("data")
        .cloned()
        .ok_or_else(|| usage("missing event data"))?;
    let source = fields
        .get("source")
        .cloned()
        .ok_or_else(|| usage("missing event source"))?;
    let mut event = json!({"class":class.as_str(),"line":line,"depth":depth});
    if let Some(event_fields) = event.as_object_mut() {
        if !event_payload.is_null() {
            event_fields.insert("data".to_owned(), event_payload);
        }
        event_fields.insert("source".to_owned(), source);
    }
    decode_event(&event)?;
    validate_source(&event)?;
    Ok(event)
}

fn read_word_column(bytes: &[u8], start: usize, index: usize) -> Result<u32, ApiError> {
    let offset = index
        .checked_mul(4)
        .and_then(|position| start.checked_add(position))
        .ok_or_else(|| usage("event count is too large"))?;
    read_u32_at(bytes, offset)
}

fn read_u16_at(bytes: &[u8], offset: usize) -> Result<u16, ApiError> {
    let end = offset
        .checked_add(2)
        .ok_or_else(|| usage("invalid event header"))?;
    let slice = bytes
        .get(offset..end)
        .ok_or_else(|| usage("truncated event header"))?;
    let array: [u8; 2] = slice
        .try_into()
        .map_err(|_| usage("invalid event header"))?;
    Ok(u16::from_le_bytes(array))
}

fn read_u32_at(bytes: &[u8], offset: usize) -> Result<u32, ApiError> {
    let end = offset
        .checked_add(4)
        .ok_or_else(|| usage("invalid event column"))?;
    let slice = bytes
        .get(offset..end)
        .ok_or_else(|| usage("truncated event column"))?;
    let array: [u8; 4] = slice
        .try_into()
        .map_err(|_| usage("invalid event column"))?;
    Ok(u32::from_le_bytes(array))
}

fn read_u64_at(bytes: &[u8], offset: usize) -> Result<u64, ApiError> {
    let end = offset
        .checked_add(8)
        .ok_or_else(|| usage("invalid event header"))?;
    let slice = bytes
        .get(offset..end)
        .ok_or_else(|| usage("truncated event header"))?;
    let array: [u8; 8] = slice
        .try_into()
        .map_err(|_| usage("invalid event header"))?;
    Ok(u64::from_le_bytes(array))
}
