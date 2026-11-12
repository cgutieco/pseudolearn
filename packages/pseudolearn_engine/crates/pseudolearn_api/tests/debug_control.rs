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
        "Algoritmo Probe\nDefinir value Como Cadena <- \"\";\nLeer value;\nEscribir value;\nFinAlgoritmo\n",
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
    let pending_input = awaiting
        .pointer("/value/pending_input")
        .ok_or_else(|| format!("missing input identity: {awaiting}"))?;
    let resource_id = pending_input
        .get("resource_id")
        .ok_or("missing input resource identity")?;
    let task_id = pending_input
        .get("task_id")
        .ok_or("missing input task identity")?;
    let request_id = pending_input
        .get("request_id")
        .ok_or("missing input request identity")?;
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
    session.call(
        "input",
        &json!({"resource":resource,"resource_id":resource_id,
            "task_id":task_id,"request_id":request_id,
            "text":""}),
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

#[test]
fn debug_state_reads_a_historical_task_without_moving_the_live_execution() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(
        &mut session,
        "Algoritmo Probe\nDefinir value Como Entero <- 41;\nEscribir value + 1;\nFinAlgoritmo\n",
    )?;
    session.call(
        "debug_configure",
        &json!({"resource":resource,"breakpoints":[]}),
    );
    let live = session.call("advance", &json!({"resource":resource,"batch_size":64}));
    let horizon = session.call("horizon", &json!({"resource":resource}));
    let historical = session.call(
        "debug_state",
        &json!({"resource":resource,"event":0,"task_id":0,"start_frame":0,"frame_count":1}),
    );
    assert_eq!(
        historical.pointer("/value/event"),
        Some(&json!(0)),
        "{historical}"
    );
    assert_eq!(
        historical.pointer("/value/total_frames"),
        Some(&json!(1)),
        "{historical}"
    );
    assert_eq!(
        session.call("horizon", &json!({"resource":resource})),
        horizon
    );
    assert_eq!(
        session
            .call("advance", &json!({"resource":resource,"batch_size":1}))
            .pointer("/value/output"),
        live.pointer("/value/output")
    );
    let out_of_range = session.call(
        "debug_state",
        &json!({"resource":resource,"event":4097,"task_id":0}),
    );
    assert_eq!(
        out_of_range.pointer("/failure/family"),
        Some(&json!("usage"))
    );
    let missing_task = session.call("debug_state", &json!({"resource":resource,"event":0}));
    assert_eq!(
        missing_task.pointer("/failure/family"),
        Some(&json!("usage"))
    );
    Ok(())
}

#[test]
fn reconfiguring_an_existing_session_applies_stop_on_entry() -> Result<(), String> {
    let mut session = ApiSession::default();
    let resource = execution(&mut session, "Algoritmo Probe\nEscribir 1;\nFinAlgoritmo\n")?;
    for stop_on_entry in [false, true] {
        let configured = session.call(
            "debug_configure",
            &json!({"resource":resource,"stop_on_entry":stop_on_entry,"breakpoints":[]}),
        );
        assert!(configured.get("value").is_some(), "{configured}");
    }
    let first = pump(&mut session, &resource);
    assert_eq!(first.pointer("/value/debug/reason"), Some(&json!("entry")));
    Ok(())
}

#[test]
fn obsolete_generation_is_rejected_and_control_after_termination_is_not_busy() -> Result<(), String>
{
    let mut session = ApiSession::default();
    let resource = execution(&mut session, "Algoritmo Probe\nEscribir 1;\nFinAlgoritmo\n")?;
    session.call(
        "debug_configure",
        &json!({"resource":resource,"stop_on_entry":false,"breakpoints":[]}),
    );
    let obsolete = session.call(
        "debug_control",
        &json!({"resource":resource,"command":"continue","stop_generation":99}),
    );
    assert_eq!(
        obsolete.pointer("/failure/family"),
        Some(&json!("usage")),
        "{obsolete}"
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
    for _ in 0..2 {
        let again = session.call(
            "debug_control",
            &json!({"resource":resource,"command":"continue"}),
        );
        assert!(again.pointer("/failure").is_none(), "{again}");
    }
    Ok(())
}
