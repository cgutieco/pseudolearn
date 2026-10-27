use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const CLOCK_THEN_READ: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable pending Como Entero <- 0;\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nLeer pending;\nEscribir pending;\nFinAlgoritmo\n";

struct Run {
    session: ApiSession,
    resource: Value,
}

fn start(limits: Value) -> Result<Run, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK_THEN_READ}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK_THEN_READ,
            "limits":limits,"host":{"permissions":["reloj"],"detached":true}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    Ok(Run { session, resource })
}

impl Run {
    fn call(&mut self, operation: &str, fields: Value) -> Value {
        let mut arguments = json!({"resource":self.resource});
        if let (Some(target), Some(extra)) = (arguments.as_object_mut(), fields.as_object()) {
            target.extend(extra.clone());
        }
        self.session.call(operation, &arguments)
    }

    fn advance(&mut self) -> Value {
        self.call("advance", json!({"batch_size":1000}))
    }

    fn reply(&mut self, sequence: u64, outcome: &str, value: Value) -> Value {
        self.call(
            "effect_result",
            json!({"effect_seq":sequence,"result":{"outcome":outcome,"value":value}}),
        )
    }

    fn resolve_clock(&mut self, instant: Value) -> Result<(), String> {
        let request = self.advance();
        let sequence = sequence_of(&request)?;
        let capability = request
            .pointer("/value/pending_effect/result_capability")
            .cloned()
            .ok_or_else(|| format!("no capability: {request}"))?;
        self.reply(sequence, "committed", json!({"kind":"capability","value":capability}));
        let now = self.advance();
        let sequence = sequence_of(&now)?;
        let accepted = match instant {
            Value::Number(_) => self.reply(sequence, "committed", json!({"kind":"integer","value":instant})),
            failure => self.reply(sequence, "failed", failure),
        };
        accepted.get("value").map(|_| ()).ok_or_else(|| format!("{accepted}"))
    }
}

fn sequence_of(response: &Value) -> Result<u64, String> {
    response
        .pointer("/value/termination/effect_seq")
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("no sequence: {response}"))
}

fn kind(response: &Value) -> Option<&str> {
    response.pointer("/value/termination/kind").and_then(Value::as_str)
}

#[test]
fn payload_carries_every_declared_field() -> Result<(), String> {
    let mut run = start(json!({}))?;
    let first = run.advance();
    let termination = first.pointer("/value/termination").cloned().unwrap_or(Value::Null);
    assert_eq!(termination.get("kind"), Some(&json!("awaiting_effect")), "{first}");
    assert_eq!(termination.get("effect_seq"), Some(&json!(1)));
    assert_eq!(termination.get("capability_kind"), Some(&json!("clock")));
    assert_eq!(termination.get("operation"), Some(&json!("request_clock")));
    assert_eq!(termination.get("arguments_summary"), Some(&json!("{\"count\":0}")));
    assert!(termination.get("source_node_id").is_some_and(Value::is_u64), "{termination}");
    Ok(())
}

#[test]
fn session_alternates_effect_and_input_suspensions() -> Result<(), String> {
    let mut run = start(json!({}))?;
    run.resolve_clock(json!(100))?;
    let waiting = run.advance();
    assert_eq!(kind(&waiting), Some("awaiting_input"), "{waiting}");
    assert!(waiting.pointer("/value/termination/effect_seq").is_none());
    let misplaced = run.reply(3, "committed", json!({"kind":"integer","value":1}));
    assert!(misplaced.get("failure").is_some(), "{misplaced}");
    assert!(run.call("input", json!({"text":"5"})).get("value").is_some());
    let done = run.advance();
    assert_eq!(kind(&done), Some("completed"), "{done}");
    assert_eq!(done.pointer("/value/output"), Some(&json!("100\n5\n")));
    Ok(())
}

