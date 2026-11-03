use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Suspendible Fetch(net Como RedCap) Como Resultado<Entero, Cadena>\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, \"http://127.0.0.1:1/\")) Hacer\nExito(response): Escribir response.Estado(); Retornar Exito(response.Estado());\nError(problem): Retornar Error(problem.Codigo);\nFinSegun\nFinSubProceso\nSubProceso Suspendible Wait()\nSegun Aguardar SolicitarTemporizador() Hacer\nExito(timer):\nSegun Aguardar timer.Esperar(50000000) Hacer\nExito(instant): Escribir \"timer\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Work()\nEscribir \"sibling\";\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas report\nLanzar Fetch(net);\nLanzar Wait();\nLanzar Work();\nFinTareas\nSegun report Hacer\nNada: Escribir \"done\";\nAlgo(problem): Escribir \"task_error\";\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn answer(effect: &Value) -> Value {
    if let Some(capability) = effect
        .get("result_capability")
        .filter(|value| !value.is_null())
    {
        return json!({"outcome":"committed","value":{"kind":"capability","value":capability}});
    }
    match effect.get("operation").and_then(Value::as_str) {
        Some("network_send") => json!({"outcome":"committed","value":{"kind":"http_response",
            "value":{"status":200,"headers":[],"body":[],"final_url":"http://127.0.0.1:1/"}}}),
        _ => json!({"outcome":"committed","value":{"kind":"integer","value":1_000_000_000}}),
    }
}

fn pending(response: &Value) -> Vec<Value> {
    let mut effects: Vec<Value> = response
        .pointer("/value/pending_effects")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    if let Some(single) = response.pointer("/value/pending_effect")
        && effects.is_empty()
    {
        effects.push(single.clone());
    }
    effects
}

fn inspect_live_run(program: &str, reverse: bool) -> Result<(), String> {
    inspect_staged_run(program, reverse, false)
}

fn inspect_staged_run(program: &str, reverse: bool, staged: bool) -> Result<(), String> {
    let mut timer_answered = false;
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,
            "host":{"detached":true}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    let mut last = Value::Null;
    let mut delivered: Vec<Value> = Vec::new();
    for _ in 0..200 {
        last = session.call("advance", &json!({"resource":resource,"batch_size":25}));
        let events = last
            .pointer("/value/events")
            .and_then(Value::as_array)
            .cloned()
            .unwrap_or_default();
        delivered.extend(events);
        if last.pointer("/value/termination/kind") == Some(&json!("completed")) {
            break;
        }
        let mut effects = pending(&last);
        if reverse {
            effects.reverse();
        }
        for effect in effects {
            let operation = effect.get("operation").and_then(Value::as_str).unwrap_or("");
            if staged && operation == "network_send" && !timer_answered {
                continue;
            }
            if operation == "timer_wait" {
                timer_answered = true;
            }
            let result = answer(&effect);
            let delivered = session.call(
                "effect_result",
                &json!({"resource":resource,"effect_seq":effect.get("effect_seq"),"result":result}),
            );
            if delivered.get("value").is_none() {
                return Err(format!("rejected: {delivered}"));
            }
        }
    }
    assert_eq!(
        last.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{last}"
    );
    let total = u64::try_from(delivered.len()).map_err(|error| error.to_string())?;
    if std::env::var("GRID").is_ok() {
        for (index, event) in delivered.iter().enumerate() {
            eprintln!("EVT {index} {} task={}", event["class"], event["task_id"]);
        }
    }
    let window = session.call(
        "history_events",
        &json!({"resource":resource,"start":0,"count":total}),
    );
    let replayed = window
        .pointer("/value/events")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| format!("missing window: {window}"))?;
    assert_eq!(replayed.len(), delivered.len());
    for (index, (live, historic)) in delivered.iter().zip(&replayed).enumerate() {
        assert_eq!(
            live.get("class"),
            historic.get("class"),
            "event {index}: {live} vs {historic}"
        );
    }
    let mut lifetimes = std::collections::BTreeMap::new();
    for (index, event) in delivered.iter().enumerate() {
        let index = u64::try_from(index).map_err(|error| error.to_string())?;
        let task = event.pointer("/data/task").and_then(Value::as_u64);
        match (event.get("class").and_then(Value::as_str), task) {
            (Some("task_ready"), Some(task)) => {
                lifetimes.entry(task).or_insert((index, u64::MAX));
            }
            (Some("task_completed"), Some(task)) => {
                if let Some(entry) = lifetimes.get_mut(&task) {
                    entry.1 = index;
                }
            }
            _ => {}
        }
    }
    for event in 0..total {
        for task in 0..4 {
            let frame = session.call(
                "query_frame",
                &json!({"resource":resource,"event":event,"frame":0,"task_id":task}),
            );
            let message = frame.to_string();
            if std::env::var("GRID").is_ok() {
                eprintln!("GRID {event} {task} {}", if message.contains("invalid task") { "X" } else { "." });
            }
            assert!(
                !message.contains("unreachable event"),
                "event {event} task {task}: {message}"
            );
        }
    }
    Ok(())
}

const TWO_FETCHES: &str = "SubProceso Suspendible Fetch(label Como Cadena, net Como RedCap, path Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, \"http://127.0.0.1:1\" + path)) Hacer\nExito(response): Escribir label;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(\"slow\", net, \"/slow\");\nLanzar Fetch(\"fast\", net, \"/fast\");\nFinTareas\nEscribir \"done\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

#[test]
fn every_event_of_a_live_run_with_pending_effects_is_queryable() -> Result<(), String> {
    inspect_live_run(PROGRAM, false)
}

#[test]
fn results_delivered_in_reverse_request_order_stay_queryable() -> Result<(), String> {
    inspect_live_run(TWO_FETCHES, true)
}

const NO_EFFECTS: &str = "SubProceso Suspendible Work()\nEscribir \"sibling\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nEscribir \"done\";\nFinAlgoritmo\n";

#[test]
fn zz_no_effects_grid() -> Result<(), String> {
    inspect_live_run(NO_EFFECTS, false)
}

#[test]
fn a_task_finishing_while_another_effect_is_pending_stays_queryable() -> Result<(), String> {
    inspect_staged_run(PROGRAM, false, true)
}
