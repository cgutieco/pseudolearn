use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn start(session: &mut ApiSession, program: &str) -> Result<Value, String> {
    let analysis = session
        .call("create_analysis", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| "missing analysis".to_owned())?;
    let response = session.call("start", &json!({"analysis":analysis,"observe":"events"}));
    response.pointer("/value/resource").cloned().ok_or_else(|| {
        let diagnostic_response = session.call("analysis", &json!({"resource":analysis}));
        let diagnostics = diagnostic_response.pointer("/value/diagnostics");
        format!("missing execution: {response}; diagnostics: {diagnostics:?}")
    })
}

fn advance(session: &mut ApiSession, execution: &Value, size: u64) -> Value {
    session.call("advance", &json!({"resource":execution,"batch_size":size}))
}

fn advance_until_suspension(
    session: &mut ApiSession,
    execution: &Value,
    task_id: u64,
) -> Result<Vec<Value>, String> {
    let mut history = Vec::new();
    for _ in 0..64 {
        let response = advance(session, execution, 1);
        let batch_events = response
            .pointer("/value/events")
            .and_then(Value::as_array)
            .ok_or_else(|| "missing events".to_owned())?
            .clone();
        let suspended = batch_events.iter().any(|event| {
            event.pointer("/class") == Some(&json!("task_suspended"))
                && event.pointer("/data/task") == Some(&json!(task_id))
        });
        history.extend(batch_events);
        if suspended {
            return Ok(history);
        }
    }
    Err("task did not suspend".to_owned())
}

#[test]
fn task_id_reads_distinct_recursive_frames_for_sibling_tasks() -> Result<(), String> {
    let program = "SubProceso Recurse(value Como Entero, depth Como Entero)\nSi depth = 0 Entonces\nEscribir value;\nSiNo\nRecurse(value, depth - 1);\nFinSi\nFinSubProceso\nSubProceso Suspendible Work(value Como Entero)\nRecurse(value, 1);\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(7);\nLanzar Work(9);\nFinTareas\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let execution = start(&mut session, program)?;
    let trace = advance(&mut session, &execution, 4096);
    let events = trace
        .pointer("/value/events")
        .and_then(Value::as_array)
        .ok_or_else(|| "missing events".to_owned())?;
    let mut active_task = 0;
    let mut first_recursive_call = None;
    let mut second_recursive_call = None;
    for (event_index, event) in events.iter().enumerate() {
        if event.pointer("/class") == Some(&json!("task_resumed")) {
            active_task = event
                .pointer("/data/task")
                .and_then(Value::as_u64)
                .ok_or("missing resumed task")?;
        }
        if active_task == 1
            && event.pointer("/class") == Some(&json!("call"))
            && event.pointer("/data/nombre") == Some(&json!("Recurse"))
            && first_recursive_call.is_none()
        {
            first_recursive_call =
                Some(u64::try_from(event_index).map_err(|_| "event index overflow".to_owned())?);
        }
        if active_task == 2
            && event.pointer("/class") == Some(&json!("call"))
            && event.pointer("/data/nombre") == Some(&json!("Recurse"))
            && second_recursive_call.is_none()
        {
            second_recursive_call =
                Some(u64::try_from(event_index).map_err(|_| "event index overflow".to_owned())?);
        }
    }
    let first_event = first_recursive_call.ok_or_else(|| "task one did not recurse".to_owned())?;
    let second_event =
        second_recursive_call.ok_or_else(|| "task two did not recurse".to_owned())?;
    let mut read_value = |task_id, event, frame| {
        session.call(
            "query_frame",
            &json!({
                "resource":execution,
                "event":event,
                "frame":frame,
                "task_id":task_id
            }),
        )
    };
    let first = read_value(1, first_event, 2);
    let second = read_value(2, second_event, 2);
    assert_eq!(
        first.pointer("/value/variables/value/valor"),
        Some(&json!("7")),
        "{first}; {events:?}"
    );
    assert_eq!(
        second.pointer("/value/variables/value/valor"),
        Some(&json!("9")),
        "{second}"
    );
    assert_eq!(first.pointer("/failure/family"), None);
    assert_eq!(second.pointer("/failure/family"), None);
    Ok(())
}

#[test]
fn task_id_reads_a_suspended_child_without_changing_the_schedule() -> Result<(), String> {
    let program = "SubProceso Suspendible Consume(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir sent Como Logico <- Aguardar stream.Enviar(7);\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Consume(stream);\nLanzar Produce(stream);\nFinTareas\nFinAlgoritmo\n";
    let mut session = ApiSession::default();
    let execution = start(&mut session, program)?;
    let history = advance_until_suspension(&mut session, &execution, 1)?;
    let suspended_event = history
        .iter()
        .enumerate()
        .find(|(_, event)| {
            event.pointer("/class") == Some(&json!("task_suspended"))
                && event.pointer("/data/task") == Some(&json!(1))
        })
        .map(|(event_index, _)| {
            u64::try_from(event_index).map_err(|_| "event index overflow".to_owned())
        })
        .ok_or_else(|| "child one was not suspended".to_owned())??;
    let root = session.call(
        "query_frame",
        &json!({"resource":execution,"event":suspended_event,"frame":0,"task_id":0}),
    );
    let child = session.call(
        "query_frame",
        &json!({"resource":execution,"event":suspended_event,"frame":1,"task_id":1}),
    );
    assert_eq!(root.pointer("/failure/family"), None);
    assert_eq!(
        child.pointer("/value/unidad"),
        Some(&json!("Consume")),
        "{child}"
    );
    assert_eq!(child.pointer("/failure/family"), None);
    let next_after_query = advance(&mut session, &execution, 1);
    let mut control_session = ApiSession::default();
    let control_execution = start(&mut control_session, program)?;
    advance_until_suspension(&mut control_session, &control_execution, 1)?;
    let next_without_query = advance(&mut control_session, &control_execution, 1);
    assert_eq!(next_after_query, next_without_query);
    Ok(())
}

#[test]
fn old_event_state_is_stable_after_execution_advances() -> Result<(), String> {
    let mut session = ApiSession::default();
    let execution = start(
        &mut session,
        "Algoritmo Main\nDefinir value Como Entero <- 1;\nvalue <- 2;\nFinAlgoritmo\n",
    )?;
    advance(&mut session, &execution, 1);
    let request = json!({
        "resource":execution,
        "event":0,
        "frame":0,
        "task_id":0
    });
    let before = session.call("query_frame", &request);
    advance(&mut session, &execution, 4096);
    let after = session.call("query_frame", &request);
    assert_eq!(before, after);
    Ok(())
}

#[test]
fn task_selector_rejects_the_old_alias_and_malformed_id() -> Result<(), String> {
    let mut session = ApiSession::default();
    let execution = start(&mut session, "Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n")?;
    advance(&mut session, &execution, 1);
    for arguments in [
        json!({"resource":execution,"event":0,"frame":0,"task":0}),
        json!({"resource":execution,"event":0,"frame":0,"task_id":"0"}),
    ] {
        let rejected = session.call("query_frame", &arguments);
        assert_eq!(rejected.pointer("/failure/family"), Some(&json!("usage")));
    }
    let rejected_page = session.call(
        "query_page",
        &json!({
            "resource":execution,
            "query":"frame_variables",
            "target":0,
            "event":0,
            "page_size":1,
            "task":0
        }),
    );
    assert_eq!(
        rejected_page.pointer("/failure/family"),
        Some(&json!("usage"))
    );
    Ok(())
}
