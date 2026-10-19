use crate::ApiError;
use crate::execution_resource::usage;
use crate::execution_state::{query_object, value};
use crate::typed_values::typed_frame;
use pseudolearn_runtime as runtime;
use pseudolearn_timeline::{ArraySliceRange, capture_array_slice, capture_frame};
use pseudolearn_vm::Machine;
use serde_json::{Value, json};

const MAXIMUM_PAGE_SIZE: usize = 4096;

pub(crate) struct PageRequest {
    pub(crate) query: String,
    pub(crate) target: u64,
    pub(crate) event: usize,
    pub(crate) page_size: usize,
    pub(crate) cursor: Option<String>,
}

impl PageRequest {
    pub(crate) fn parse(arguments: &Value) -> Result<Self, ApiError> {
        let number = |name: &str| {
            arguments
                .get(name)
                .and_then(Value::as_u64)
                .ok_or_else(|| usage("missing page field"))
        };
        let page_size =
            usize::try_from(number("page_size")?).map_err(|_| usage("invalid page size"))?;
        if page_size == 0 || page_size > MAXIMUM_PAGE_SIZE {
            return Err(usage("invalid page size"));
        }
        Ok(Self {
            query: arguments
                .get("query")
                .and_then(Value::as_str)
                .ok_or_else(|| usage("missing page query"))?
                .to_owned(),
            target: arguments.get("target").and_then(Value::as_u64).unwrap_or(0),
            event: usize::try_from(number("event")?).map_err(|_| usage("invalid event"))?,
            page_size,
            cursor: arguments
                .get("cursor")
                .and_then(Value::as_str)
                .map(str::to_owned),
        })
    }
}

pub(crate) fn page(
    machine: &Machine<'_>,
    request: &PageRequest,
    scope: &str,
) -> Result<Value, ApiError> {
    let binding = binding_hash(scope, request);
    let offset = match &request.cursor {
        Some(cursor) => offset_of(cursor, binding)?,
        None => 0,
    };
    let (elements, total) = elements(machine, request, offset)?;
    let end = offset.saturating_add(elements.len());
    let truncated = end < total;
    let next_cursor = truncated.then(|| format!("{binding:016x}.{end:x}"));
    let mut response =
        json!({"elements":elements,"truncated":truncated,"next_cursor":next_cursor,"total":total});
    if let (true, Some(fields)) = (request.query == "array_cells", response.as_object_mut()) {
        fields.insert(
            "dimensions".to_owned(),
            json!(array_dimensions(machine, request.target)?),
        );
    }
    Ok(response)
}

fn elements(
    machine: &Machine<'_>,
    request: &PageRequest,
    offset: usize,
) -> Result<(Vec<Value>, usize), ApiError> {
    match request.query.as_str() {
        "array_cells" => array_cells(machine, request, offset),
        "frame_variables" => {
            let view = capture_frame(machine, target_index(request)?)
                .map_err(|error| usage(&error.to_string()))?;
            let variables = typed_frame(&view)
                .get("variables")
                .cloned()
                .unwrap_or(Value::Null);
            Ok(window(entries(&variables), offset, request.page_size))
        }
        "object_fields" => {
            let object = query_object(machine, request.target)?;
            let fields = object.get("campos").cloned().unwrap_or(Value::Null);
            Ok(window(entries(&fields), offset, request.page_size))
        }
        _ => Err(usage("unknown page query")),
    }
}

fn array_cells(
    machine: &Machine<'_>,
    request: &PageRequest,
    offset: usize,
) -> Result<(Vec<Value>, usize), ApiError> {
    let total = array_cell_count(machine, request.target)?;
    let length = request.page_size.min(total.saturating_sub(offset));
    let cells = capture_array_slice(
        machine,
        request.target,
        ArraySliceRange {
            start_index: offset,
            slice_length: length,
        },
    )
    .map_err(|error| usage(&error.to_string()))?;
    Ok((cells.iter().map(value).collect(), total))
}

fn array_dimensions(machine: &Machine<'_>, ordinal: u64) -> Result<Vec<u64>, ApiError> {
    let heap = machine.heap();
    let handle = runtime::live_allocation_handles(heap)
        .into_iter()
        .find(|handle| runtime::allocation_ordinal(heap, *handle) == Ok(ordinal))
        .filter(|handle| runtime::is_array_allocation(heap, *handle))
        .ok_or_else(|| usage("invalid array reference"))?;
    runtime::array_dimensions(heap, handle)
        .map(<[u64]>::to_vec)
        .map_err(|_| usage("invalid array reference"))
}

fn array_cell_count(machine: &Machine<'_>, ordinal: u64) -> Result<usize, ApiError> {
    let heap = machine.heap();
    let handle = runtime::live_allocation_handles(heap)
        .into_iter()
        .find(|handle| runtime::allocation_ordinal(heap, *handle) == Ok(ordinal))
        .filter(|handle| runtime::is_array_allocation(heap, *handle))
        .ok_or_else(|| usage("invalid array reference"))?;
    let dimensions =
        runtime::array_dimensions(heap, handle).map_err(|_| usage("invalid array reference"))?;
    dimensions
        .iter()
        .try_fold(1_usize, |total, dimension| {
            total.checked_mul(usize::try_from(*dimension).ok()?)
        })
        .ok_or_else(|| usage("array too large"))
}

fn target_index(request: &PageRequest) -> Result<usize, ApiError> {
    usize::try_from(request.target).map_err(|_| usage("invalid frame"))
}

fn entries(map: &Value) -> Vec<Value> {
    map.as_object()
        .map(|fields| {
            fields
                .iter()
                .map(|(name, content)| json!({"name":name,"value":content}))
                .collect()
        })
        .unwrap_or_default()
}

fn window(all: Vec<Value>, offset: usize, page_size: usize) -> (Vec<Value>, usize) {
    let total = all.len();
    (
        all.into_iter().skip(offset).take(page_size).collect(),
        total,
    )
}

fn binding_hash(scope: &str, request: &PageRequest) -> u64 {
    let text = format!(
        "{scope}|{}|{}|{}|{}",
        request.query, request.target, request.event, request.page_size
    );
    text.bytes().fold(0xcbf2_9ce4_8422_2325_u64, |hash, byte| {
        (hash ^ u64::from(byte)).wrapping_mul(0x0100_0000_01b3)
    })
}

fn offset_of(cursor: &str, binding: u64) -> Result<usize, ApiError> {
    let (hash, offset) = cursor
        .split_once('.')
        .ok_or_else(|| usage("invalid cursor"))?;
    if u64::from_str_radix(hash, 16).ok() != Some(binding) {
        return Err(usage("cursor does not match this query"));
    }
    usize::from_str_radix(offset, 16).map_err(|_| usage("invalid cursor"))
}
