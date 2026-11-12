use pseudolearn_bridge::api::{call_session, close_session, create_session};
use serde_json::{Value, json};

fn session_identifier() -> u64 {
    let created = create_session();
    assert!(created.is_ok());
    created.unwrap_or_default()
}

fn send(session: u64, operation: &str, arguments: Value) -> Value {
    let request = json!({"operation":operation,"arguments":arguments}).to_string();
    let response = call_session(session, request);
    let parsed = serde_json::from_str(&response);
    assert!(parsed.is_ok());
    parsed.unwrap_or(Value::Null)
}

#[test]
fn malformed_and_truncated_event_buffers_return_usage_failures() {
    let session = session_identifier();
    let malformed_json = send(
        session,
        "decode_events",
        json!({"encoding":"json","encoded":"["}),
    );
    assert_eq!(
        malformed_json.pointer("/failure/family"),
        Some(&json!("usage"))
    );
    let encoded = send(
        session,
        "encode_events",
        json!({"encoding":"binary","events":[{"class":"statement_entered","line":1,"depth":1}]}),
    );
    let bytes = encoded.pointer("/value").and_then(Value::as_array);
    assert!(bytes.is_some());
    let Some(bytes) = bytes else {
        return;
    };
    let mut truncated = bytes.clone();
    assert!(truncated.pop().is_some());
    let malformed_binary = send(
        session,
        "decode_events",
        json!({"encoding":"binary","encoded":truncated}),
    );
    assert_eq!(
        malformed_binary.pointer("/failure/family"),
        Some(&json!("usage"))
    );
    assert!(close_session(session).is_ok());
}
