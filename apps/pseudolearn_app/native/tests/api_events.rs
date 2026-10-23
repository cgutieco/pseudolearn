use pseudolearn_bridge::api::{call_session, close_session, create_session};
use serde_json::{Value, json};

fn session_identifier() -> u64 {
    create_session().unwrap_or_default()
}

fn send(session: u64, operation: &str, arguments: Value) -> Value {
    let request = json!({"operation":operation,"arguments":arguments}).to_string();
    serde_json::from_str(&call_session(session, request)).unwrap_or(Value::Null)
}

#[test]
fn event_binary_versions_cross_the_native_bridge_with_source_identity() {
    let session = session_identifier();
    let negotiated = send(session, "negotiate", json!({"event_binary_versions":[1,2]}));
    assert_eq!(
        negotiated.pointer("/value/event_binary_write_version"),
        Some(&json!(2))
    );
    let events = json!([{"class":"statement_entered","line":1,"depth":1,"source":{
        "revision_id":"rev1","node_id":"rev1.n1",
        "identity":{"project_id":"7","revision_id":"11","source_id":2},
        "span":{"start":{"line":1,"column":1},"end":{"line":1,"column":2},
            "start_byte":"0","end_byte":"1"}
    }}]);
    let encoded = send(
        session,
        "encode_events",
        json!({"events":events,"encoding":"binary","version":2}),
    );
    let bytes = encoded.pointer("/value").cloned().unwrap_or_default();
    assert_eq!(bytes.get(4), Some(&json!(2)));
    let decoded = send(
        session,
        "decode_events",
        json!({"encoded":bytes,"encoding":"binary"}),
    );
    assert_eq!(decoded.get("value"), Some(&events));
    let rejected = send(
        session,
        "encode_events",
        json!({"events":events,"encoding":"binary","version":1}),
    );
    assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    assert!(close_session(session).is_ok());
}

#[test]
fn truncated_event_binary_is_rejected_at_the_native_bridge() {
    let session = session_identifier();
    let response = send(
        session,
        "decode_events",
        json!({"encoded":[80,76,69,86,2],"encoding":"binary"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
    assert!(close_session(session).is_ok());
}
