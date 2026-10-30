use serde_json::Value;

const SEQUENCE_TEXT: &str = include_str!("../fixtures/lsp_interop/sequence.json");

#[derive(Clone, Debug, PartialEq)]
pub enum StepKind {
    Request,
    Notification,
}

#[derive(Clone, Debug)]
pub struct Step {
    pub number: u64,
    pub kind: StepKind,
    pub method: String,
    pub payload: Value,
}

pub fn load(root: &str) -> Result<Vec<Step>, String> {
    let placeholder = placeholder()?;
    let document: Value = serde_json::from_str(&SEQUENCE_TEXT.replace(&placeholder, root))
        .map_err(|error| error.to_string())?;
    document
        .get("steps")
        .and_then(Value::as_array)
        .ok_or("sequence has no steps")?
        .iter()
        .map(parse_step)
        .collect()
}

fn placeholder() -> Result<String, String> {
    let document: Value = serde_json::from_str(SEQUENCE_TEXT).map_err(|error| error.to_string())?;
    document
        .get("root_placeholder")
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| "sequence has no root placeholder".to_owned())
}

fn parse_step(entry: &Value) -> Result<Step, String> {
    let kind = match entry.get("kind").and_then(Value::as_str) {
        Some("request") => StepKind::Request,
        Some("notification") => StepKind::Notification,
        other => return Err(format!("unknown step kind {other:?}")),
    };
    Ok(Step {
        number: entry
            .get("step")
            .and_then(Value::as_u64)
            .ok_or("step has no number")?,
        kind,
        method: entry
            .get("method")
            .and_then(Value::as_str)
            .ok_or("step has no method")?
            .to_owned(),
        payload: entry.get("params").cloned().unwrap_or(Value::Null),
    })
}
