use serde_json::{Value, json};

pub(crate) const PARSE_ERROR: i64 = -32700;
pub(crate) const INVALID_REQUEST: i64 = -32600;
pub(crate) const METHOD_NOT_FOUND: i64 = -32601;
pub(crate) const INVALID_PARAMS: i64 = -32602;
pub(crate) const MAXIMUM_LINE_BYTES: usize = 1_048_576;

pub(crate) enum McpMessage {
    Request {
        identity: Value,
        method: String,
        parameters: Value,
    },
    Notification,
    Malformed(Value),
}

pub(crate) fn parse_line(line: &str) -> McpMessage {
    if line.len() > MAXIMUM_LINE_BYTES {
        return McpMessage::Malformed(error(&Value::Null, INVALID_REQUEST, "Invalid Request"));
    }
    let Ok(message) = serde_json::from_str::<Value>(line) else {
        return McpMessage::Malformed(error(&Value::Null, PARSE_ERROR, "Parse error"));
    };
    let identity = message.get("id").cloned();
    let method = message.get("method").and_then(Value::as_str);
    match (identity, method) {
        (Some(identity), Some(method)) => McpMessage::Request {
            identity,
            method: method.to_owned(),
            parameters: message.get("params").cloned().unwrap_or(Value::Null),
        },
        (None, Some(_)) => McpMessage::Notification,
        (identity, None) => McpMessage::Malformed(error(
            &identity.unwrap_or(Value::Null),
            INVALID_REQUEST,
            "Invalid Request",
        )),
    }
}

pub(crate) fn success(identity: &Value, result: &Value) -> Value {
    json!({"jsonrpc": "2.0", "id": identity, "result": result})
}

pub(crate) fn error(identity: &Value, code: i64, message: &str) -> Value {
    json!({"jsonrpc": "2.0", "id": identity, "error": {"code": code, "message": message}})
}

pub(crate) fn initialize_result() -> Value {
    json!({
        "protocolVersion": "2025-06-18",
        "capabilities": {"tools": {}, "resources": {}},
        "serverInfo": {"name": "pseudolearn", "version": "2026"}
    })
}

pub(crate) fn tool_result(payload: &Value, failed: bool) -> Value {
    json!({
        "content": [{"type": "text", "text": payload.to_string()}],
        "isError": failed
    })
}
