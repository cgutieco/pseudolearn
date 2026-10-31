use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn call(session: &mut ApiSession, operation: &str, arguments: &Value) -> Result<Value, String> {
    let response = session.call(operation, arguments);
    response
        .get("value")
        .cloned()
        .ok_or_else(|| response.to_string())
}

fn launch(program: &str, line: u64) -> Result<(ApiSession, Value), String> {
    let mut session = ApiSession::default();
    let analysis = call(&mut session, "create_analysis", &json!({"program":program}))?;
    let execution = call(
        &mut session,
        "start",
        &json!({"analysis":analysis.get("resource"),"observe":"events"}),
    )?;
    let resource = execution
        .get("resource")
        .cloned()
        .ok_or("missing execution")?;
    call(
        &mut session,
        "debug_configure",
        &json!({"resource":resource,"stop_on_entry":false,
        "breakpoints":[{"source_id":0,"line":line}]}),
    )?;
    call(
        &mut session,
        "debug_control",
        &json!({"resource":resource,"command":"continue"}),
    )?;
    stop(&mut session, &resource)?;
    Ok((session, resource))
}

fn stop(session: &mut ApiSession, resource: &Value) -> Result<Value, String> {
    for _ in 0..1000 {
        let batch = call(
            session,
            "advance",
            &json!({"resource":resource,"batch_size":7}),
        )?;
        if batch.pointer("/debug/stopped").and_then(Value::as_bool) == Some(true) {
            return batch
                .get("debug")
                .cloned()
                .ok_or("missing debug state".to_owned());
        }
        if batch.pointer("/termination/kind").and_then(Value::as_str) != Some("running") {
            return Err(format!(
                "execution terminated before debug predicate: {batch}"
            ));
        }
    }
    Err("debug predicate did not settle within the test budget".to_owned())
}

#[test]
fn step_out_stops_at_the_selected_return_before_the_caller_returns() -> Result<(), String> {
    let program = "SubProceso Inner(number Como Entero) Como Entero\nRetornar number + 1;\nFinSubProceso\nSubProceso Outer() Como Entero\nRetornar Inner(4);\nFinSubProceso\nAlgoritmo Main\nEscribir Outer();\nFinAlgoritmo\n";
    let (mut session, resource) = launch(program, 2)?;
    let before = call(&mut session, "debug_state", &json!({"resource":resource}))?;
    assert_eq!(
        before.pointer("/frames/0/name").and_then(Value::as_str),
        Some("Inner")
    );
    call(
        &mut session,
        "debug_control",
        &json!({"resource":resource,"command":"step_out","task_id":0}),
    )?;
    let after = stop(&mut session, &resource)?;
    assert_eq!(after.get("reason"), Some(&json!("step")));
    assert_eq!(
        after.pointer("/frames/0/name").and_then(Value::as_str),
        Some("Outer")
    );
    assert_eq!(
        after.pointer("/source/class").and_then(Value::as_str),
        Some("return")
    );
    assert_eq!(after.get("output"), Some(&json!("")));
    Ok(())
}

#[test]
fn a_selected_task_finishing_stops_before_other_tasks_keep_running() -> Result<(), String> {
    let program = "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nFinAlgoritmo\n";
    let (mut session, resource) = launch(program, 2)?;
    let before = call(&mut session, "debug_state", &json!({"resource":resource}))?;
    let task = before
        .get("task_id")
        .and_then(Value::as_u64)
        .ok_or("missing selected task")?;
    assert_ne!(task, 0);
    call(
        &mut session,
        "debug_control",
        &json!({"resource":resource,"command":"step_out","task_id":task}),
    )?;
    let after = stop(&mut session, &resource)?;
    assert_eq!(after.get("reason"), Some(&json!("task_terminated")));
    assert_eq!(after.get("total_frames"), Some(&json!(0)));
    assert_eq!(after.get("output"), Some(&json!("1\n")));
    assert!(
        after
            .get("frames")
            .and_then(Value::as_array)
            .is_some_and(Vec::is_empty)
    );
    Ok(())
}
