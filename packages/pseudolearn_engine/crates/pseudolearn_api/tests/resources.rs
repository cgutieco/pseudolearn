use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn created(session: &mut ApiSession, program: &str) -> Result<Value, String> {
    let result = session.call("create_analysis", &json!({"program":program}));
    result
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| result.to_string())
}

#[test]
fn released_document_invalidates_its_descendants() -> Result<(), String> {
    let mut session = ApiSession::default();
    let document = session.call(
        "create_document",
        &json!({"program":"Algoritmo Resource\nFinAlgoritmo\n"}),
    );
    let document = document
        .pointer("/value/resource")
        .ok_or("missing document")?;
    let analysis = session.call("create_analysis", &json!({"document":document}));
    let analysis = analysis
        .pointer("/value/resource")
        .ok_or("missing analysis")?;
    assert!(
        session
            .call("release", &json!({"resource":document}))
            .get("value")
            .is_some()
    );
    assert_eq!(
        session
            .call("analysis", &json!({"resource":analysis}))
            .pointer("/failure/family")
            .cloned()
            .unwrap_or(Value::Null),
        "usage"
    );
    Ok(())
}

#[test]
fn suspended_input_resumes_without_repeating_output() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = created(
        &mut session,
        "Algoritmo Resource\nDefinir Mutable value Como Entero <- 0;\nEscribir 8;\nLeer value;\nEscribir value + 4;\nFinAlgoritmo\n",
    )?;
    let execution = session.call("start", &json!({"analysis":analysis}));
    let resource = execution
        .pointer("/value/resource")
        .ok_or_else(|| execution.to_string())?;
    let first = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    assert_eq!(
        first
            .pointer("/value/termination/kind")
            .cloned()
            .unwrap_or(Value::Null),
        "awaiting_input"
    );
    assert_eq!(
        first
            .pointer("/value/output")
            .cloned()
            .unwrap_or(Value::Null),
        "8\n"
    );
    assert!(
        session
            .call("input", &json!({"resource":resource,"text":"13"}))
            .get("value")
            .is_some()
    );
    let last = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    assert_eq!(
        last.pointer("/value/termination/kind")
            .cloned()
            .unwrap_or(Value::Null),
        "completed"
    );
    assert_eq!(
        last.pointer("/value/output")
            .cloned()
            .unwrap_or(Value::Null),
        "8\n17\n"
    );
    assert_eq!(
        last.pointer("/value/inputs_consumed")
            .cloned()
            .unwrap_or(Value::Null),
        1
    );
    Ok(())
}

#[test]
fn seeking_does_not_change_the_live_continuation() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = created(
        &mut session,
        "Algoritmo Resource\nDefinir Mutable value Como Entero <- 0;\nvalue <- 9;\nEscribir value;\nFinAlgoritmo\n",
    )?;
    let execution = session.call("start", &json!({"analysis":analysis}));
    let resource = execution
        .pointer("/value/resource")
        .ok_or("missing execution")?;
    let first = session.call("advance", &json!({"resource":resource,"batch_size":4}));
    assert_eq!(
        first
            .pointer("/value/events")
            .cloned()
            .unwrap_or(Value::Null)
            .as_array()
            .map(Vec::len),
        Some(4)
    );
    let state = session.call("seek", &json!({"resource":resource,"event":1}));
    assert!(state.get("value").is_some(), "{state}");
    let last = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    assert_eq!(
        last.pointer("/value/output")
            .cloned()
            .unwrap_or(Value::Null),
        "9\n"
    );
    assert_eq!(
        last.pointer("/value/termination/kind")
            .cloned()
            .unwrap_or(Value::Null),
        "completed"
    );
    assert_eq!(
        session
            .call("query_state", &json!({"resource":resource,"event":999}))
            .pointer("/failure/family")
            .cloned()
            .unwrap_or(Value::Null),
        "usage"
    );
    Ok(())
}

#[test]
fn starting_an_analysis_with_errors_returns_usage_failure() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = created(&mut session, "invalid source")?;
    assert_eq!(
        session
            .call("start", &json!({"analysis":analysis}))
            .pointer("/failure/family")
            .cloned()
            .unwrap_or(Value::Null),
        "usage"
    );
    assert_eq!(
        session
            .call("analysis", &json!({"resource":u64::MAX}))
            .pointer("/failure/family")
            .cloned()
            .unwrap_or(Value::Null),
        "usage"
    );
    Ok(())
}
