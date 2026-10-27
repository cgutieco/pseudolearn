use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const WRITER: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"escritura\");\nRetornar file.EscribirTexto(\"x\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n";

struct Run {
    session: ApiSession,
    resource: Value,
}

fn start(program: &str, permissions: &[&str]) -> Result<Run, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,
            "host":{"permissions":permissions,"detached":true}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    Ok(Run { session, resource })
}

impl Run {
    fn advance(&mut self) -> Value {
        self.session.call(
            "advance",
            &json!({"resource":self.resource,"batch_size":1000}),
        )
    }

    fn feed(&mut self, operation: &str, fields: Value) -> Value {
        let mut arguments = json!({"resource":self.resource});
        if let (Some(target), Some(extra)) = (arguments.as_object_mut(), fields.as_object()) {
            target.extend(extra.clone());
        }
        self.session.call(operation, &arguments)
    }

    fn reply(&mut self, sequence: &Value, result: Value) -> Value {
        self.feed("effect_result", json!({"effect_seq":sequence,"result":result}))
    }
}

fn kind(response: &Value) -> Option<&str> {
    response.pointer("/value/termination/kind").and_then(Value::as_str)
}

fn pending(response: &Value) -> Result<(Value, Value), String> {
    let sequence = response
        .pointer("/value/termination/effect_seq")
        .cloned()
        .ok_or_else(|| format!("no sequence: {response}"))?;
    let capability = response
        .pointer("/value/pending_effect/result_capability")
        .cloned()
        .unwrap_or(Value::Null);
    Ok((sequence, capability))
}

fn committed(kind: &str, value: Value) -> Value {
    json!({"outcome":"committed","value":{"kind":kind,"value":value}})
}

#[test]
fn clock_request_suspends_with_the_effect_payload() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    assert_eq!(kind(&first), Some("awaiting_effect"), "{first}");
    assert_eq!(first.pointer("/value/termination/operation"), Some(&json!("request_clock")));
    assert_eq!(first.pointer("/value/termination/effect_seq"), Some(&json!(1)));
    Ok(())
}

#[test]
fn manual_resolution_completes_the_program() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    let (sequence, capability) = pending(&first)?;
    let accepted = run.reply(&sequence, committed("capability", capability));
    assert!(accepted.get("value").is_some(), "{accepted}");
    let second = run.advance();
    assert_eq!(second.pointer("/value/termination/operation"), Some(&json!("clock_now")));
    let (next, _) = pending(&second)?;
    run.reply(&next, committed("integer", json!(100)));
    let done = run.advance();
    assert_eq!(kind(&done), Some("completed"), "{done}");
    assert_eq!(done.pointer("/value/output"), Some(&json!("100\n")));
    Ok(())
}

#[test]
fn input_is_rejected_while_an_effect_is_pending() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    run.advance();
    let rejected = run.feed("input", json!({"text":"x"}));
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}

#[test]
fn wrong_sequence_is_rejected_and_the_effect_stays_pending() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    let (_, capability) = pending(&first)?;
    let rejected = run.reply(&json!(99), committed("capability", capability.clone()));
    assert!(rejected.get("failure").is_some(), "{rejected}");
    let (sequence, _) = pending(&first)?;
    assert!(run.reply(&sequence, committed("capability", capability)).get("value").is_some());
    Ok(())
}

#[test]
fn wrong_result_type_is_rejected() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    let (sequence, _) = pending(&first)?;
    let rejected = run.reply(&sequence, committed("integer", json!(7)));
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}

#[test]
fn result_without_a_pending_effect_is_rejected() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let rejected = run.reply(&json!(1), committed("integer", json!(7)));
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}

#[test]
fn cancellation_while_pending_rejects_later_results() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    let (sequence, capability) = pending(&first)?;
    run.feed("cancel", json!({}));
    let after = run.reply(&sequence, committed("capability", capability));
    let advanced = run.advance();
    assert!(after.get("failure").is_some(), "{after}");
    assert_eq!(kind(&advanced), Some("cancelled"), "{advanced}");
    Ok(())
}

#[test]
fn read_only_effect_cannot_be_reported_as_uncertain() -> Result<(), String> {
    let mut run = start(CLOCK, &["reloj"])?;
    let first = run.advance();
    let (sequence, capability) = pending(&first)?;
    run.reply(&sequence, committed("capability", capability));
    let second = run.advance();
    let (next, _) = pending(&second)?;
    let uncertain = json!({"outcome":"uncertain","value":{"code":"interrumpido","uncertain":true}});
    let rejected = run.reply(&next, uncertain);
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}

#[test]
fn uncertain_write_is_visible_to_the_program_and_marks_the_tape() -> Result<(), String> {
    let mut run = start(WRITER, &["archivos_escritura"])?;
    for (kind_name, _) in [("capability", 0), ("capability", 1)] {
        let step = run.advance();
        let (sequence, capability) = pending(&step)?;
        run.reply(&sequence, committed(kind_name, capability));
    }
    let write = run.advance();
    assert_eq!(write.pointer("/value/termination/operation"), Some(&json!("file_write_text")));
    let (sequence, _) = pending(&write)?;
    let uncertain = json!({"outcome":"uncertain","value":{"code":"interrumpido","uncertain":true}});
    assert!(run.reply(&sequence, uncertain).get("value").is_some());
    let done = run.advance();
    assert_eq!(kind(&done), Some("completed"), "{done}");
    assert_eq!(done.pointer("/value/output"), Some(&json!("incierto\n")));
    assert_eq!(done.pointer("/value/effect_tape/status"), Some(&json!("uncertain_external_state")));
    Ok(())
}
