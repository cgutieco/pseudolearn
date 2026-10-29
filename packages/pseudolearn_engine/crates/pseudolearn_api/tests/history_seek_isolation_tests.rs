use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir left Como Cadena <- Propagar file.LeerTexto();\nEscribir left;\nDefinir second Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir right Como Cadena <- Propagar second.LeerTexto();\nRetornar Exito(left + right);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn finished_session() -> Result<(ApiSession, Value, Value), String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":PROGRAM}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":PROGRAM,"profile":"es",
            "strictness":"strict","seed":42,
            "host":{"permissions":["archivos_lectura"],"files":{"a":"hola","b":"mundo"}}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing resource")?;
    let finished = session.call("advance", &json!({"resource":resource,"batch_size":1}));
    let mut last = finished;
    for _ in 0..200 {
        if last.pointer("/value/termination/kind") == Some(&json!("completed")) {
            break;
        }
        last = session.call("advance", &json!({"resource":resource,"batch_size":1}));
    }
    Ok((session, resource, last))
}

fn host_calls(response: &Value) -> Option<u64> {
    response
        .pointer("/value/host_observation/calls")
        .and_then(Value::as_u64)
}

fn states(session: &mut ApiSession, resource: &Value, events: &[u64]) -> Vec<Value> {
    events
        .iter()
        .map(|event| session.call("query_state", &json!({"resource":resource,"event":event})))
        .collect()
}

#[test]
fn seeking_forward_and_backward_never_calls_the_host_again() -> Result<(), String> {
    let (mut session, resource, finished) = finished_session()?;
    let calls = host_calls(&finished).ok_or("missing host observation")?;
    assert!(calls > 0, "{finished}");
    let horizon = session.call("horizon", &json!({"resource":resource}));
    let first = horizon
        .pointer("/value/first")
        .and_then(Value::as_u64)
        .ok_or("first")?;
    let last = horizon
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or("last")?;
    assert!(last > first);
    let forward: Vec<u64> = (first..=last).collect();
    let backward: Vec<u64> = forward.iter().rev().copied().collect();
    let ascending = states(&mut session, &resource, &forward);
    let mut descending = states(&mut session, &resource, &backward);
    descending.reverse();
    assert!(
        ascending.iter().all(|state| state.get("value").is_some()),
        "{ascending:?}"
    );
    assert_eq!(ascending, descending);
    let after = session.call("advance", &json!({"resource":resource,"batch_size":1}));
    assert_eq!(host_calls(&after), Some(calls), "{after}");
    Ok(())
}

#[test]
fn seeking_past_the_horizon_is_a_usage_error_and_keeps_the_host_untouched() -> Result<(), String> {
    let (mut session, resource, finished) = finished_session()?;
    let calls = host_calls(&finished);
    let beyond = session.call(
        "query_state",
        &json!({"resource":resource,"event":1_000_000}),
    );
    assert_eq!(
        beyond.pointer("/failure/family"),
        Some(&json!("usage")),
        "{beyond}"
    );
    let after = session.call("advance", &json!({"resource":resource,"batch_size":1}));
    assert_eq!(host_calls(&after), calls);
    Ok(())
}
