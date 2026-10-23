use pseudolearn_api::{
    AnalyzeRequest, ApiSourceIdentity, ExecuteRequest, IrRequest, execute_analyze, execute_ir,
    execute_program,
};
use serde_json::json;

const IDENTITY: ApiSourceIdentity = ApiSourceIdentity {
    project_id: 7,
    revision_id: 11,
    source_id: 2,
};

#[test]
fn analysis_diagnostics_and_tokens_keep_their_source_identity() {
    let response = execute_analyze(&AnalyzeRequest {
        program: "algorithm P\nwrite @;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
        source: Some(IDENTITY),
    });
    let diagnostic = response.diagnostics.first();
    assert_eq!(
        diagnostic.and_then(|value| value.span.source),
        Some(IDENTITY)
    );
    assert_eq!(
        response
            .tokens
            .iter()
            .find(|token| token.kind == "invalid_character")
            .and_then(|token| token.span.source),
        Some(IDENTITY)
    );
}

#[test]
fn execution_faults_and_events_keep_the_same_source_identity() {
    let request = ExecuteRequest {
        program: "Algoritmo P\nEscribir 1 div 0;\nFinAlgoritmo\n".to_owned(),
        observe: "events".to_owned(),
        source: Some(IDENTITY),
        ..ExecuteRequest::default()
    };
    let response = execute_program(&request);
    assert_eq!(
        response
            .diagnostics
            .iter()
            .find(|diagnostic| diagnostic.code == "divisionByZero")
            .and_then(|diagnostic| diagnostic.span.source),
        Some(IDENTITY)
    );
    let event_identity = response
        .events
        .iter()
        .find_map(|event| event.pointer("/source/identity"));
    assert_eq!(event_identity, Some(&json!(IDENTITY)));
}

#[test]
fn legacy_analysis_keeps_its_previous_unqualified_span_shape() {
    let response = execute_analyze(&AnalyzeRequest {
        program: "Algoritmo P\nEscribir @;\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    });
    assert!(
        response
            .diagnostics
            .first()
            .is_some_and(|diagnostic| diagnostic.span.source.is_none())
    );
}

#[test]
fn source_identity_survives_ir_lowering_and_canonical_reprint() {
    let response = execute_ir(&IrRequest {
        program_ir: String::new(),
        program: "Algoritmo P\nEscribir 1 div 0;\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: Some(IDENTITY),
    });
    let reprint = response.ir.reprint.as_deref().unwrap_or_default();
    assert!(reprint.contains("@f2:"));
}

#[test]
fn session_boundary_rejects_incomplete_source_identity() {
    let mut session = pseudolearn_api::ApiSession::default();
    let response = session.call(
        "create_analysis",
        &json!({"program":"", "source":{"project_id":"7","revision_id":"0","source_id":2}}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn wire_identity_preserves_unsigned_64_bit_values_as_decimal_strings() {
    let mut session = pseudolearn_api::ApiSession::default();
    let response = session.call(
        "create_analysis",
        &json!({
            "program":"Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
            "profile":"es",
            "strictness":"strict",
            "source":{"project_id":"18446744073709551615","revision_id":"9007199254740993","source_id":2}
        }),
    );
    let resource = response
        .pointer("/value/resource")
        .cloned()
        .unwrap_or_default();
    let report = session.call("analysis", &json!({"resource":resource}));
    assert_eq!(
        report.pointer("/value/diagnostics/0/span/source"),
        Some(&json!({
            "project_id":"18446744073709551615",
            "revision_id":"9007199254740993",
            "source_id":2
        }))
    );
}
