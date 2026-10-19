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
fn session_negotiates_and_closes() {
    let session = session_identifier();
    assert_eq!(
        send(session, "negotiate", json!({"editions":"2026"})),
        json!({"value":null})
    );
    assert!(close_session(session).is_ok());
    assert!(
        call_session(
            session,
            json!({"operation":"version","arguments":{}}).to_string()
        )
        .contains("invalid session")
    );
}

#[test]
fn version_reports_only_available_capabilities() {
    let session = session_identifier();
    let version = send(session, "version", json!({}));
    let capabilities = version
        .pointer("/value/capabilities")
        .and_then(Value::as_array);
    assert!(capabilities.is_some());
    let Some(capabilities) = capabilities else {
        return;
    };
    assert!(capabilities.iter().any(|value| value == "execute"));
    for announced in ["program_view", "state_pages"] {
        assert!(capabilities.iter().any(|value| value == announced));
        assert_eq!(
            send(session, "negotiate", json!({"capabilities":announced})),
            json!({"value":null})
        );
    }
    assert_eq!(
        send(session, "negotiate", json!({"capabilities":"unknown"})).pointer("/failure/family"),
        Some(&json!("version"))
    );
    assert!(close_session(session).is_ok());
}

#[test]
fn invalid_requests_return_typed_failures() {
    let response = call_session(u64::MAX, "{".to_owned());
    assert!(response.contains("request is not valid JSON"));
    let session = session_identifier();
    let response = send(session, "negotiate", json!({"editions":"unknown"}));
    assert_eq!(response.pointer("/failure/family"), Some(&json!("version")));
    assert!(close_session(session).is_ok());
}

#[test]
fn api_faults_are_contained_at_the_bridge() {
    let session = session_identifier();
    let response = send(
        session,
        "inject_fault",
        json!({"stage":"execution","request":{"program":""}}),
    );
    assert_eq!(
        response.pointer("/failure/family"),
        Some(&json!("internal"))
    );
    assert!(close_session(session).is_ok());
}
