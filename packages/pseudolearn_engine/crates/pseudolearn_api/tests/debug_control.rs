use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn execution(session: &mut ApiSession, program: &str) -> Result<Value, String> {
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource")}),
    );
    started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| started.to_string())
}

fn pump(session: &mut ApiSession, resource: &Value) -> Value {
    for _ in 0..1000 {
        let response = session.call("advance", &json!({"resource":resource,"batch_size":64}));
        if response.pointer("/value/debug/stopped") == Some(&json!(true))
            || response.pointer("/value/termination/kind") != Some(&json!("running"))
        {
            return response;
        }
    }
    Value::Null
}

#[test]
fn entry_and_next_keep_one_live_execution() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(
        &mut session,
        "Algoritmo Probe\nDefinir value Como Entero <- 41;\nEscribir value + 1;\nFinAlgoritmo\n",
    )?;
    let configured = session.call(
        "debug_configure",
        &json!({"resource":resource,"stop_on_entry":true,"breakpoints":[]}),
    );
    assert!(configured.get("value").is_some(), "{configured}");
    let first = pump(&mut session, &resource);
    assert_eq!(
        first.pointer("/value/debug/reason"),
        Some(&json!("entry")),
        "{first}"
    );
    assert_eq!(first.pointer("/value/output"), Some(&json!("")));
    session.call(
        "debug_control",
        &json!({"resource":resource,"command":"next","task_id":0}),
    );
    let second = pump(&mut session, &resource);
    assert_eq!(
        second.pointer("/value/debug/reason"),
        Some(&json!("step")),
        "{second}"
    );
    session.call(
        "debug_control",
        &json!({"resource":resource,"command":"continue"}),
    );
    let finished = pump(&mut session, &resource);
    assert_eq!(
        finished.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{finished}"
    );
    assert_eq!(finished.pointer("/value/output"), Some(&json!("42\n")));
    Ok(())
}

#[test]
fn pause_preserves_input_and_rejects_unknown_commands() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(
        &mut session,
        "Algoritmo Probe\nDefinir Mutable value Como Cadena <- \"\";\nLeer value;\nEscribir value;\nFinAlgoritmo\n",
    )?;
    session.call(
        "debug_configure",
        &json!({"resource":resource,"breakpoints":[]}),
    );
    let awaiting = pump(&mut session, &resource);
    assert_eq!(
        awaiting.pointer("/value/termination/kind"),
        Some(&json!("awaiting_input"))
    );
    let paused = session.call(
        "debug_control",
        &json!({"resource":resource,"command":"pause"}),
    );
    assert_eq!(
        paused.pointer("/value/stopped"),
        Some(&json!(true)),
        "{paused}"
    );
    let invalid = session.call(
        "debug_control",
        &json!({"resource":resource,"command":"restart"}),
    );
    assert_eq!(invalid.pointer("/failure/family"), Some(&json!("usage")));
    session.call("input", &json!({"resource":resource,"text":""}));
    session.call(
        "debug_control",
        &json!({"resource":resource,"command":"continue"}),
    );
    let finished = pump(&mut session, &resource);
    assert_eq!(
        finished.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{finished}"
    );
    Ok(())
}

#[test]
fn breakpoints_are_resolved_without_sliding_to_another_statement() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(
        &mut session,
        "Algoritmo Probe\n\nEscribir 7;\nFinAlgoritmo\n",
    )?;
    let configured = session.call("debug_configure", &json!({"resource":resource,"breakpoints":[{"source_id":0,"line":2},{"source_id":0,"line":3}]}));
    assert_eq!(
        configured.pointer("/value/breakpoints/0/verified"),
        Some(&json!(false)),
        "{configured}"
    );
    assert_eq!(
        configured.pointer("/value/breakpoints/1/verified"),
        Some(&json!(true)),
        "{configured}"
    );
    let stopped = pump(&mut session, &resource);
    assert_eq!(
        stopped.pointer("/value/debug/reason"),
        Some(&json!("breakpoint")),
        "{stopped}"
    );
    assert_eq!(stopped.pointer("/value/output"), Some(&json!("")));
    Ok(())
}
