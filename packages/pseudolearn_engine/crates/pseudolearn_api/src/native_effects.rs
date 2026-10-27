use crate::{ApiError, ExecuteRequest, ExecuteResponse};
use pseudolearn_runtime::ExecutionMode;
use serde_json::{Value, json};

pub fn native_effect_input(request: &ExecuteRequest) -> Result<Vec<u8>, ApiError> {
    let mode = crate::tape_wire::parse_execution_mode(request.execution_mode.as_deref())?;
    if matches!(mode, ExecutionMode::HistorySeek) {
        return Err(crate::execution_resource::usage(
            "history_seek is not supported by the native subject",
        ));
    }
    crate::tape_wire::validate_replay_tape(request, mode)?;
    let tape = match mode {
        ExecutionMode::ReplayFromTape => request
            .effect_tape
            .as_ref()
            .map(crate::tape_wire::tape_from_value)
            .transpose()?
            .map(|tape| crate::tape_wire::tape_to_value(&tape)),
        _ => None,
    };
    let maximum = request
        .host
        .as_ref()
        .and_then(|host| host.get("max_tape_bytes"))
        .cloned();
    let document = json!({
        "host": request.host,
        "identity": crate::tape_wire::build_identity(request),
        "max_tape_bytes": maximum,
        "tape": tape,
    });
    serde_json::to_vec(&document).map_err(|error| ApiError::InternalFault(error.to_string()))
}

pub fn apply_native_effect_output(response: &mut ExecuteResponse, bytes: &[u8]) {
    let Ok(document) = serde_json::from_slice::<Value>(bytes) else {
        return;
    };
    response.effect_tape = document.get("tape").cloned();
    response.host_observation = Some(json!({
        "calls": document.get("host_calls").cloned().unwrap_or(Value::Null),
        "open_resources": 0,
    }));
    if let Some(code) = document.get("replay_error").and_then(Value::as_str) {
        response.termination = json!({"kind":"failed","code":code});
    }
}
