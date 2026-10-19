use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn run(program: &str) -> Result<Vec<Value>, String> {
    let mut session = ApiSession::default();
    let analysis = session
        .call("create_analysis", &json!({"program":program}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing analysis")?;
    let started = session
        .call("start", &json!({"analysis":analysis}))
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing execution")?;
    let advanced = session.call("advance", &json!({"resource":started,"batch_size":4096}));
    advanced
        .pointer("/value/events")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing events".to_owned())
}

fn entered_nodes(events: &[Value]) -> Vec<Value> {
    events
        .iter()
        .filter(|event| event.get("class") == Some(&json!("statement_entered")))
        .filter_map(|event| event.pointer("/source/node_id").cloned())
        .collect()
}

#[test]
fn statements_sharing_a_line_have_distinct_node_identities() -> Result<(), String> {
    let events = run("Algoritmo P\nDefinir x Como Entero;\nx <- 1; x <- 2;\nFinAlgoritmo\n")?;
    let nodes = entered_nodes(&events);
    assert_eq!(nodes.len(), 3);
    assert_ne!(nodes.get(1), nodes.get(2));
    Ok(())
}

#[test]
fn entered_and_exited_events_of_one_statement_share_identity() -> Result<(), String> {
    let events = run("Algoritmo P\nEscribir \"a\";\nFinAlgoritmo\n")?;
    let entered = events
        .iter()
        .find(|event| event.get("class") == Some(&json!("statement_entered")))
        .and_then(|event| event.pointer("/source"))
        .ok_or("missing entered source")?;
    let exited = events
        .iter()
        .find(|event| event.get("class") == Some(&json!("statement_exited")))
        .and_then(|event| event.pointer("/source"))
        .ok_or("missing exited source")?;
    assert_eq!(entered, exited);
    assert!(entered.get("revision_id").is_some());
    assert_eq!(entered.pointer("/span/start/line"), Some(&json!(2)));
    Ok(())
}

#[test]
fn every_event_of_a_loop_resolves_to_a_node() -> Result<(), String> {
    let events = run(
        "Algoritmo P\nDefinir i Como Entero;\nPara i <- 1 Hasta 3 Con Paso 1 Hacer\nEscribir i;\nFinPara\nFinAlgoritmo\n",
    )?;
    assert!(!events.is_empty());
    for event in &events {
        assert!(
            event.pointer("/source/node_id").is_some(),
            "event without source: {event}"
        );
    }
    Ok(())
}
