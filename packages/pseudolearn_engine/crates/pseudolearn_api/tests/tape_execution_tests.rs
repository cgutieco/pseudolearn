use pseudolearn_api::tape_wire::{build_identity, tape_from_value, tape_to_value};
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
    assert!(unwrapped_tape.get("entries").and_then(serde_json::Value::as_array).is_some_and(|entries| !entries.is_empty()));
}

#[test]
fn replay_rejects_adulterated_recording() -> Result<(), String> {
    let program = "Algoritmo Main\nEscribir 42;\nFinAlgoritmo\n";
    let recording = execute_record(program);
    let mut tape = recording.pointer("/value/effect_tape").cloned().ok_or_else(|| format!("missing tape: {recording}"))?;
    *tape.pointer_mut("/entries/0/entry_hash").ok_or("missing entry hash")? = json!("bad_hash");
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let response = session.call("start", &json!({
        "analysis":analysis.pointer("/value/resource"), "program":program,
        "execution_mode":"replay_from_tape", "effect_tape":tape
    }));
    assert_eq!(response.pointer("/failure/detail").and_then(serde_json::Value::as_str), Some("Invalid protocol: replay_corrupted_tape"));
    Ok(())
}

#[test]
fn replay_consumes_recorded_output() -> Result<(), String> {
    let program = "Algoritmo Main\nEscribir 42;\nEscribir 7;\nFinAlgoritmo\n";
    let recording = execute_record(program);
    let tape = recording.pointer("/value/effect_tape").cloned().ok_or_else(|| format!("missing tape: {recording}"))?;
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call("start", &json!({
        "analysis":analysis.pointer("/value/resource"), "program":program,
        "execution_mode":"replay_from_tape", "effect_tape":tape
    }));
    let response = session.call("advance", &json!({"resource":started.pointer("/value/resource"),"batch_size":1000}));
    assert_eq!(response.pointer("/value/output"), Some(&json!("42\n7\n")));
    assert_eq!(response.pointer("/value/termination/kind"), Some(&json!("completed")));
    Ok(())
}

#[test]
fn tape_value_round_trip_preserves_content() -> Result<(), String> {
    let identity = ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
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
fn recorded_entry_hashes_chain_the_previous_hash() -> Result<(), String> {
    let recording = execute_record("Algoritmo Main\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n");
    let value = recording.pointer("/value/effect_tape").ok_or("missing tape")?;
    let tape = tape_from_value(value).map_err(|failure| format!("{failure:?}"))?;
    let entries = tape.entries();
    assert!(entries.len() >= 2);
    for pair in entries.windows(2) {
        let (previous, entry) = match pair {
            [previous, entry] => (previous, entry),
            _ => return Err("window of two expected".to_owned()),
        };
        let expected = pseudolearn_runtime::tape_entry_hash(&previous.entry_hash, entry);
        assert_eq!(entry.entry_hash, expected);
        let mut altered = entry.clone();
        altered.operation.push('x');
        assert_ne!(
            pseudolearn_runtime::tape_entry_hash(&previous.entry_hash, &altered),
            expected
        );
        assert_ne!(
            pseudolearn_runtime::tape_entry_hash("other_previous", entry),
            expected
        );
    }
    Ok(())
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

#[test]
fn two_identical_recordings_serialize_to_identical_tapes() -> Result<(), String> {
    let program = "Algoritmo Main\nEscribir 42;\nEscribir 7;\nFinAlgoritmo\n";
    let first = execute_record(program);
    let second = execute_record(program);
    let first_tape = first.pointer("/value/effect_tape").ok_or("missing first tape")?;
    let second_tape = second.pointer("/value/effect_tape").ok_or("missing second tape")?;
    assert_eq!(first_tape, second_tape);
    assert_eq!(first_tape.to_string(), second_tape.to_string());
    Ok(())
}

#[test]
fn recorded_input_reads_replay_from_the_tape_without_external_input() -> Result<(), String> {
    let program = "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n";
    let recording = ApiSession::default().call(
        "record",
        &json!({"request":{"program":program,"profile":"es","strictness":"strict","seed":42,"inputs":["21"],"observe":"events"}}),
    );
    let tape = recording
        .pointer("/value/effect_tape")
        .cloned()
        .ok_or_else(|| format!("missing tape: {recording}"))?;
    let reads = tape
        .pointer("/entries")
        .and_then(serde_json::Value::as_array)
        .map_or(0, |entries| {
            entries.iter().filter(|entry| entry.get("operation") == Some(&json!("read"))).count()
        });
    assert_eq!(reads, 1, "{tape}");
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call("start", &json!({
        "analysis":analysis.pointer("/value/resource"),"program":program,"profile":"es",
        "strictness":"strict","seed":42,"execution_mode":"replay_from_tape","effect_tape":tape
    }));
    let response = session.call("advance", &json!({"resource":started.pointer("/value/resource"),"batch_size":1000}));
    assert_eq!(response.pointer("/value/output"), Some(&json!("42\n")), "{response}");
    assert_eq!(response.pointer("/value/termination/kind"), Some(&json!("completed")));
    Ok(())
}
