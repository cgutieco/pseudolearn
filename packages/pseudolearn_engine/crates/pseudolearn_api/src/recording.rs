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
    capture: bool,
    count: usize,
    digest: Option<crate::recording_digest::EventDigest>,
}

pub(crate) fn record(session: &mut ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    let options = arguments.get("options");
    crate::recording_options::validate(options)?;
    let request = arguments
        .get("request")
        .ok_or_else(|| usage("missing request"))?;
    let mut request: ExecuteRequest =
        serde_json::from_value(request.clone()).map_err(|error| usage(&error.to_string()))?;
    let pending = crate::recording_options::apply(&mut request, options)?;
    let analysis = value(session.call("create_analysis", &json!(request)))?;
    let resource = start(session, &analysis, &request)?;
    let outcome = record_execution(session, &resource, arguments, (&request, pending));
    let parent = analysis
        .get("document")
        .or_else(|| analysis.get("resource"))
        .cloned()
        .unwrap_or(Value::Null);
    value(session.call("release", &json!({"resource":parent})))?;
    outcome
}

pub(crate) fn start(
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
    plan: (&ExecuteRequest, Vec<String>),
) -> Result<Value, ApiError> {
    let (request, pending) = plan;
    let capture = crate::recording_options::capture_states(arguments.get("options"));
    let initial = if capture {
        value(session.call("initial_state", &json!({"resource":resource})))?
    } else {
        Value::Null
    };
    let mut recording = Recording {
        events: Vec::new(),
        states: Vec::new(),
        deltas: Vec::new(),
        previous: initial.clone(),
        initial,
        historical: Vec::new(),
        capture,
        count: 0,
        digest: arguments
            .pointer("/options/summarize_events")
            .and_then(Value::as_bool)
            .unwrap_or(false)
            .then(crate::recording_digest::EventDigest::default),
    };
    let terminal = drive(session, resource, arguments, (&mut recording, pending))?;
    result(
        session,
        resource,
        (arguments, request),
        (terminal, recording),
    )
}

fn drive(
    session: &mut ApiSession,
    resource: &Value,
    arguments: &Value,
    progress: (&mut Recording, Vec<String>),
) -> Result<Value, ApiError> {
    let (recording, mut pending) = progress;
    let options = arguments.get("options");
    let seeking = crate::recording_options::seek_every_event(options);
    let batch_size = arguments
        .pointer("/options/batch_size")
        .and_then(Value::as_u64)
        .unwrap_or(1);
    loop {
        let batch = value(session.call(
            "advance",
            &json!({"resource":resource,"batch_size":batch_size}),
        ))?;
        append(session, resource, &batch, (&mut *recording, seeking))?;
        let kind = batch.pointer("/termination/kind").and_then(Value::as_str);
        if kind == Some("awaiting_input") && !pending.is_empty() {
            let text = pending.remove(0);
            value(session.call("input", &json!({"resource":resource,"text":text})))?;
        } else if kind != Some("running") {
            return Ok(batch);
        }
    }
}

fn append(
    session: &mut ApiSession,
    resource: &Value,
    batch: &Value,
    tracking: (&mut Recording, bool),
) -> Result<(), ApiError> {
    let (recording, seeking) = tracking;
    for event in batch
        .get("events")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing events"))?
    {
        append_event(session, resource, event, (&mut *recording, seeking))?;
    }
    Ok(())
}

fn append_event(
    session: &mut ApiSession,
    resource: &Value,
    event: &Value,
    tracking: (&mut Recording, bool),
) -> Result<(), ApiError> {
    let (recording, seeking) = tracking;
    let index = recording.count;
    recording.count = index
        .checked_add(1)
        .ok_or_else(|| usage("event count overflow"))?;
    if !recording.capture {
        if let Some(digest) = recording.digest.as_mut() {
            digest.append(event)?;
        } else {
            recording.events.push(event.clone());
        }
        if seeking {
            let historical = seek_event(session, resource, index)?;
            recording.historical.push(historical);
        }
        return Ok(());
    }
    let state = value(session.call("query_state", &json!({"resource":resource,"event":index})))?;
    recording.deltas.push(json!(crate::state_changes::between(
        &recording.previous,
        &state
    )));
    recording.previous = state.clone();
    recording.events.push(event.clone());
    recording.states.push(state);
    let historical = if seeking {
        seek_event(session, resource, index)?
    } else {
        value(session.call("seek", &json!({"resource":resource,"event":index})))?
    };
    recording.historical.push(historical);
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
        populate_terminal_fields(fields, (recording, horizon, queries), request);
    }
    Ok(terminal)
}

fn populate_terminal_fields(
    fields: &mut serde_json::Map<String, Value>,
    payload: (Recording, Value, Vec<Value>),
    request: &ExecuteRequest,
) {
    let (recording, horizon, queries) = payload;
    fields.insert("events".to_owned(), json!(recording.events));
    if let Some(digest) = recording.digest {
        fields.insert("event_summary".to_owned(), digest.finish());
    }
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

pub(crate) fn value(response: Value) -> Result<Value, ApiError> {
    response
        .get("value")
        .cloned()
        .ok_or_else(|| usage(&response.to_string()))
}

fn seek_event(session: &mut ApiSession, resource: &Value, index: usize) -> Result<Value, ApiError> {
    value(session.call("seek", &json!({"resource":resource,"event":0})))?;
    value(session.call("seek", &json!({"resource":resource,"event":index})))
}
