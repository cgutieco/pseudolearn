use pseudolearn_runtime::{
    EffectTape, ExecutionIdentity, ReplayError, ReproducibilityStatus, TapeEntry,
    TapeReplayProvider, decode_effect_tape, encode_effect_tape,
};

fn identity() -> ExecutionIdentity {
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

fn entry(sequence: u64) -> TapeEntry {
    TapeEntry {
        effect_seq: sequence,
        task_id: 1,
        delivery_seq: None,
        source_node_id: 10,
        capability_kind: "consola".to_owned(),
        operation: "escribir".to_owned(),
        request_digest: "req123".to_owned(),
        secret_reference: None,
        outcome: "committed".to_owned(),
        payload_bytes: vec![1, 2, 3],
        entry_hash: String::new(),
    }
}

fn recorded(budget: usize, entries: u64) -> EffectTape {
    let mut tape = EffectTape::with_budget(identity(), budget);
    for sequence in 1..=entries {
        tape.append(entry(sequence));
    }
    tape
}

fn smallest_admitting_budget(entries: u64) -> Result<usize, String> {
    (0..4096usize)
        .find(|budget| recorded(*budget, entries).entries().len() == usize::try_from(entries).unwrap_or(0))
        .ok_or_else(|| "no budget under 4096 admits the entries".to_owned())
}

#[test]
fn one_byte_below_the_exact_budget_truncates() -> Result<(), String> {
    let exact = smallest_admitting_budget(1)?;
    let tape = recorded(exact.saturating_sub(1), 1);
    assert_eq!(tape.status, ReproducibilityStatus::NonReproducibleTruncated);
    assert!(tape.entries().is_empty());
    assert!(!tape.is_reproducible());
    Ok(())
}

#[test]
fn the_exact_budget_admits_the_entry_and_the_tape_fits_it() -> Result<(), String> {
    let exact = smallest_admitting_budget(1)?;
    let tape = recorded(exact, 1);
    assert_eq!(tape.status, ReproducibilityStatus::Reproducible);
    assert_eq!(tape.entries().len(), 1);
    let encoded = encode_effect_tape(&tape).map_err(|error| format!("{error:?}"))?;
    assert_eq!(encoded.len(), exact);
    Ok(())
}

#[test]
fn one_byte_above_the_exact_budget_admits_the_entry() -> Result<(), String> {
    let exact = smallest_admitting_budget(1)?;
    let tape = recorded(exact.saturating_add(1), 1);
    assert_eq!(tape.status, ReproducibilityStatus::Reproducible);
    assert_eq!(tape.entries().len(), 1);
    Ok(())
}

#[test]
fn second_entry_is_cut_at_its_own_exact_boundary() -> Result<(), String> {
    let exact = smallest_admitting_budget(2)?;
    let below = recorded(exact.saturating_sub(1), 2);
    assert_eq!(below.status, ReproducibilityStatus::NonReproducibleTruncated);
    assert_eq!(below.entries().len(), 1);
    let exact_tape = recorded(exact, 2);
    assert_eq!(exact_tape.status, ReproducibilityStatus::Reproducible);
    assert_eq!(exact_tape.entries().len(), 2);
    Ok(())
}

#[test]
fn truncated_tape_ignores_later_entries_and_stays_within_the_budget() -> Result<(), String> {
    let exact = smallest_admitting_budget(2)?;
    let tape = recorded(exact.saturating_sub(1), 5);
    assert_eq!(tape.status, ReproducibilityStatus::NonReproducibleTruncated);
    assert_eq!(tape.entries().len(), 1);
    let encoded = encode_effect_tape(&tape).map_err(|error| format!("{error:?}"))?;
    assert!(encoded.len() < exact);
    Ok(())
}

#[test]
fn zero_budget_truncates_the_first_entry() {
    let tape = recorded(0, 1);
    assert_eq!(tape.status, ReproducibilityStatus::NonReproducibleTruncated);
    assert!(tape.entries().is_empty());
}

#[test]
fn a_truncated_tape_smaller_than_its_identity_decodes_and_is_rejected_as_non_reproducible()
-> Result<(), String> {
    let tape = recorded(1, 1);
    assert_eq!(tape.status, ReproducibilityStatus::NonReproducibleTruncated);
    let bytes = encode_effect_tape(&tape).map_err(|error| error.code().to_owned())?;
    let decoded = decode_effect_tape(&bytes).map_err(|error| error.code().to_owned())?;
    assert!(matches!(
        TapeReplayProvider::new(decoded),
        Err(ReplayError::NonReproducible)
    ));
    Ok(())
}

#[test]
fn a_reproducible_tape_over_its_budget_is_corrupted() -> Result<(), String> {
    let mut tape = recorded(4096, 1);
    tape.budget.max_bytes = 1;
    let bytes = encode_effect_tape(&tape).map_err(|error| error.code().to_owned())?;
    assert_eq!(
        decode_effect_tape(&bytes).err(),
        Some(ReplayError::CorruptedTape)
    );
    Ok(())
}
