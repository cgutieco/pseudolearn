use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const TWO_READS: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir first Como Entero <- Propagar clock.Ahora();\nEscribir first;\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn record(host: Value, seed: i64) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": {
            "program": TWO_READS,
            "profile": "es",
            "strictness": "strict",
            "seed": seed,
            "host": host
        }, "options": {"capture_states": false}}),
    )
}

fn replay(tape: &Value, seed: i64) -> Value {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program": TWO_READS}));
    let started = session.call(
        "start",
        &json!({"analysis": analysis.pointer("/value/resource"), "program": TWO_READS,
            "profile": "es", "strictness": "strict", "seed": seed, "host": {"detached": true},
            "execution_mode": "replay_from_tape", "effect_tape": tape}),
    );
    if started.pointer("/failure").is_some() {
        return started;
    }
    let resource = started.pointer("/value/resource").cloned();
    session.call("advance", &json!({"resource": resource, "batch_size": 64}))
}

#[test]
fn two_live_clock_reads_are_increasing_and_recorded() {
    let recorded = record(json!({"clock": [100, 250]}), 7);
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("100\n250\n")),
        "{recorded}"
    );
    assert_eq!(
        recorded.pointer("/value/effect_tape/identity/seed"),
        Some(&json!(7)),
        "{recorded}"
    );
}

#[test]
fn replay_returns_the_recorded_clock_reads_without_consulting_the_host() -> Result<(), String> {
    let recorded = record(json!({"clock": [100, 250]}), 7);
    let tape = recorded
        .pointer("/value/effect_tape")
        .ok_or_else(|| format!("missing tape: {recorded}"))?;
    let replayed = replay(tape, 7);
    assert_eq!(
        replayed.pointer("/value/output"),
        Some(&json!("100\n250\n")),
        "{replayed}"
    );
    assert_eq!(
        replayed.pointer("/value/host_observation/calls"),
        Some(&json!(0)),
        "{replayed}"
    );
    Ok(())
}

#[test]
fn replay_with_a_different_seed_is_an_identity_mismatch() -> Result<(), String> {
    let recorded = record(json!({"clock": [100, 250]}), 7);
    let tape = recorded
        .pointer("/value/effect_tape")
        .ok_or_else(|| format!("missing tape: {recorded}"))?;
    let replayed = replay(tape, 8);
    assert_eq!(
        replayed.pointer("/failure/detail"),
        Some(&json!("Invalid protocol: replay_identity_mismatch")),
        "{replayed}"
    );
    Ok(())
}
