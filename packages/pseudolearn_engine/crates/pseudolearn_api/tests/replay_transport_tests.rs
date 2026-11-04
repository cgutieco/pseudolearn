use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn host() -> Value {
    json!({"detached":true})
}

fn start_replay(extra: Value) -> Value {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK}));
    let mut arguments = json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK,
        "profile":"es","seed":42,"host":host(),
        "execution_mode":"replay_from_tape"});
    if let (Some(fields), Some(more)) = (arguments.as_object_mut(), extra.as_object()) {
        fields.extend(more.clone());
    }
    session.call("start", &arguments)
}

fn live_tape() -> Result<Value, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK,"profile":"es",
            "seed":42,"host":host()}),
    );
    let resource = started.pointer("/value/resource").cloned();
    let waiting = session.call("advance", &json!({"resource":resource,"batch_size":64}));
    let sequence = waiting
        .pointer("/value/termination/effect_seq")
        .cloned()
        .ok_or_else(|| format!("no effect wait: {waiting}"))?;
    session.call(
        "effect_result",
        &json!({"resource":resource,"effect_seq":sequence,
            "result":{"outcome":"committed","value":{"kind":"capability","value":{"slot":0,"generation":1,"rights":4,"kind":4}}}}),
    );
    let done = session.call("advance", &json!({"resource":resource,"batch_size":64}));
    done.pointer("/value/effect_tape")
        .cloned()
        .ok_or_else(|| format!("missing tape: {done}"))
}

#[test]
fn replay_without_a_tape_is_a_usage_failure() {
    let response = start_replay(json!({}));
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn replay_with_an_unknown_tape_schema_is_a_version_failure() {
    let response = start_replay(json!({"effect_tape":{"format":"pseudolearn.tape/v0"}}));
    assert_eq!(response.pointer("/failure/family"), Some(&json!("version")));
}

#[test]
fn replay_with_a_tape_without_format_is_a_usage_failure() {
    let response = start_replay(json!({"effect_tape":{}}));
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn live_advance_carries_the_recorded_tape() -> Result<(), String> {
    let tape = live_tape()?;
    assert_eq!(
        tape.get("format"),
        Some(&json!("pseudolearn.tape/v1")),
        "{tape}"
    );
    Ok(())
}

#[test]
fn advancing_while_an_effect_is_pending_repeats_the_same_request_without_events()
-> Result<(), String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK,"profile":"es",
            "seed":42,"host":host(),"observe":"events"}),
    );
    let resource = started.pointer("/value/resource").cloned();
    let first = session.call("advance", &json!({"resource":resource,"batch_size":64}));
    let second = session.call("advance", &json!({"resource":resource,"batch_size":64}));
    assert_eq!(
        first.pointer("/value/termination"),
        second.pointer("/value/termination"),
        "{first} {second}"
    );
    assert_eq!(
        second.pointer("/value/events"),
        Some(&json!([])),
        "{second}"
    );
    assert_eq!(
        first.pointer("/value/pending_effect"),
        second.pointer("/value/pending_effect")
    );
    Ok(())
}

fn largest_integer(value: &Value) -> u64 {
    match value {
        Value::Number(number) => number.as_u64().unwrap_or(0),
        Value::Array(items) => items.iter().map(largest_integer).max().unwrap_or(0),
        Value::Object(fields) => fields.values().map(largest_integer).max().unwrap_or(0),
        _ => 0,
    }
}

#[test]
fn recorded_tape_has_no_integer_outside_the_signed_64_bit_range() -> Result<(), String> {
    let tape = live_tape()?;
    let largest = largest_integer(&tape);
    let ceiling = u64::try_from(i64::MAX).map_err(|error| error.to_string())?;
    assert!(largest <= ceiling, "{largest}: {tape}");
    Ok(())
}

#[test]
fn unlimited_budgets_are_absent_from_the_tape_identity() -> Result<(), String> {
    let tape = live_tape()?;
    let limits = tape
        .pointer("/identity/limits")
        .and_then(Value::as_object)
        .ok_or_else(|| format!("missing limits: {tape}"))?;
    assert!(!limits.contains_key("statements"), "{limits:?}");
    assert!(!limits.contains_key("micro_steps"), "{limits:?}");
    assert!(limits.contains_key("depth") && limits.contains_key("cells"));
    Ok(())
}
