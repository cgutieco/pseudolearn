use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir writer Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"escritura\");\nDescartar writer.EscribirTexto(\"dato\");\nDescartar writer.Cerrar();\nDefinir reader Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura\");\nDefinir text Como Cadena <- Propagar reader.LeerTexto();\nEscribir text;\nRetornar Exito(text);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const HTTP_PROGRAM: &str = "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/write\")) Hacer\nExito(response): Escribir response.Estado;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

struct Finished {
    session: ApiSession,
    resource: Value,
    last: Value,
}

fn run_to_end(program: &str, host: Value) -> Result<Finished, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,
            "profile":"es","strictness":"strict","seed":42,"host":host}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    let mut last = Value::Null;
    for _ in 0..400 {
        last = session.call("advance", &json!({"resource":resource,"batch_size":1}));
        if last.pointer("/value/termination/kind") == Some(&json!("completed")) {
            return Ok(Finished {
                session,
                resource,
                last,
            });
        }
    }
    Err(format!("did not complete: {last}"))
}

fn file_host() -> Value {
    json!({"files":{"n":""}})
}

fn http_host() -> Value {
    json!({
        "http":{"POST https://fake.test/write":{"estado":201}}})
}

fn calls(response: &Value) -> Option<u64> {
    response
        .pointer("/value/host_observation/calls")
        .and_then(Value::as_u64)
}

fn horizon_end(finished: &mut Finished) -> Result<u64, String> {
    let horizon = finished
        .session
        .call("horizon", &json!({"resource":finished.resource}));
    horizon
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("missing horizon: {horizon}"))
}

fn inspect_whole_history(finished: &mut Finished) -> Result<(), String> {
    let last = horizon_end(finished)?;
    let resource = finished.resource.clone();
    for event in (0..=last).chain((0..=last).rev()) {
        let state = finished
            .session
            .call("query_state", &json!({"resource":resource,"event":event}));
        assert!(state.get("failure").is_none(), "{state}");
        finished.session.call(
            "history_events",
            &json!({"resource":resource,"from":0,"count":8}),
        );
    }
    Ok(())
}

fn assert_isolated(program: &str, host: Value) -> Result<(), String> {
    let mut finished = run_to_end(program, host)?;
    let before_calls = calls(&finished.last).ok_or("missing host observation")?;
    assert!(before_calls > 0, "{}", finished.last);
    let before_output = finished.last.pointer("/value/output").cloned();
    let before_tape = finished.last.pointer("/value/effect_tape").cloned();
    inspect_whole_history(&mut finished)?;
    let after = finished.session.call(
        "advance",
        &json!({"resource":finished.resource,"batch_size":1}),
    );
    assert_eq!(calls(&after), Some(before_calls), "{after}");
    assert_eq!(after.pointer("/value/output").cloned(), before_output);
    assert_eq!(after.pointer("/value/effect_tape").cloned(), before_tape);
    assert_ne!(
        after.pointer("/value/termination/kind"),
        Some(&json!("failed")),
        "{after}"
    );
    Ok(())
}

#[test]
fn history_queries_do_not_repeat_file_writes_or_change_output_and_tape() -> Result<(), String> {
    assert_isolated(PROGRAM, file_host())
}

#[test]
fn history_queries_do_not_repeat_http_posts_or_change_output_and_tape() -> Result<(), String> {
    assert_isolated(HTTP_PROGRAM, http_host())
}

#[test]
fn rejected_history_queries_leave_the_host_counter_untouched() -> Result<(), String> {
    let mut finished = run_to_end(PROGRAM, file_host())?;
    let before = calls(&finished.last).ok_or("missing host observation")?;
    let rejected = finished.session.call(
        "query_state",
        &json!({"resource":finished.resource,"event":u32::MAX}),
    );
    assert!(rejected.get("failure").is_some(), "{rejected}");
    let after = finished.session.call(
        "advance",
        &json!({"resource":finished.resource,"batch_size":1}),
    );
    assert_eq!(calls(&after), Some(before), "{after}");
    Ok(())
}
