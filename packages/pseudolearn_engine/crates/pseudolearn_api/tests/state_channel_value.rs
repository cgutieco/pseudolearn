use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PIPELINE: &str = "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(1);\nDefinir secondAccepted Como Logico <- Aguardar stream.Enviar(2);\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Entero>)\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Salir;\nFinSegun\nHasta Que Falso\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Produce(stream);\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n";

fn finished_run(program: &str) -> Result<(ApiSession, Value, u64), String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let analysis = analysis
        .pointer("/value/resource")
        .ok_or("missing analysis")?
        .clone();
    let started = session.call("start", &json!({"analysis":analysis}));
    let resource = started
        .pointer("/value/resource")
        .ok_or("missing execution")?
        .clone();
    session.call("advance", &json!({"resource":resource,"batch_size":4096}));
    let horizon = session.call("horizon", &json!({"resource":resource}));
    let last = horizon
        .pointer("/value/last")
        .and_then(Value::as_u64)
        .ok_or("missing horizon")?;
    Ok((session, resource, last))
}

fn frames(session: &mut ApiSession, resource: &Value, event: u64) -> Vec<Value> {
    let state = session.call("query_state", &json!({"resource":resource,"event":event}));
    state
        .pointer("/value/marcos")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default()
}

fn channels_at(session: &mut ApiSession, resource: &Value, event: u64) -> Vec<Value> {
    frames(session, resource, event)
        .iter()
        .filter_map(|frame| frame.pointer("/variables/stream").cloned())
        .collect()
}

#[test]
fn a_channel_parameter_is_published_as_one_value_with_its_state() -> Result<(), String> {
    let (mut session, resource, last) = finished_run(PIPELINE)?;
    let mut opened = false;
    let mut closed = false;
    let mut queued = false;
    for event in 0..=last {
        for frame in frames(&mut session, &resource, event) {
            let variables = frame.get("variables").and_then(Value::as_object);
            let names: Vec<&String> = variables
                .map(|map| map.keys().collect())
                .unwrap_or_default();
            assert!(
                names.iter().all(|name| !name.ends_with(".identity")),
                "event {event}: {names:?}"
            );
        }
        for channel in channels_at(&mut session, &resource, event) {
            let state = channel
                .get("canal")
                .ok_or(format!("not a channel: {channel}"))?;
            assert_eq!(state.get("identidad"), Some(&json!(1)));
            assert_eq!(state.get("capacidad"), Some(&json!(1)));
            let waiting = state
                .get("en_cola")
                .and_then(Value::as_u64)
                .ok_or("en_cola")?;
            assert!(waiting <= 1, "{state}");
            queued |= waiting == 1;
            match state.get("abierto") {
                Some(Value::Bool(true)) => opened = true,
                Some(Value::Bool(false)) => closed = true,
                other => return Err(format!("abierto missing: {other:?}")),
            }
        }
    }
    assert!(opened, "the channel is open before it is closed");
    assert!(closed, "the channel is reported closed after Cerrar");
    assert!(
        queued,
        "a value waits in the buffer between send and receive"
    );
    Ok(())
}

#[test]
fn a_program_without_channels_publishes_no_channel_value() -> Result<(), String> {
    let (mut session, resource, last) =
        finished_run("Algoritmo P\nDefinir n Como Entero <- 1;\nFinAlgoritmo\n")?;
    for event in 0..=last {
        let state = session.call("query_state", &json!({"resource":resource,"event":event}));
        assert!(!state.to_string().contains("canal"), "{state}");
    }
    Ok(())
}
