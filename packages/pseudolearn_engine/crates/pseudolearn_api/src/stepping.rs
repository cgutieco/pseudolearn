use crate::execution_resource::usage;
use crate::{ApiError, ApiSession, ExecuteRequest};
use serde_json::{Value, json};

struct Condition<'condition> {
    name: &'condition str,
    start_depth: u64,
    target_line: u64,
}

pub(crate) fn step(session: &mut ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    let request: ExecuteRequest = serde_json::from_value(
        arguments
            .get("request")
            .cloned()
            .ok_or_else(|| usage("missing request"))?,
    )
    .map_err(|error| usage(&error.to_string()))?;
    let from_event = number(arguments, "from_event")?;
    let name = arguments
        .get("condition")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing step condition"))?;
    let target_line = number(arguments, "target_line")?;
    let analysis = crate::recording::value(session.call("create_analysis", &json!(request)))?;
    let outcome = crate::recording::start(session, &analysis, &request).and_then(|resource| {
        let mut condition = Condition {
            name,
            start_depth: 0,
            target_line,
        };
        run_until(session, &resource, from_event, &mut condition)
    });
    let parent = analysis
        .get("document")
        .or_else(|| analysis.get("resource"))
        .cloned()
        .unwrap_or(Value::Null);
    crate::recording::value(session.call("release", &json!({"resource":parent})))?;
    outcome
}

fn number(arguments: &Value, name: &str) -> Result<u64, ApiError> {
    arguments
        .get(name)
        .and_then(Value::as_u64)
        .ok_or_else(|| usage("missing step position"))
}

fn run_until(
    session: &mut ApiSession,
    resource: &Value,
    from_event: u64,
    condition: &mut Condition<'_>,
) -> Result<Value, ApiError> {
    let mut index: u64 = 0;
    loop {
        let batch = crate::recording::value(
            session.call("advance", &json!({"resource":resource,"batch_size":1})),
        )?;
        let events = batch
            .get("events")
            .and_then(Value::as_array)
            .ok_or_else(|| usage("missing events"))?;
        if let Some(target) = scan(events, &mut index, from_event, condition) {
            return Ok(json!({"target":target}));
        }
        if batch.pointer("/termination/kind").and_then(Value::as_str) != Some("running") {
            return Ok(json!({"target":index}));
        }
    }
}

fn scan(
    events: &[Value],
    index: &mut u64,
    from_event: u64,
    condition: &mut Condition<'_>,
) -> Option<u64> {
    for event in events {
        if *index == from_event {
            condition.start_depth = field(event, "depth");
        } else if *index > from_event && satisfied(condition, event) {
            return Some(*index);
        }
        *index = index.saturating_add(1);
    }
    None
}

fn satisfied(condition: &Condition<'_>, event: &Value) -> bool {
    let entered = event.get("class").and_then(Value::as_str) == Some("statement_entered");
    match condition.name {
        "into" => entered,
        "over" => entered && field(event, "depth") <= condition.start_depth,
        "out" => field(event, "depth") < condition.start_depth,
        "line" => entered && field(event, "line") == condition.target_line,
        _ => false,
    }
}

fn field(event: &Value, name: &str) -> u64 {
    event.get(name).and_then(Value::as_u64).unwrap_or_default()
}
