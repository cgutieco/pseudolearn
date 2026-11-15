use serde_json::{Value, json};

pub(crate) fn response(request: &Value, outcome: Result<Value, String>) -> Value {
    let mut message = json!({
        "type":"response", "request_seq":request.get("seq"),
        "command":request.get("command"), "success":outcome.is_ok()
    });
    match outcome {
        Ok(body) => message["body"] = body,
        Err(detail) => message["message"] = json!(detail),
    }
    message
}

pub(crate) fn event(name: &str, body: Value) -> Value {
    let mut message = json!({"type":"event","event":name});
    message["body"] = body;
    message
}

pub(crate) fn argument<'argument>(request: &'argument Value, name: &str) -> &'argument Value {
    request
        .get("arguments")
        .and_then(|value| value.get(name))
        .unwrap_or(&Value::Null)
}

pub(crate) fn capabilities() -> Value {
    json!({
        "supportsConfigurationDoneRequest":true,
        "supportsTerminateRequest":true,
        "supportsEvaluateForHovers":true,
        "supportsStepBack":true,
        "supportsDelayedStackTraceLoading":true,
        "supportsValueFormattingOptions":false,
        "supportsSingleThreadExecutionRequests":false,
        "supportsLoadedSourcesRequest":true
    })
}

pub(crate) fn natural(value: &Value, fallback: u64) -> u64 {
    value.as_u64().unwrap_or(fallback)
}
