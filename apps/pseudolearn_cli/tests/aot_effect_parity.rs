#![forbid(unsafe_code)]

use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::io::Write;
use std::process::{Command, Stdio};

const CLOCK_PROGRAM: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn host() -> Value {
    json!({"permissions":["reloj"],"requested_permissions":["reloj"],"clock":[100,200]})
}

fn request(extra: &Value) -> Result<Value, String> {
    let mut base = json!({"kind":"execute","program":CLOCK_PROGRAM,"profile":"es","strictness":"strict",
        "inputs":[],"seed":42,"observe":"none","limits":{"micro_steps":100_000},"host":host()});
    let fields = base.as_object_mut().ok_or("request is not an object")?;
    for (key, value) in extra.as_object().ok_or("extra is not an object")? {
        fields.insert(key.clone(), value.clone());
    }
    Ok(base)
}

fn engine(request: &Value) -> Result<Value, String> {
    let response = ApiSession::default().call(
        "record",
        &json!({"request":request,"options":{"capture_states":false,"batch_size":1000}}),
    );
    response
        .get("value")
        .cloned()
        .ok_or_else(|| format!("engine rejected request: {response}"))
}

fn converse(adapter: &[&str], request: &Value) -> Result<Value, String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("--see-adapter")
        .args(adapter)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|error| error.to_string())?;
    if let Some(mut pipe) = child.stdin.take() {
        writeln!(pipe, "{request}").map_err(|error| error.to_string())?;
        writeln!(pipe, "{}", json!({"kind":"shutdown"})).map_err(|error| error.to_string())?;
    }
    let output = child
        .wait_with_output()
        .map_err(|error| error.to_string())?;
    String::from_utf8_lossy(&output.stdout)
        .lines()
        .filter_map(|line| serde_json::from_str::<Value>(line).ok())
        .find(|value| value.get("kind").and_then(Value::as_str) == Some("execute"))
        .ok_or_else(|| "missing execute response".to_owned())
}

fn tape_of(response: &Value) -> Result<Value, String> {
    response
        .get("effect_tape")
        .filter(|tape| !tape.is_null())
        .cloned()
        .ok_or_else(|| format!("missing tape: {response}"))
}

#[test]
fn native_records_the_same_tape_the_engine_records() -> Result<(), String> {
    let engine = engine(&request(&json!({}))?)?;
    let native = converse(&["aot"], &request(&json!({}))?)?;
    assert_eq!(engine.get("output"), Some(&json!("100\n")), "{engine}");
    assert_eq!(native.get("output"), engine.get("output"), "{native}");
    assert_eq!(
        native.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{native}"
    );
    let engine_entries = tape_of(&engine)?;
    let native_entries = tape_of(&native)?;
    assert_eq!(
        native_entries.get("entries"),
        engine_entries.get("entries"),
        "{native}"
    );
    Ok(())
}

#[test]
fn engine_tape_replays_natively_without_host_calls() -> Result<(), String> {
    let engine = engine(&request(&json!({}))?)?;
    let replay =
        request(&json!({"execution_mode":"replay_from_tape","effect_tape":tape_of(&engine)?}))?;
    let native = converse(&["aot"], &replay)?;
    assert_eq!(native.get("output"), engine.get("output"), "{native}");
    assert_eq!(
        native.pointer("/host_observation/calls"),
        Some(&json!(0)),
        "{native}"
    );
    Ok(())
}

#[test]
fn native_tape_replays_in_the_engine() -> Result<(), String> {
    let native = converse(&["aot"], &request(&json!({}))?)?;
    let replay =
        request(&json!({"execution_mode":"replay_from_tape","effect_tape":tape_of(&native)?}))?;
    let engine = engine(&replay)?;
    assert_eq!(engine.get("output"), native.get("output"), "{engine}");
    assert_eq!(
        engine.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{engine}"
    );
    Ok(())
}

#[test]
fn native_rejects_a_tampered_tape_without_consulting_the_host() -> Result<(), String> {
    let engine = engine(&request(&json!({}))?)?;
    let mut tape = tape_of(&engine)?;
    *tape
        .pointer_mut("/entries/0/payload_bytes")
        .ok_or("missing payload")? = json!([1, 2, 3]);
    let replay = request(&json!({"execution_mode":"replay_from_tape","effect_tape":tape}))?;
    let native = converse(&["aot"], &replay)?;
    assert_eq!(
        native.pointer("/termination/kind"),
        Some(&json!("failed")),
        "{native}"
    );
    assert_eq!(native.get("output"), Some(&json!("")), "{native}");
    assert_eq!(
        native.pointer("/termination/code"),
        Some(&json!("replay_corrupted_tape")),
        "{native}"
    );
    assert!(
        native
            .pointer("/host_observation/calls")
            .is_none_or(|calls| calls == &json!(0)),
        "{native}"
    );
    Ok(())
}

#[test]
fn denied_permission_is_reported_identically() -> Result<(), String> {
    let denied =
        request(&json!({"host":{"permissions":[],"requested_permissions":["reloj"],"clock":[1]}}))?;
    let engine = engine(&denied)?;
    let native = converse(&["aot"], &denied)?;
    assert_ne!(engine.get("output"), Some(&json!("")), "{engine}");
    assert_ne!(engine.get("output"), Some(&json!("100\n")), "{engine}");
    assert_eq!(native.get("output"), engine.get("output"), "{native}");
    assert_eq!(
        tape_of(&native)?.get("entries"),
        tape_of(&engine)?.get("entries")
    );
    Ok(())
}

#[test]
fn native_rejects_history_seek() -> Result<(), String> {
    let native = converse(
        &["aot"],
        &request(&json!({"execution_mode":"history_seek"}))?,
    )?;
    assert_ne!(
        native.pointer("/termination/kind"),
        Some(&json!("completed")),
        "{native}"
    );
    Ok(())
}

#[test]
fn native_tape_is_inspected_with_seek_by_the_engine() -> Result<(), String> {
    let native = converse(&["aot"], &request(&json!({}))?)?;
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":CLOCK_PROGRAM}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":CLOCK_PROGRAM,
            "profile":"es","strictness":"strict","inputs":[],"seed":42,
            "limits":{"micro_steps":100_000},"observe":"events",
            "execution_mode":"history_seek","effect_tape":tape_of(&native)?,"host":host()}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    let advanced = session.call("advance", &json!({"resource":resource,"batch_size":1000}));
    assert_eq!(
        advanced.pointer("/value/termination/kind"),
        Some(&json!("completed")),
        "{advanced}"
    );
    assert_eq!(
        advanced.pointer("/value/host_observation/calls"),
        Some(&json!(0)),
        "{advanced}"
    );
    let sought = session.call("seek", &json!({"resource":resource,"event":0}));
    assert!(sought.get("value").is_some(), "{sought}");
    Ok(())
}
