use crate::{properties::PropertySubject, property_api as api, property_scenarios::Scenario};
use serde_json::{Value, json};

type Difference = Result<Option<(Value, Value)>, String>;

struct StepQuery<'step> {
    from_event: usize,
    condition: &'step str,
    target_line: u64,
}

pub(crate) fn check(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    base: &Value,
) -> Difference {
    let events = api::array(base, "events")?;
    for (start_index, event) in events.iter().enumerate() {
        let current_depth = depth(event);
        let target_line = line(event);
        for condition in ["into", "over", "out", "line"] {
            let expected_index = match condition {
                "into" => step_into(events, start_index),
                "over" => step_over(events, start_index, current_depth),
                "out" => step_out(events, start_index, current_depth),
                "line" => step_line(events, start_index, target_line),
                _ => events.len(),
            };
            let expected = json!({"target": expected_index});
            let query = StepQuery {
                from_event: start_index,
                condition,
                target_line,
            };
            let actual = step_request(subject, scenario, &query)?;
            if actual != expected {
                return Ok(Some((expected, actual)));
            }
        }
    }
    Ok(None)
}

fn step_request(
    subject: &mut impl PropertySubject,
    scenario: &Scenario,
    query: &StepQuery<'_>,
) -> Result<Value, String> {
    let arguments = json!({
        "request": scenario.request,
        "from_event": query.from_event,
        "condition": query.condition,
        "target_line": query.target_line,
    });
    api::value(api::call(subject, "step", arguments)?)
}

fn step_into(events: &[Value], start_index: usize) -> usize {
    for (offset, event) in events
        .iter()
        .enumerate()
        .skip(start_index.saturating_add(1))
    {
        if is_statement_entered(event) {
            return offset;
        }
    }
    events.len()
}

fn step_over(events: &[Value], start_index: usize, current_depth: u64) -> usize {
    for (offset, event) in events
        .iter()
        .enumerate()
        .skip(start_index.saturating_add(1))
    {
        if is_statement_entered(event) && depth(event) <= current_depth {
            return offset;
        }
    }
    events.len()
}

fn step_out(events: &[Value], start_index: usize, current_depth: u64) -> usize {
    for (offset, event) in events
        .iter()
        .enumerate()
        .skip(start_index.saturating_add(1))
    {
        if depth(event) < current_depth {
            return offset;
        }
    }
    events.len()
}

fn step_line(events: &[Value], start_index: usize, target_line: u64) -> usize {
    for (offset, event) in events
        .iter()
        .enumerate()
        .skip(start_index.saturating_add(1))
    {
        if is_statement_entered(event) && line(event) == target_line {
            return offset;
        }
    }
    events.len()
}

fn is_statement_entered(event: &Value) -> bool {
    matches!(
        event
            .get("clase")
            .or_else(|| event.get("class"))
            .and_then(Value::as_str),
        Some("statement_entered" | "enter")
    )
}

fn depth(event: &Value) -> u64 {
    event
        .get("profundidad")
        .or_else(|| event.get("depth"))
        .and_then(Value::as_u64)
        .unwrap_or_default()
}

fn line(event: &Value) -> u64 {
    event
        .get("linea")
        .or_else(|| event.get("line"))
        .and_then(Value::as_u64)
        .unwrap_or_default()
}
