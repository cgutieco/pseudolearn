#![forbid(unsafe_code)]

use super::payload::parse_payload;
use crate::events::{EventPayload, TraceClass, TraceEvent};

const WIRE_SIGNATURE: &[u8; 4] = b"PLEV";
const WIRE_VERSION: u16 = 1;
const WIRE_RESERVED: u16 = 0;
const HEADER_SIZE: usize = 16;

pub fn decode_plev(bytes: &[u8]) -> Result<Vec<TraceEvent>, &'static str> {
    if bytes.len() < HEADER_SIZE {
        return Err("Payload shorter than header size");
    }
    validate_header(bytes)?;
    let count_slice = bytes.get(8..16).ok_or("Header event count slice invalid")?;
    let count_u64 = u64::from_le_bytes(
        count_slice
            .try_into()
            .map_err(|_| "Header event count slice invalid")?,
    );
    let count = usize::try_from(count_u64).map_err(|_| "Event count overflow")?;
    let layout = calculate_layout(count);
    if bytes.len() < layout.pool_header_end {
        return Err("Payload shorter than columns and pool header");
    }
    let pool_length_u32 = read_u32_at(bytes, layout.pool_header_start)?;
    let pool_length = usize::try_from(pool_length_u32).map_err(|_| "Pool length overflow")?;
    let expected_length = layout.pool_header_end.saturating_add(pool_length);
    if bytes.len() != expected_length {
        return Err("Payload length mismatch with pool length");
    }
    let pool_bytes = bytes
        .get(layout.pool_header_end..)
        .ok_or("Pool out of bounds")?;
    let pool_string = std::str::from_utf8(pool_bytes).map_err(|_| "Pool is not valid UTF-8")?;
    decode_events(bytes, &layout, pool_string, count)
}

struct WireLayout {
    col_class_start: usize,
    col_line_start: usize,
    col_depth_start: usize,
    col_offset_start: usize,
    pool_header_start: usize,
    pool_header_end: usize,
}

fn calculate_layout(count: usize) -> WireLayout {
    let col_class_start = HEADER_SIZE;
    let col_line_start = col_class_start.saturating_add(count);
    let col_depth_start = col_line_start.saturating_add(count.saturating_mul(4));
    let col_offset_start = col_depth_start.saturating_add(count.saturating_mul(4));
    let pool_header_start = col_offset_start.saturating_add(count.saturating_mul(4));
    let pool_header_end = pool_header_start.saturating_add(4);
    WireLayout {
        col_class_start,
        col_line_start,
        col_depth_start,
        col_offset_start,
        pool_header_start,
        pool_header_end,
    }
}

fn validate_header(bytes: &[u8]) -> Result<(), &'static str> {
    let signature = bytes.get(0..4).ok_or("Header too short for signature")?;
    if signature != WIRE_SIGNATURE {
        return Err("Invalid wire signature");
    }
    let version_bytes = bytes.get(4..6).ok_or("Header too short for version")?;
    let version = u16::from_le_bytes(version_bytes.try_into().map_err(|_| "Invalid version")?);
    if version != WIRE_VERSION {
        return Err("Unsupported wire version");
    }
    let reserved_bytes = bytes.get(6..8).ok_or("Header too short for reserved")?;
    let reserved = u16::from_le_bytes(reserved_bytes.try_into().map_err(|_| "Invalid reserved")?);
    if reserved != WIRE_RESERVED {
        return Err("Nonzero reserved header field");
    }
    Ok(())
}

fn read_u32_at(bytes: &[u8], offset: usize) -> Result<u32, &'static str> {
    let end = offset.saturating_add(4);
    let slice = bytes.get(offset..end).ok_or("Failed reading u32")?;
    slice
        .try_into()
        .map(u32::from_le_bytes)
        .map_err(|_| "Failed reading u32")
}

fn decode_events(
    bytes: &[u8],
    layout: &WireLayout,
    pool_string: &str,
    count: usize,
) -> Result<Vec<TraceEvent>, &'static str> {
    let (classes, offsets) = read_columns(bytes, layout, count)?;
    let mut events = Vec::with_capacity(count);

    for index in 0..count {
        let class = *classes.get(index).ok_or("Class index out of bounds")?;
        let line_offset = layout
            .col_line_start
            .saturating_add(index.saturating_mul(4));
        let line = read_u32_at(bytes, line_offset)?;
        let depth_offset = layout
            .col_depth_start
            .saturating_add(index.saturating_mul(4));
        let depth = read_u32_at(bytes, depth_offset)?;
        let payload = decode_event_payload(&classes, &offsets, index, pool_string)?;
        events.push(TraceEvent {
            class,
            line,
            depth,
            span: None,
            payload,
        });
    }

    Ok(events)
}

fn read_columns(
    bytes: &[u8],
    layout: &WireLayout,
    count: usize,
) -> Result<(Vec<TraceClass>, Vec<usize>), &'static str> {
    let mut classes = Vec::with_capacity(count);
    let mut offsets = Vec::with_capacity(count);
    for index in 0..count {
        let class_offset = layout.col_class_start.saturating_add(index);
        let class_byte = *bytes.get(class_offset).ok_or("Class byte out of bounds")?;
        let class = TraceClass::from_u8(class_byte).ok_or("Invalid trace class byte")?;
        let offset_index = layout
            .col_offset_start
            .saturating_add(index.saturating_mul(4));
        let offset_u32 = read_u32_at(bytes, offset_index)?;
        let offset = usize::try_from(offset_u32).map_err(|_| "Offset overflow")?;
        classes.push(class);
        offsets.push(offset);
    }
    Ok((classes, offsets))
}

fn decode_event_payload(
    classes: &[TraceClass],
    offsets: &[usize],
    index: usize,
    pool_string: &str,
) -> Result<Option<EventPayload>, &'static str> {
    let class = *classes.get(index).ok_or("Class index out of bounds")?;
    if !class_requires_payload(class) {
        return Ok(None);
    }
    let start = *offsets.get(index).ok_or("Offset index out of bounds")?;
    let end = find_next_payload_offset(classes, offsets, index, pool_string.len());
    if start > end || end > pool_string.len() {
        return Err("Payload offset out of pool bounds");
    }
    let slice = pool_string
        .get(start..end)
        .ok_or("Payload offset out of pool bounds")?;
    let payload = parse_payload(class, slice)?;
    Ok(Some(payload))
}

fn class_requires_payload(class: TraceClass) -> bool {
    !matches!(
        class,
        TraceClass::StatementEntered | TraceClass::StatementExited | TraceClass::InputRequested
    )
}

fn find_next_payload_offset(
    classes: &[TraceClass],
    offsets: &[usize],
    current: usize,
    pool_total_length: usize,
) -> usize {
    let start = current.saturating_add(1);
    for next_index in start..classes.len() {
        if let Some(&cls) = classes.get(next_index)
            && class_requires_payload(cls)
            && let Some(&offset) = offsets.get(next_index)
        {
            return offset;
        }
    }
    pool_total_length
}
