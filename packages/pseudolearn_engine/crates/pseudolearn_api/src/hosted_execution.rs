use crate::execution_resource::ExecutionResource;
use crate::{ApiDiagnostic, ApiError, ExecuteRequest, ExecuteResponse};
use pseudolearn_vm::LoadedProgram;
use serde_json::{Value, json};

pub(crate) fn execute(
    program: &LoadedProgram,
    warnings: &[ApiDiagnostic],
    request: &ExecuteRequest,
) -> ExecuteResponse {
    match run(program, warnings, request) {
        Ok(response) => response,
        Err(error) => ExecuteResponse {
            kind: "execute".to_owned(),
            output: String::new(),
            termination: json!({"kind":"failed","code":failure_code(&error)}),
            diagnostics: Vec::new(),
            events: Vec::new(),
            inputs_consumed: 0,
            state_at: None,
            effect_tape: None,
            pending_effect: None,
            host_observation: Some(json!({"calls":0,"open_resources":0})),
        },
    }
}

fn run(
    program: &LoadedProgram,
    warnings: &[ApiDiagnostic],
    request: &ExecuteRequest,
) -> Result<ExecuteResponse, ApiError> {
    let mut execution =
        ExecutionResource::from_loaded(request, program.clone(), warnings.to_vec())?;
    let mut events = Vec::new();
    loop {
        let mut response = execution.advance(4096)?;
        if request.observe == "events" {
            events.extend(response_events(&response));
        }
        if is_running(&response) {
            continue;
        }
        let state = request
            .state_at
            .map(|event| execution.state(event))
            .transpose()?;
        finish_response(&mut response, events, state)?;
        return serde_json::from_value(response)
            .map_err(|error| ApiError::InternalFault(error.to_string()));
    }
}

fn response_events(response: &Value) -> Vec<Value> {
    response
        .get("events")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .cloned()
        .collect()
}

fn is_running(response: &Value) -> bool {
    response
        .pointer("/termination/kind")
        .and_then(Value::as_str)
        == Some("running")
}

fn finish_response(
    response: &mut Value,
    events: Vec<Value>,
    state: Option<Value>,
) -> Result<(), ApiError> {
    let fields = response
        .as_object_mut()
        .ok_or_else(|| crate::execution_prepare::usage("invalid execution response"))?;
    fields.insert("kind".to_owned(), json!("execute"));
    fields.insert("events".to_owned(), json!(events));
    if let Some(state) = state {
        fields.insert("state_at".to_owned(), state);
    }
    Ok(())
}

fn failure_code(error: &ApiError) -> &str {
    match error {
        ApiError::InvalidProtocol(code) => code,
        _ => "internalFault",
    }
}
