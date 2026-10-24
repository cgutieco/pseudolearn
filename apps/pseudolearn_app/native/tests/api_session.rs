use pseudolearn_bridge::api::{call_session, close_session, create_session};
use serde_json::{Value, json};

fn session_identifier() -> u64 {
    let created = create_session();
    assert!(created.is_ok());
    created.unwrap_or_default()
}

fn single_file_analysis(session: u64, program: &str) -> Result<(Value, u64), String> {
    let created = send(
        session,
        "create_analysis",
        json!({"program":program,"profile":"es","strictness":"strict"}),
    );
    let resource = created
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or("missing analysis resource")?;
    let document = created
        .pointer("/value/document")
        .and_then(Value::as_u64)
        .ok_or("missing document resource")?;
    Ok((
        send(session, "analysis", json!({"resource":resource})),
        document,
    ))
}

fn has_original_identifier_span(analysis: &Value) -> bool {
    analysis
        .pointer("/value/tokens")
        .and_then(Value::as_array)
        .is_some_and(|tokens| {
            tokens.iter().any(|token| {
                token.get("kind") == Some(&json!("identifier"))
                    && token.pointer("/span/start/line") == Some(&json!(3))
                    && token.pointer("/span/start/column") == Some(&json!(1))
                    && token.pointer("/span/end/column") == Some(&json!(5))
            })
        })
}

fn stored_program(session: u64, document: u64) -> Result<String, String> {
    send(session, "document", json!({"resource":document}))
        .pointer("/value/program")
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| "missing stored program".to_owned())
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
fn source_identity_crosses_the_native_json_boundary_exactly() {
    let session = session_identifier();
    let created = send(
        session,
        "create_analysis",
        json!({
            "program":"Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
            "profile":"es",
            "strictness":"strict",
            "source":{"project_id":"18446744073709551615","revision_id":"9007199254740993","source_id":2}
        }),
    );
    let resource = created.pointer("/value/resource").cloned();
    assert!(resource.is_some());
    let analysis = send(session, "analysis", json!({"resource":resource}));
    assert_eq!(
        analysis.pointer("/value/diagnostics/0/span/source"),
        Some(&json!({
            "project_id":"18446744073709551615",
            "revision_id":"9007199254740993",
            "source_id":2
        }))
    );
    assert!(close_session(session).is_ok());
}

#[test]
fn loose_unicode_source_round_trips_through_native_json_analysis() -> Result<(), String> {
    let session = session_identifier();
    let program = "Algoritmo P\nDefinir año, Importar, Exportar, import, export Como Entero;\nan\u{0303}o <- 5;\nImportar <- 1;\nExportar <- 2;\nimport <- 3;\nexport <- 4;\nEscribir año, Importar, Exportar, import, export;\nFinAlgoritmo\n";
    let (analysis, document) = single_file_analysis(session, program)?;
    assert_eq!(analysis.pointer("/value/diagnostics"), Some(&json!([])));
    assert_eq!(stored_program(session, document)?, program);
    assert!(has_original_identifier_span(&analysis));
    assert!(close_session(session).is_ok());
    Ok(())
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
