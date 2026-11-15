use crate::service::workspace_campaign::clock::Clock;
use crate::service::workspace_campaign::transport::Transport;
use serde_json::Value;
use std::collections::BTreeMap;

pub type Published = BTreeMap<String, Value>;

pub struct Observation {
    pub nanos: u64,
    pub published: Published,
    pub response: Value,
}

fn request_id(message: &Value) -> Result<u64, String> {
    message
        .get("id")
        .and_then(Value::as_u64)
        .ok_or_else(|| "the last message of a step must be a request".to_owned())
}

fn remember(message: &Value, published: &mut Published) -> bool {
    if message.get("method").and_then(Value::as_str) != Some("textDocument/publishDiagnostics") {
        return false;
    }
    if let Some(uri) = message.pointer("/params/uri").and_then(Value::as_str) {
        let diagnostics = message
            .pointer("/params/diagnostics")
            .cloned()
            .unwrap_or(Value::Null);
        published.insert(uri.to_owned(), diagnostics);
    }
    true
}

fn await_response(
    transport: &mut impl Transport,
    wanted: u64,
    published: &mut Published,
) -> Result<Value, String> {
    loop {
        let message = transport.receive()?;
        if remember(&message, published) {
            continue;
        }
        if message.get("id").and_then(Value::as_u64) == Some(wanted)
            && message.get("method").is_none()
        {
            return Ok(message);
        }
    }
}

pub fn observe(
    transport: &mut impl Transport,
    clock: &mut impl Clock,
    messages: &[Value],
) -> Result<Observation, String> {
    let wanted = request_id(messages.last().ok_or("empty step")?)?;
    let mut published = Published::new();
    let mut response = Value::Null;
    let started = clock.now_nanos();
    for message in messages {
        transport.send(message)?;
        if let Some(identifier) = message.get("id").and_then(Value::as_u64) {
            let current = await_response(transport, identifier, &mut published)?;
            if identifier == wanted {
                response = current;
            }
        }
    }
    let nanos = clock.now_nanos().saturating_sub(started);
    Ok(Observation {
        nanos,
        published,
        response,
    })
}

struct Untimed;

impl Clock for Untimed {
    fn now_nanos(&mut self) -> u64 {
        0
    }
}

pub fn settle(transport: &mut impl Transport, messages: &[Value]) -> Result<Published, String> {
    observe(transport, &mut Untimed, messages).map(|observation| observation.published)
}
