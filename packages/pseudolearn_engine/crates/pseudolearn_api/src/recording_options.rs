use crate::ApiError;
use crate::ExecuteRequest;
use crate::execution_resource::usage;
use serde_json::Value;

const SUPPORTED: [&str; 7] = [
    "batch_size",
    "retention_events",
    "query_all_events",
    "seek_every_event",
    "host_tape",
    "input_batch_sizes",
    "capture_states",
];

pub(crate) fn validate(options: Option<&Value>) -> Result<(), ApiError> {
    let unsupported = options
        .and_then(Value::as_object)
        .is_some_and(|fields| fields.keys().any(|key| !SUPPORTED.contains(&key.as_str())));
    if unsupported {
        return Err(usage("unsupported recording option"));
    }
    Ok(())
}

pub(crate) fn capture_states(options: Option<&Value>) -> bool {
    options
        .and_then(|fields| fields.get("capture_states"))
        .and_then(Value::as_bool)
        .unwrap_or(true)
}

pub(crate) fn seek_every_event(options: Option<&Value>) -> bool {
    options
        .and_then(|fields| fields.get("seek_every_event"))
        .and_then(Value::as_bool)
        .unwrap_or(false)
}

pub(crate) fn apply(
    request: &mut ExecuteRequest,
    options: Option<&Value>,
) -> Result<Vec<String>, ApiError> {
    if let Some(tape) = options.and_then(|fields| fields.get("host_tape")) {
        request.seed = tape
            .get("seed")
            .and_then(Value::as_i64)
            .ok_or_else(|| usage("invalid host tape seed"))?;
        request.inputs = serde_json::from_value(tape.get("inputs").cloned().unwrap_or_default())
            .map_err(|error| usage(&error.to_string()))?;
    }
    let Some(sizes) = options.and_then(|fields| fields.get("input_batch_sizes")) else {
        return Ok(Vec::new());
    };
    let first = sizes
        .get(0)
        .and_then(Value::as_u64)
        .and_then(|count| usize::try_from(count).ok())
        .ok_or_else(|| usage("invalid input batch sizes"))?;
    let first = first.min(request.inputs.len());
    Ok(request.inputs.split_off(first))
}
