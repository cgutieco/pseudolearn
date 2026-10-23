use pseudolearn_bridge::api::{call_session, close_session, create_session};
use serde_json::{Value, json};

fn session_identifier() -> u64 {
    let created = create_session();
    assert!(created.is_ok());
    created.unwrap_or_default()
}

fn send(session: u64, operation: &str, arguments: Value) -> Value {
    let request = json!({"operation":operation,"arguments":arguments}).to_string();
    let parsed = serde_json::from_str(&call_session(session, request));
    assert!(parsed.is_ok());
    parsed.unwrap_or(Value::Null)
}

fn resource(response: &Value) -> u64 {
    let identifier = response.pointer("/value/resource").and_then(Value::as_u64);
    assert!(identifier.is_some());
    identifier.unwrap_or_default()
}

fn started(session: u64, program: &str) -> (u64, u64) {
    let analysis = resource(&send(
        session,
        "create_analysis",
        json!({"program":program}),
    ));
    let document = send(session, "analysis", json!({"resource":analysis}));
    assert!(document.get("value").is_some());
    let execution = resource(&send(
        session,
        "start",
        json!({"analysis":analysis,"observe":"events"}),
    ));
    (analysis, execution)
}

#[test]
fn events_carry_node_identity_from_the_document_view() {
    let session = session_identifier();
    let (_, execution) = started(
        session,
        "Algoritmo P\nEscribir 1; Escribir 2;\nFinAlgoritmo\n",
    );
    let batch = send(
        session,
        "advance",
        json!({"resource":execution,"batch_size":64}),
    );
    let events = batch
        .pointer("/value/events")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    let entered: Vec<_> = events
        .iter()
        .filter(|event| event.get("class") == Some(&json!("statement_entered")))
        .filter_map(|event| event.pointer("/source/node_id"))
        .collect();
    assert_eq!(entered.len(), 2);
    assert_ne!(entered.first(), entered.get(1));
    assert!(close_session(session).is_ok());
}

#[test]
fn source_identity_survives_the_native_view_and_event_boundary() -> Result<(), String> {
    let session = session_identifier();
    let identity = json!({"project_id":"7","revision_id":"11","source_id":2});
    let created = send(
        session,
        "create_analysis",
        json!({
            "program":"Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
            "source":identity
        }),
    );
    let analysis = resource(&created);
    let document = created
        .pointer("/value/document")
        .and_then(Value::as_u64)
        .ok_or("missing source document")?;
    let view = send(session, "program_view", json!({"resource":document}));
    assert_eq!(view.pointer("/value/source"), Some(&identity));
    let execution = resource(&send(
        session,
        "start",
        json!({"analysis":analysis,"observe":"events"}),
    ));
    let batch = send(
        session,
        "advance",
        json!({"resource":execution,"batch_size":64}),
    );
    let event_identity = batch
        .pointer("/value/events")
        .and_then(Value::as_array)
        .and_then(|events| {
            events
                .iter()
                .find_map(|event| event.pointer("/source/identity"))
        });
    assert_eq!(event_identity, Some(&identity));
    assert!(close_session(session).is_ok());
    Ok(())
}

#[test]
fn document_view_and_node_queries_cross_the_bridge() {
    let session = session_identifier();
    let document = resource(&send(
        session,
        "create_document",
        json!({"program":"Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}),
    ));
    let view = send(session, "program_view", json!({"resource":document}));
    let identifier = view.pointer("/value/nodes/0/node_id").cloned();
    assert!(identifier.is_some());
    let node = send(
        session,
        "query_node",
        json!({"resource":document,"node_id":identifier}),
    );
    assert!(node.pointer("/value/node/kind").is_some());
    let stale = send(
        session,
        "query_node",
        json!({"resource":document,"node_id":"rev999.n0"}),
    );
    assert_eq!(stale.pointer("/failure/family"), Some(&json!("usage")));
    assert!(close_session(session).is_ok());
}

#[test]
fn paged_state_queries_reject_foreign_cursors_after_release() {
    let session = session_identifier();
    let program = "Algoritmo P\nDimension a[5] Como Entero;\na[0] <- 1;\nFinAlgoritmo\n";
    let (_, execution) = started(session, program);
    send(
        session,
        "advance",
        json!({"resource":execution,"batch_size":64}),
    );
    let page = json!({"resource":execution,"query":"array_cells","target":1,
        "event":3,"page_size":2});
    let first = send(session, "query_page", page.clone());
    assert_eq!(first.pointer("/value/truncated"), Some(&json!(true)));
    let mut other = page;
    if let Some(fields) = other.as_object_mut() {
        fields.insert("page_size".to_owned(), json!(3));
        fields.insert(
            "cursor".to_owned(),
            first
                .pointer("/value/next_cursor")
                .cloned()
                .unwrap_or_default(),
        );
    }
    let rejected = send(session, "query_page", other);
    assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    assert!(
        send(session, "release", json!({"resource":execution}))
            .get("value")
            .is_some()
    );
    let released = send(
        session,
        "query_page",
        json!({"resource":execution,"query":"array_cells","target":1,"event":3,"page_size":2}),
    );
    assert_eq!(released.pointer("/failure/family"), Some(&json!("usage")));
    assert!(close_session(session).is_ok());
}
