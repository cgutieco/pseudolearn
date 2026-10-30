use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";
const MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n";
const READING_MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo P\nDefinir Mutable pending Como Entero <- 0;\nLeer pending;\nEscribir pending;\nEscribir Doble(2);\nFinAlgoritmo\n";
const BROKEN_MAIN: &str = "Algoritmo P\nEscribir Desconocida(1);\nFinAlgoritmo\n";

fn arguments(main: &str) -> Value {
    json!({
        "entry": "app/main",
        "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
                {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
                {"name": "geo", "root": "geo", "kind": "library"}
            ],
            "files": [
                {"path": "app/main", "source_id": 1, "text": main},
                {"path": "geo/vectores", "source_id": 2, "text": LIBRARY}
            ]
        }
    })
}

fn value(outcome: &Value) -> Result<&Value, String> {
    outcome
        .get("value")
        .ok_or_else(|| format!("no value: {outcome}"))
}

fn start(session: &mut ApiSession, main: &str) -> Result<Value, String> {
    let outcome = session.call("start_project", &arguments(main));
    let resource = value(&outcome)?
        .get("resource")
        .cloned()
        .ok_or_else(|| format!("no resource: {outcome}"))?;
    Ok(resource)
}

fn advance(session: &mut ApiSession, resource: &Value) -> Result<Value, String> {
    let outcome = session.call(
        "advance",
        &json!({"resource": resource, "batch_size": 4096}),
    );
    value(&outcome).cloned()
}

fn kind(response: &Value) -> Option<&str> {
    response
        .pointer("/termination/kind")
        .and_then(Value::as_str)
}

#[test]
fn started_project_runs_to_completion_across_modules() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = start(&mut session, MAIN)?;
    let response = advance(&mut session, &resource)?;
    assert_eq!(kind(&response), Some("completed"));
    assert_eq!(response.get("output"), Some(&json!("42\n")));
    Ok(())
}

#[test]
fn started_project_waits_for_input_and_accepts_a_line() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = start(&mut session, READING_MAIN)?;
    let waiting = advance(&mut session, &resource)?;
    assert_eq!(kind(&waiting), Some("awaiting_input"));
    let fed = session.call("input", &json!({"resource": resource, "text": "7"}));
    value(&fed)?;
    let finished = advance(&mut session, &resource)?;
    assert_eq!(kind(&finished), Some("completed"));
    assert_eq!(finished.get("output"), Some(&json!("7\n4\n")));
    Ok(())
}

#[test]
fn input_wait_is_cancelled_by_releasing_the_resource() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = start(&mut session, READING_MAIN)?;
    let waiting = advance(&mut session, &resource)?;
    assert_eq!(kind(&waiting), Some("awaiting_input"));
    value(&session.call("release", &json!({"resource": resource})))?;
    let late = session.call("input", &json!({"resource": resource, "text": "7"}));
    assert!(late.get("value").is_none());
    Ok(())
}

#[test]
fn project_with_errors_does_not_create_a_resource() -> Result<(), String> {
    let mut session = ApiSession::default();
    let outcome = session.call("start_project", &arguments(BROKEN_MAIN));
    let result = value(&outcome)?;
    assert!(result.get("resource").is_none());
    let diagnostics = result.get("diagnostics").and_then(Value::as_array);
    assert!(diagnostics.is_some_and(|items| !items.is_empty()));
    Ok(())
}

#[test]
fn start_project_without_project_is_a_protocol_error() {
    let outcome = ApiSession::default().call("start_project", &json!({}));
    assert!(outcome.get("value").is_none());
}

#[test]
fn released_project_execution_rejects_further_advance() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = start(&mut session, MAIN)?;
    value(&session.call("release", &json!({"resource": resource})))?;
    let outcome = session.call("advance", &json!({"resource": resource, "batch_size": 1}));
    assert!(outcome.get("value").is_none());
    Ok(())
}

#[test]
fn two_started_projects_have_independent_resources() -> Result<(), String> {
    let mut session = ApiSession::default();
    let first = start(&mut session, MAIN)?;
    let second = start(&mut session, MAIN)?;
    assert_ne!(first, second);
    value(&session.call("release", &json!({"resource": first})))?;
    let response = advance(&mut session, &second)?;
    assert_eq!(kind(&response), Some("completed"));
    Ok(())
}
