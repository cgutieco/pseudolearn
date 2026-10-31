use crate::ApiError;
use crate::execution_resource::usage;
use crate::execution_state::value;
use crate::typed_values::typed_frame;
use pseudolearn_runtime as runtime;
use pseudolearn_timeline::{ArraySliceRange, capture_array_slice, capture_frame_window};
use pseudolearn_vm::Machine;
use serde_json::{Value, json};

const MAXIMUM_PAGE_SIZE: usize = 4096;

pub(crate) struct PageRequest {
    pub(crate) query: String,
    pub(crate) target: u64,
    pub(crate) event: usize,
    pub(crate) page_size: usize,
    pub(crate) cursor: Option<String>,
    pub(crate) offset: usize,
    pub(crate) task_id: Option<u64>,
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
        if arguments.get("cursor").is_some_and(Value::is_string)
            && arguments.get("offset").is_some()
        {
            return Err(usage("cursor and offset are mutually exclusive"));
        }
        Ok(Self {
            offset: page_offset(arguments)?,
            task_id: arguments
                .get("task_id")
                .map(|value| value.as_u64().ok_or_else(|| usage("invalid task identity")))
                .transpose()?,
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

fn page_offset(arguments: &Value) -> Result<usize, ApiError> {
    arguments
        .get("offset")
        .map(|value| {
            value
                .as_u64()
                .and_then(|number| usize::try_from(number).ok())
                .ok_or_else(|| usage("invalid page offset"))
        })
        .transpose()
        .map(|offset| offset.unwrap_or(0))
}

pub(crate) fn page(
    machine: &Machine<'_>,
    request: &PageRequest,
    scope: &str,
) -> Result<Value, ApiError> {
    let binding = binding_hash(scope, request);
    let offset = match &request.cursor {
        Some(cursor) => offset_of(cursor, binding)?,
        None => request.offset,
    };
    let (elements, total) = elements(machine, request, offset)?;
    if offset > total {
        return Err(usage("invalid page offset"));
    }
    let end = offset.saturating_add(elements.len());
    let truncated = end < total;
    let next_cursor = truncated.then(|| format!("{binding:016x}.{end:x}"));
    let mut response = json!({"elements":elements,"truncated":truncated,"next_cursor":next_cursor,"total":total,"values_read":elements.len()});
    if let (true, Some(fields)) = (request.query == "array_cells", response.as_object_mut()) {
        fields.insert(
            "dimensions".to_owned(),
            json!(array_dimensions(machine, request.target)?),
        );
    }
    if let Some(fields) = response.as_object_mut() {
        fields.insert("indexed".to_owned(), json!(indexed(machine, request)));
    }
    Ok(response)
}

fn indexed(machine: &Machine<'_>, request: &PageRequest) -> bool {
    if request.query == "array_cells" {
        return true;
    }
    if request.query != "object_fields" {
        return false;
    }
    runtime::allocation_handle(machine.heap(), request.target).is_some_and(|handle| {
        runtime::is_array_allocation(machine.heap(), handle)
            || runtime::is_collection_allocation(machine.heap(), handle)
                && runtime::collection_is_dictionary(machine.heap(), handle) == Ok(false)
    })
}

fn elements(
    machine: &Machine<'_>,
    request: &PageRequest,
    offset: usize,
) -> Result<(Vec<Value>, usize), ApiError> {
    match request.query.as_str() {
        "array_cells" => array_cells(machine, request, offset),
        "frame_variables" => {
            let (view, total) =
                capture_frame_window(machine, target_index(request)?, (offset, request.page_size))
                    .map_err(|error| usage(&error.to_string()))?;
            let variables = typed_frame(&view);
            let elements = variables
                .get("variables")
                .and_then(Value::as_object)
                .map(|variables| {
                    variables
                        .iter()
                        .map(|(name, value)| json!({"name":name,"value":value}))
                        .collect()
                })
                .unwrap_or_default();
            Ok((elements, total))
        }
        "object_fields" => {
            crate::state_object_pages::page(machine, request.target, (offset, request.page_size))
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

fn binding_hash(scope: &str, request: &PageRequest) -> u64 {
    let text = format!(
        "{scope}|{}|{}|{}|{}|{:?}",
        request.query, request.target, request.event, request.page_size, request.task_id
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
