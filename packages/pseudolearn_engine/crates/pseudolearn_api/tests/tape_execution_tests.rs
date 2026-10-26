use pseudolearn_api::tape_wire::{
    build_identity, compute_entry_hash, tape_from_value, tape_to_value,
};
use pseudolearn_api::{ApiSession, ExecuteRequest};
use pseudolearn_timeline::{EffectTape, ExecutionIdentity, TapeEntry};
use serde_json::json;

fn execute_record(program: &str) -> serde_json::Value {
    let mut session = ApiSession::default();
    let request = json!({
        "request": {
            "program": program,
            "profile": "es",
            "strictness": "strict",
            "seed": 42
        }
    });
    session.call("record", &request)
}

#[test]
fn record_operation_emits_versioned_effect_tape() {
    let outcome = execute_record("Algoritmo P\nEscribir 42;\nFinAlgoritmo\n");
    let tape = outcome.pointer("/value/effect_tape");
    assert!(tape.is_some());
    let unwrapped_tape = match tape {
        Some(found_tape) => found_tape,
        None => return,
    };
    assert_eq!(unwrapped_tape.get("format").and_then(serde_json::Value::as_str), Some("pseudolearn.tape/v1"));
    assert_eq!(unwrapped_tape.get("status").and_then(serde_json::Value::as_str), Some("reproducible"));
    let identity = unwrapped_tape.get("identity");
    assert!(identity.is_some());
}

#[test]
fn tape_value_round_trip_preserves_content() -> Result<(), String> {
    let identity = ExecutionIdentity {
        source_digest: "digest_123".to_owned(),
        package_graph_digest: "none".to_owned(),
        profile: "es".to_owned(),
        seed: 7,
        statement_limit: Some(50),
        permissions: vec!["reloj".to_owned()],
    };
    let mut tape = EffectTape::new(identity);
    tape.append(TapeEntry {
        effect_seq: 1,
        task_id: 0,
        source_node_id: 1,
        capability_kind: "consola".to_owned(),
        operation: "escribir".to_owned(),
        request_digest: "req".to_owned(),
        secret_reference: None,
        outcome: "committed".to_owned(),
        payload_bytes: vec![10, 20],
        entry_hash: "hash_entry".to_owned(),
    });
    let value = tape_to_value(&tape);
    let restored = tape_from_value(&value).map_err(|failure| format!("{failure:?}"))?;
    assert_eq!(restored.version, tape.version);
    assert_eq!(restored.identity, tape.identity);
    assert_eq!(restored.entries().len(), 1);
    Ok(())
}

#[test]
fn entry_hash_chains_previous_hash() {
    let previous = "initial_seed_hash";
    let first = compute_entry_hash(previous, 1, "escribir", &[1, 2]);
    let second = compute_entry_hash(&first, 2, "escribir", &[3, 4]);
    assert_ne!(first, second);
    let tampered = compute_entry_hash(previous, 1, "leer", &[1, 2]);
    assert_ne!(first, tampered);
}

#[test]
fn replay_mode_rejects_identity_mismatch() {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";
    let analysis = session.call("create_analysis", &json!({"program": program}));
    let analysis_id = analysis.pointer("/value/resource").cloned();
    let request_identity = build_identity(&ExecuteRequest {
        program: program.to_owned(),
        seed: 12345,
        ..Default::default()
    });
    let mut different_identity = request_identity;
    different_identity.seed = 99999;
    let mismatched_tape = EffectTape::new(different_identity);
    let request_payload = json!({
        "analysis": analysis_id,
        "program": program,
        "profile": "es",
        "strictness": "strict",
        "seed": 12345,
        "execution_mode": "replay_from_tape",
        "effect_tape": tape_to_value(&mismatched_tape)
    });
    let outcome = session.call("start", &request_payload);
    assert_eq!(
        outcome.pointer("/failure/family").and_then(serde_json::Value::as_str),
        Some("usage")
    );
    assert_eq!(
        outcome.pointer("/failure/detail").and_then(serde_json::Value::as_str),
        Some("Invalid protocol: replay_identity_mismatch")
    );
}

#[test]
fn replay_mode_rejects_non_reproducible_tape() {
    let mut session = ApiSession::default();
    let program = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";
    let analysis = session.call("create_analysis", &json!({"program": program}));
    let analysis_id = analysis.pointer("/value/resource").cloned();
    let request = ExecuteRequest {
        program: program.to_owned(),
        seed: 12345,
        ..Default::default()
    };
    let identity = build_identity(&request);
    let mut non_reproducible_tape = EffectTape::new(identity);
    non_reproducible_tape.mark_incomplete();
    let request_payload = json!({
        "analysis": analysis_id,
        "program": program,
        "profile": "es",
        "strictness": "strict",
        "seed": 12345,
        "execution_mode": "replay_from_tape",
        "effect_tape": tape_to_value(&non_reproducible_tape)
    });
    let outcome = session.call("start", &request_payload);
    assert_eq!(
        outcome.pointer("/failure/family").and_then(serde_json::Value::as_str),
        Some("usage")
    );
    assert_eq!(
        outcome.pointer("/failure/detail").and_then(serde_json::Value::as_str),
        Some("Invalid protocol: replay_non_reproducible")
    );
}
