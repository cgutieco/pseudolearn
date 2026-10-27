use pseudolearn_runtime::{EffectTape, ExecutionIdentity, TAPE_SCHEMA_V1, TapeEntry};

fn sample_identity() -> ExecutionIdentity {
    ExecutionIdentity {
        strictness: "strict".to_owned(),
        limits: Default::default(),
        source_digest: "abcd1234ef".to_owned(),
        package_graph_digest: "none".to_owned(),
        profile: "es".to_owned(),
        seed: 42,
        statement_limit: Some(100),
        permissions: vec!["consola".to_owned()],
    }
}

fn sample_entry(sequence: u64, outcome: &str) -> TapeEntry {
    TapeEntry {
        effect_seq: sequence,
        task_id: 1,
        source_node_id: 10,
        capability_kind: "consola".to_owned(),
        operation: "escribir".to_owned(),
        request_digest: "req123".to_owned(),
        secret_reference: None,
        outcome: outcome.to_owned(),
        payload_bytes: vec![1, 2, 3],
        entry_hash: "hash123".to_owned(),
    }
}

#[test]
fn new_tape_has_schema_v1_and_is_reproducible() {
    let tape = EffectTape::new(sample_identity());
    assert_eq!(tape.version, TAPE_SCHEMA_V1);
    assert!(tape.is_reproducible());
    assert!(tape.entries().is_empty());
}

#[test]
fn appending_committed_entries_preserves_reproducibility() {
    let mut tape = EffectTape::new(sample_identity());
    tape.append(sample_entry(1, "committed"));
    tape.append(sample_entry(2, "committed"));
    assert_eq!(tape.entries().len(), 2);
    assert!(tape.is_reproducible());
}

#[test]
fn uncertain_outcome_marks_tape_non_reproducible() {
    let mut tape = EffectTape::new(sample_identity());
    tape.append(sample_entry(1, "committed"));
    tape.append(sample_entry(2, "uncertain"));
    assert_eq!(tape.entries().len(), 2);
    assert!(!tape.is_reproducible());
}

#[test]
fn mark_incomplete_invalidates_reproducibility() {
    let mut tape = EffectTape::new(sample_identity());
    tape.append(sample_entry(1, "committed"));
    tape.mark_incomplete();
    assert!(!tape.is_reproducible());
}

#[test]
fn exact_serialized_budget_admits_only_complete_entries() -> Result<(), String> {
    let mut limit = 2048;
    for _ in 0..8 {
        let mut tape = EffectTape::with_budget(sample_identity(), limit);
        tape.append(sample_entry(1, "committed"));
        let actual = pseudolearn_runtime::encode_effect_tape(&tape)
            .map_err(|error| format!("{error:?}"))?
            .len();
        if limit == actual {
            break;
        }
        limit = actual;
    }
    for offset in [-1_i64, 0, 1] {
        let maximum = usize::try_from(
            i64::try_from(limit)
                .map_err(|error| error.to_string())?
                .checked_add(offset)
                .ok_or("budget overflow")?,
        )
        .map_err(|error| error.to_string())?;
        let mut tape = EffectTape::with_budget(sample_identity(), maximum);
        tape.append(sample_entry(1, "committed"));
        assert_eq!(tape.is_reproducible(), offset >= 0);
        assert!(
            pseudolearn_runtime::encode_effect_tape(&tape)
                .map_err(|error| format!("{error:?}"))?
                .len()
                <= maximum
        );
    }
    Ok(())
}

#[test]
fn secret_reference_removes_payload_before_serialization() -> Result<(), String> {
    let mut tape = EffectTape::new(sample_identity());
    let mut entry = sample_entry(1, "committed");
    entry.payload_bytes = b"private-value".to_vec();
    entry.secret_reference = Some(
        pseudolearn_runtime::SecretHandle::authenticate(
            "primary".to_owned(),
            b"key",
            &entry.payload_bytes,
        )
        .map_err(|error| format!("{error:?}"))?
        .to_reference_string(),
    );
    tape.append(entry);
    assert!(!tape.is_reproducible());
    assert!(
        tape.entries()
            .iter()
            .all(|entry| entry.payload_bytes.is_empty())
    );
    let bytes =
        pseudolearn_runtime::encode_effect_tape(&tape).map_err(|error| format!("{error:?}"))?;
    assert!(
        !bytes
            .windows(b"private-value".len())
            .any(|window| window == b"private-value")
    );
    Ok(())
}
