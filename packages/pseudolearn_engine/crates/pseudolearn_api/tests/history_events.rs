use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

#[test]
fn retained_event_windows_match_live_events_in_both_directions() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":"Algoritmo Probe\nEscribir 7;\nFinAlgoritmo\n"}),
    );
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource")}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or("resource")?;
    let live = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    let events = live
        .pointer("/value/events")
        .and_then(Value::as_array)
        .ok_or("events")?;
    let window = session.call(
        "history_events",
        &json!({"resource":resource,"start":0,"count":events.len()}),
    );
    let historical = window
        .pointer("/value/events")
        .and_then(Value::as_array)
        .ok_or("historical events")?;
    assert_eq!(historical.len(), events.len(), "{window}");
    for (live, retained) in events.iter().zip(historical) {
        let mut expected = live.clone();
        let actual_task = retained.get("task_id").and_then(Value::as_u64);
        assert_eq!(actual_task, Some(0), "{retained}");
        if let Some(fields) = expected.as_object_mut() {
            fields.insert("task_id".to_owned(), json!(0));
        }
        assert_eq!(&expected, retained, "{window}");
    }
    let reverse = session.call("history_events", &json!({"resource":resource,"start":events.len().saturating_sub(1),"count":events.len(),"direction":"backward"}));
    let reversed: Vec<_> = events
        .iter()
        .rev()
        .map(|event| {
            let mut expected = event.clone();
            if let Some(fields) = expected.as_object_mut() {
                fields.insert("task_id".to_owned(), json!(0));
            }
            expected
        })
        .collect();
    assert_eq!(
        reverse.pointer("/value/events"),
        Some(&json!(reversed)),
        "{reverse}"
    );
    let after = session.call("advance", &json!({"resource":resource,"batch_size":1}));
    assert_eq!(
        after.pointer("/value/output"),
        live.pointer("/value/output")
    );
    assert_eq!(
        after.pointer("/value/host_observation"),
        live.pointer("/value/host_observation")
    );
    Ok(())
}

#[test]
fn history_events_preserve_runtime_task_attribution() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":"SubProceso Suspendible Work()\nEscribir 7;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n"}),
    );
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"observe":"events"}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or("resource")?;
    let advanced = session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    let live_events = advanced
        .pointer("/value/events")
        .and_then(Value::as_array)
        .ok_or("live events")?;
    let retained = session.call(
        "history_events",
        &json!({"resource":resource,"start":0,"count":live_events.len()}),
    );
    let retained_events = retained
        .pointer("/value/events")
        .and_then(Value::as_array)
        .ok_or("retained events")?;
    assert_eq!(retained_events.len(), live_events.len());
    let child_statement = retained_events.iter().find(|event| {
        event.get("class").and_then(Value::as_str) == Some("statement_entered")
            && event.get("line").and_then(Value::as_u64) == Some(2)
    });
    assert_eq!(
        child_statement
            .and_then(|event| event.get("task_id"))
            .and_then(Value::as_u64),
        Some(1),
        "{retained}"
    );
    assert!(
        retained_events
            .iter()
            .all(|event| { event.get("task_id").and_then(Value::as_u64).is_some() })
    );
    Ok(())
}

#[test]
fn invalid_window_and_foreign_task_are_usage_errors() -> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = session.call(
        "create_analysis",
        &json!({"program":"Algoritmo Probe\nFinAlgoritmo\n"}),
    );
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource")}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or("resource")?;
    session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    for request in [
        json!({"resource":resource,"start":0,"count":4097}),
        json!({"resource":resource,"start":9999,"count":1}),
    ] {
        let response = session.call("history_events", &request);
        assert_eq!(
            response.pointer("/failure/family"),
            Some(&json!("usage")),
            "{response}"
        );
    }
    let foreign = session.call(
        "query_frame",
        &json!({"resource":resource,"event":0,"frame":0,"task_id":9999}),
    );
    assert_eq!(
        foreign.pointer("/failure/family"),
        Some(&json!("usage")),
        "{foreign}"
    );
    Ok(())
}
