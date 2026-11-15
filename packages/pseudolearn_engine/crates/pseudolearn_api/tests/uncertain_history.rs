use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const RENAMER: &str = "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"a\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir \"hecho\";\nError(problem): Si problem.Incierto Entonces Escribir \"incierto\"; Sino Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n";

fn request(fault: Value) -> Value {
    json!({
        "program": RENAMER,
        "profile": "es",
        "host": {"files": {"a": "x"}, "faults": [fault]},
    })
}

fn record(session: &mut ApiSession, request: Value) -> Value {
    session.call(
        "record",
        &json!({"request":request,"options":{"capture_states":true,"seek_every_event":true,"batch_size":1000}}),
    )
}

#[test]
fn every_event_after_an_uncertain_failure_stays_reachable() -> Result<(), String> {
    let mut session = ApiSession::default();
    let fault = json!({"operation":"directory_rename","code":"interrumpido","uncertain":true});
    let recorded = record(&mut session, request(fault));
    let value = recorded.get("value").ok_or_else(|| recorded.to_string())?;
    assert_eq!(value.get("output"), Some(&json!("incierto\n")));
    assert_eq!(
        value.pointer("/effect_tape/status"),
        Some(&json!("uncertain_external_state"))
    );
    Ok(())
}

#[test]
fn a_certain_failure_leaves_the_tape_reproducible() -> Result<(), String> {
    let mut session = ApiSession::default();
    let fault = json!({"operation":"directory_rename","code":"interrumpido","uncertain":false});
    let recorded = record(&mut session, request(fault));
    let value = recorded.get("value").ok_or_else(|| recorded.to_string())?;
    assert_eq!(value.get("output"), Some(&json!("cierto\n")));
    assert_ne!(
        value.pointer("/effect_tape/status"),
        Some(&json!("uncertain_external_state"))
    );
    Ok(())
}

#[test]
fn replaying_an_uncertain_tape_is_still_rejected() -> Result<(), String> {
    let mut session = ApiSession::default();
    let fault = json!({"operation":"directory_rename","code":"interrumpido","uncertain":true});
    let mut replay = request(fault.clone());
    let recorded = record(&mut session, request(fault));
    let tape = recorded
        .pointer("/value/effect_tape")
        .cloned()
        .ok_or_else(|| recorded.to_string())?;
    let fields = replay.as_object_mut().ok_or("request")?;
    fields.insert("execution_mode".to_owned(), json!("replay_from_tape"));
    fields.insert("effect_tape".to_owned(), tape);
    let outcome = session.call(
        "record",
        &json!({"request":replay,"options":{"capture_states":false,"batch_size":1000}}),
    );
    let detail = outcome
        .pointer("/failure/detail")
        .and_then(Value::as_str)
        .unwrap_or_default();
    assert!(detail.contains("replay_non_reproducible"), "{outcome}");
    Ok(())
}