#[test]
fn failed_reply_reaches_the_program_as_a_portable_error() -> Result<(), String> {
    let mut run = start(json!({}))?;
    run.resolve_clock(json!({"code":"no_encontrado","uncertain":false}))?;
    let waiting = run.advance();
    assert_eq!(kind(&waiting), Some("awaiting_input"), "{waiting}");
    assert_eq!(waiting.pointer("/value/output"), Some(&json!("no_encontrado\n")));
    Ok(())
}

#[test]
fn duplicated_reply_is_rejected_after_the_effect_resolved() -> Result<(), String> {
    let mut run = start(json!({}))?;
    let first = run.advance();
    let sequence = sequence_of(&first)?;
    let capability = first.pointer("/value/pending_effect/result_capability").cloned().unwrap_or(Value::Null);
    let body = json!({"kind":"capability","value":capability});
    assert!(run.reply(sequence, "committed", body.clone()).get("value").is_some());
    let duplicate = run.reply(sequence, "committed", body);
    assert!(duplicate.get("failure").is_some(), "{duplicate}");
    Ok(())
}

#[test]
fn cancellation_while_suspended_terminates_without_a_reply() -> Result<(), String> {
    let mut run = start(json!({}))?;
    let first = run.advance();
    let sequence = sequence_of(&first)?;
    run.call("cancel", json!({}));
    let after = run.advance();
    assert_eq!(kind(&after), Some("cancelled"), "{after}");
    assert!(after.get("value").and_then(|value| value.get("pending_effect")).is_none());
    assert_eq!(after.pointer("/value/effect_tape/status"), Some(&json!("incomplete")), "{after}");
    let late = run.reply(sequence, "committed", json!({"kind":"integer","value":1}));
    assert!(late.get("failure").is_some(), "{late}");
    Ok(())
}

#[test]
fn statement_limit_is_enforced_after_the_effect_resumes() -> Result<(), String> {
    let mut run = start(json!({"statements":2}))?;
    let mut outcome = Value::Null;
    for _ in 0..4 {
        outcome = run.advance();
        if kind(&outcome) != Some("awaiting_effect") {
            break;
        }
        let capability = outcome.pointer("/value/pending_effect/result_capability").cloned().unwrap_or(Value::Null);
        let sequence = sequence_of(&outcome)?;
        let body = if capability.is_null() { json!({"kind":"integer","value":1}) } else { json!({"kind":"capability","value":capability}) };
        run.reply(sequence, "committed", body);
    }
    assert_eq!(kind(&outcome), Some("limit_reached"), "{outcome}");
    assert_eq!(outcome.pointer("/value/host_observation/open_resources"), Some(&json!(0)));
    Ok(())
}

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn replay(mode: &str, tape: &Value) -> Value {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK,"profile":"es",
            "strictness":"strict","seed":42,"host":{"permissions":["reloj"],"detached":true},
            "execution_mode":mode,"effect_tape":tape}),
    );
    session.call(
        "advance",
        &json!({"resource":started.pointer("/value/resource"),"batch_size":1000}),
    )
}

#[test]
fn replay_and_seek_never_suspend_even_with_a_detached_host() -> Result<(), String> {
    let recording = ApiSession::default().call(
        "record",
        &json!({"request":{"program":CLOCK,"profile":"es","strictness":"strict","seed":42,
            "host":{"permissions":["reloj"],"clock":[100]}}}),
    );
    let tape = recording
        .pointer("/value/effect_tape")
        .cloned()
        .ok_or_else(|| format!("missing tape: {recording}"))?;
    for mode in ["replay_from_tape", "history_seek"] {
        let outcome = replay(mode, &tape);
        assert_eq!(kind(&outcome), Some("completed"), "{mode}: {outcome}");
        assert_eq!(outcome.pointer("/value/output"), Some(&json!("100\n")), "{mode}");
        assert_eq!(outcome.pointer("/value/host_observation/calls"), Some(&json!(0)), "{mode}");
    }
    Ok(())
}
