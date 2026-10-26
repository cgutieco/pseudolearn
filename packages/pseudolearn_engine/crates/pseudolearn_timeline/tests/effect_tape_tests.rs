use pseudolearn_timeline::{
    EffectTape, ExecutionIdentity, TAPE_SCHEMA_V1, TapeEntry,
};

fn sample_identity() -> ExecutionIdentity {
    ExecutionIdentity {
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
