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
    let mut session = ApiSession::default();
    let resource = start_live_execution(&mut session, program)?;
    let settings = RunSettings {
        reverse,
        staged,
        timer_answered: false,
    };
    let (last, delivered) = advance_live_execution(&mut session, &resource, settings)?;
    verify_live_history(&mut session, &resource, &delivered)?;
    verify_event_queries(&mut session, &resource, delivered.len())?;
    assert_eq!(
        last.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{last}"
    );
    Ok(())
}

fn start_live_execution(session: &mut ApiSession, program: &str) -> Result<Value, String> {
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
    Ok(resource)
}

struct RunSettings {
    reverse: bool,
    staged: bool,
    timer_answered: bool,
}

fn advance_live_execution(
    session: &mut ApiSession,
    resource: &Value,
    mut settings: RunSettings,
) -> Result<(Value, Vec<Value>), String> {
    let mut last = Value::Null;
    let mut delivered = Vec::new();
    for _ in 0..200 {
        last = session.call("advance", &json!({"resource":resource,"batch_size":25}));
        delivered.extend(event_batch(&last));
        if last.pointer("/value/termination/kind") == Some(&json!("completed")) {
            break;
        }
        deliver_pending_effects(session, resource, &last, &mut settings)?;
    }
    assert_eq!(
        last.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{last}"
    );
    Ok((last, delivered))
}

fn event_batch(response: &Value) -> Vec<Value> {
    response
        .pointer("/value/events")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default()
}

fn deliver_pending_effects(
    session: &mut ApiSession,
    resource: &Value,
    response: &Value,
    settings: &mut RunSettings,
) -> Result<(), String> {
    let mut effects = pending(response);
    if settings.reverse {
        effects.reverse();
    }
    for effect in effects {
        let operation = effect
            .get("operation")
            .and_then(Value::as_str)
            .unwrap_or("");
        if settings.staged && operation == "network_send" && !settings.timer_answered {
            continue;
        }
        if operation == "timer_wait" {
            settings.timer_answered = true;
        }
        deliver_effect(session, resource, &effect)?;
    }
    Ok(())
}

fn deliver_effect(
    session: &mut ApiSession,
    resource: &Value,
    effect: &Value,
) -> Result<(), String> {
    let result = answer(effect);
    let response = session.call(
        "effect_result",
        &json!({"resource":resource,"effect_seq":effect.get("effect_seq"),"result":result}),
    );
    if response.get("value").is_none() {
        return Err(format!("rejected: {response}"));
    }
    Ok(())
}

fn verify_live_history(
    session: &mut ApiSession,
    resource: &Value,
    delivered: &[Value],
) -> Result<(), String> {
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
    Ok(())
}

fn verify_event_queries(
    session: &mut ApiSession,
    resource: &Value,
    event_count: usize,
) -> Result<(), String> {
    let total = u64::try_from(event_count).map_err(|error| error.to_string())?;
    for event in 0..total {
        for task in 0..4 {
            let frame = session.call(
                "query_frame",
                &json!({"resource":resource,"event":event,"frame":0,"task_id":task}),
            );
            let message = frame.to_string();
            if std::env::var("GRID").is_ok() {
                print_query_grid(event, task, &message);
            }
            assert!(
                !message.contains("unreachable event"),
                "event {event} task {task}: {message}"
            );
        }
    }
    Ok(())
}

fn print_query_grid(event: u64, task: u64, message: &str) {
    let result = if message.contains("invalid task") {
        "X"
    } else {
        "."
    };
    eprintln!("GRID {event} {task} {result}");
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
