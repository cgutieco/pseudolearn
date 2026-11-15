use serde_json::{Value, json};

pub(crate) fn matches(expected: &Value, actual: &Value) -> bool {
    let Some(output) = actual.get("output").and_then(Value::as_str) else {
        return false;
    };
    let Some(messages) = decode(output) else {
        return false;
    };
    let responses: Vec<_> = messages
        .iter()
        .filter(|message| message.get("type").and_then(Value::as_str) == Some("response"))
        .collect();
    let events: Vec<_> = messages
        .iter()
        .filter(|message| message.get("type").and_then(Value::as_str) == Some("event"))
        .collect();
    crate::tool_comparison::subset(
        expected,
        Some(&json!({
            "messages":messages,"responses":responses,"events":events
        })),
    )
}

fn decode(mut remaining: &str) -> Option<Vec<Value>> {
    let mut messages = Vec::new();
    while !remaining.is_empty() {
        let (header, body) = remaining.split_once("\r\n\r\n")?;
        if header.len() > 8192 {
            return None;
        }
        let length = content_length(header)?;
        let payload = body.get(..length)?;
        messages.push(serde_json::from_str::<Value>(payload).ok()?);
        remaining = body.get(length..)?;
    }
    Some(messages)
}

fn content_length(header: &str) -> Option<usize> {
    let mut length = None;
    for line in header.split("\r\n") {
        let (name, value) = line.split_once(':')?;
        if name.eq_ignore_ascii_case("Content-Length") {
            if length.is_some() {
                return None;
            }
            length = value.trim().parse::<usize>().ok();
        }
    }
    length.filter(|length| *length <= 8388608)
}
