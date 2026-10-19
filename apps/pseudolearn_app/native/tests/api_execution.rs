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

fn resource_identifier(response: &Value) -> u64 {
    let identifier = response.pointer("/value/resource").and_then(Value::as_u64);
    assert!(identifier.is_some());
    identifier.unwrap_or_default()
}

fn create_analysis(session: u64, program: &str) -> u64 {
    let response = send(
        session,
        "create_analysis",
        json!({"program":program,"profile":"es","strictness":"strict"}),
    );
    resource_identifier(&response)
}

fn start_execution(session: u64, analysis: u64, limits: Value) -> u64 {
    let response = send(
        session,
        "start",
        json!({"analysis":analysis,"seed":42,"inputs":[],"observe":"events","limits":limits}),
    );
    resource_identifier(&response)
}

fn advance(session: u64, execution: u64, batch_size: u64) -> Value {
    send(
        session,
        "advance",
        json!({"resource":execution,"batch_size":batch_size}),
    )
}

fn cancel_twice(session: u64, execution: u64) {
    for _ in 0..2 {
        assert!(
            send(session, "cancel", json!({"resource":execution}))
                .get("value")
                .is_some()
        );
    }
}

fn assert_termination(response: &Value, termination: &str) {
    assert_eq!(
        response.pointer("/value/termination/kind"),
        Some(&json!(termination))
    );
}

#[test]
fn execution_advances_queries_and_releases_resources() {
    let session = session_identifier();
    let analysis = create_analysis(session, "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n");
    let execution = start_execution(session, analysis, json!({}));
    let batch = send(
        session,
        "advance",
        json!({"resource":execution,"batch_size":1}),
    );
    assert!(
        batch
            .pointer("/value/events")
            .and_then(Value::as_array)
            .is_some()
    );
    assert!(
        send(
            session,
            "query_state",
            json!({"resource":execution,"event":0})
        )
        .get("value")
        .is_some()
    );
    assert!(
        send(session, "release", json!({"resource":analysis}))
            .get("value")
            .is_some()
    );
    assert!(
        send(session, "release", json!({"resource":analysis}))
            .get("failure")
            .is_some()
    );
    assert!(close_session(session).is_ok());
}

#[test]
fn cancellation_is_repeatable_and_stops_later_events() {
    let session = session_identifier();
    let program = "Algoritmo P\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n";
    let analysis = create_analysis(session, program);
    let execution = start_execution(session, analysis, json!({}));
    let first = advance(session, execution, 8);
    assert!(
        first
            .pointer("/value/events")
            .and_then(Value::as_array)
            .is_some()
    );
    cancel_twice(session, execution);
    let cancelled = advance(session, execution, 8);
    assert_termination(&cancelled, "cancelled");
    let repeated = advance(session, execution, 8);
    assert_termination(&repeated, "cancelled");
    assert_eq!(
        repeated
            .pointer("/value/events")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(0)
    );
    assert!(close_session(session).is_ok());
}

#[test]
fn execution_limits_are_independent_of_batch_size() {
    let session = session_identifier();
    let program =
        "Algoritmo P\nDefinir x Como Entero;\nx <- 1;\nx <- 2;\nEscribir x;\nFinAlgoritmo\n";
    let analysis = create_analysis(session, program);
    let execution = start_execution(session, analysis, json!({"statements":1}));
    let response = advance(session, execution, 128);
    assert_eq!(
        response.pointer("/value/termination/kind"),
        Some(&json!("limit_reached"))
    );
    assert_eq!(
        response.pointer("/value/termination/limit"),
        Some(&json!("statements"))
    );
    assert!(close_session(session).is_ok());
}
