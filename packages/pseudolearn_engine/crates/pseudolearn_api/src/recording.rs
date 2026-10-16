use crate::execution_resource::usage;
use crate::{ApiError, ApiSession, ExecuteRequest};
use serde_json::{Value, json};

struct Recording {
    events: Vec<Value>,
    states: Vec<Value>,
    deltas: Vec<Value>,
    initial: Value,
    previous: Value,
    historical: Vec<Value>,
}

pub(crate) fn record(session: &mut ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    if arguments
        .get("options")
        .and_then(Value::as_object)
        .is_some_and(|options| {
            options.keys().any(|key| {
                !["batch_size", "retention_events", "query_all_events"].contains(&key.as_str())
            })
        })
    {
        return Err(usage("unsupported recording option"));
    }
    let request = arguments
        .get("request")
        .ok_or_else(|| usage("missing request"))?;
    let request: ExecuteRequest =
        serde_json::from_value(request.clone()).map_err(|error| usage(&error.to_string()))?;
    let analysis = value(session.call("create_analysis", &json!(request)))?;
    let resource = start(session, &analysis, &request)?;
    let outcome = record_execution(session, &resource, arguments, &request);
    let parent = analysis
        .get("document")
        .or_else(|| analysis.get("resource"))
        .cloned()
        .unwrap_or(Value::Null);
    value(session.call("release", &json!({"resource":parent})))?;
    outcome
}

fn start(
    session: &mut ApiSession,
    analysis: &Value,
    request: &ExecuteRequest,
) -> Result<Value, ApiError> {
    let mut arguments = serde_json::to_value(request).map_err(|error| usage(&error.to_string()))?;
    if let Some(fields) = arguments.as_object_mut() {
        fields.insert(
            "analysis".to_owned(),
            analysis.get("resource").cloned().unwrap_or(Value::Null),
        );
    }
    let execution = value(session.call("start", &arguments))?;
    execution
        .get("resource")
        .cloned()
        .ok_or_else(|| usage("missing execution resource"))
}

fn record_execution(
    session: &mut ApiSession,
    resource: &Value,
    arguments: &Value,
    request: &ExecuteRequest,
) -> Result<Value, ApiError> {
    let initial = value(session.call("initial_state", &json!({"resource":resource})))?;
    let mut recording = Recording {
        events: Vec::new(),
        states: Vec::new(),
        deltas: Vec::new(),
        previous: initial.clone(),
        initial,
        historical: Vec::new(),
    };
    let batch_size = arguments
        .pointer("/options/batch_size")
        .and_then(Value::as_u64)
        .unwrap_or(1);
    let terminal = loop {
        let batch = value(session.call(
            "advance",
            &json!({"resource":resource,"batch_size":batch_size}),
        ))?;
        append(session, resource, &batch, &mut recording)?;
        if batch.pointer("/termination/kind").and_then(Value::as_str) != Some("running") {
            break batch;
        }
    };
    result(
        session,
        resource,
        (arguments, request),
        (terminal, recording),
    )
}

fn append(
    session: &mut ApiSession,
    resource: &Value,
    batch: &Value,
    recording: &mut Recording,
) -> Result<(), ApiError> {
    for event in batch
        .get("events")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing events"))?
    {
        let index = recording.events.len();
        let state =
            value(session.call("query_state", &json!({"resource":resource,"event":index})))?;
        recording.deltas.push(json!(crate::state_changes::between(
            &recording.previous,
            &state
        )));
        recording.previous = state.clone();
        recording.events.push(event.clone());
        recording.states.push(state);
        let historical = value(session.call("seek", &json!({"resource":resource,"event":index})))?;
        recording.historical.push(historical);
    }
    Ok(())
}

fn result(
    session: &mut ApiSession,
    resource: &Value,
    configuration: (&Value, &ExecuteRequest),
    outcome: (Value, Recording),
) -> Result<Value, ApiError> {
    let (arguments, request) = configuration;
    let (mut terminal, recording) = outcome;
    if let Some(retention) = arguments.pointer("/options/retention_events") {
        value(session.call(
            "set_retention",
            &json!({"resource":resource,"events":retention}),
        ))?;
    }
    let horizon = value(session.call("horizon", &json!({"resource":resource})))?;
    let queries: Vec<_> = (0..recording.states.len())
        .map(|event| session.call("query_state", &json!({"resource":resource,"event":event})))
        .collect();
    if let Some(fields) = terminal.as_object_mut() {
        fields.insert("events".to_owned(), json!(recording.events));
        fields.insert("states".to_owned(), json!(recording.states));
        fields.insert("retained_views".to_owned(), json!(recording.states));
        fields.insert("historical_states".to_owned(), json!(recording.historical));
        fields.insert("deltas".to_owned(), json!(recording.deltas));
        fields.insert("initial_state".to_owned(), recording.initial);
        fields.insert("horizon".to_owned(), horizon);
        fields.insert("queries".to_owned(), json!(queries));
        fields.insert(
            "host_tape".to_owned(),
            json!({"seed":request.seed,"inputs":request.inputs}),
        );
    }
    Ok(terminal)
}

fn value(response: Value) -> Result<Value, ApiError> {
    response
        .get("value")
        .cloned()
        .ok_or_else(|| usage(&response.to_string()))
}
