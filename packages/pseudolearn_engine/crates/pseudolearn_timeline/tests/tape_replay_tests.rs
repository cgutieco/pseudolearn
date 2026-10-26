use pseudolearn_timeline::{
    EffectTape, ExecutionIdentity, ExecutionMode, ReplayError, TapeEntry, TapeReplayProvider,
};

fn sample_identity() -> ExecutionIdentity {
    ExecutionIdentity {
        source_digest: "digest_source".to_owned(),
        package_graph_digest: "none".to_owned(),
        profile: "es".to_owned(),
        seed: 10,
        statement_limit: None,
        permissions: vec!["reloj".to_owned()],
    }
}

fn sample_entry(sequence: u64, operation: &str) -> TapeEntry {
    TapeEntry {
        effect_seq: sequence,
        task_id: 1,
        source_node_id: 5,
        capability_kind: "reloj".to_owned(),
        operation: operation.to_owned(),
        request_digest: "req_digest".to_owned(),
        secret_reference: None,
        outcome: "committed".to_owned(),
        payload_bytes: Vec::new(),
        entry_hash: "hash".to_owned(),
    }
}

#[test]
fn execution_modes_isolate_external_host() {
    assert!(ExecutionMode::LiveRecord.allows_external_host());
    assert!(!ExecutionMode::ReplayFromTape.allows_external_host());
    assert!(!ExecutionMode::HistorySeek.allows_external_host());
}

#[test]
fn replay_provider_validates_identity() -> Result<(), String> {
    let tape = EffectTape::new(sample_identity());
    let provider =
        TapeReplayProvider::new(tape).map_err(|failure| format!("{failure:?}"))?;
    assert!(provider.validate_identity(&sample_identity()).is_ok());
    let mut mismatched = sample_identity();
    mismatched.seed = 999;
    assert_eq!(
        provider.validate_identity(&mismatched),
        Err(ReplayError::IdentityMismatch)
    );
    Ok(())
}

#[test]
fn replay_provider_detects_divergence() -> Result<(), String> {
    let mut tape = EffectTape::new(sample_identity());
    tape.append(sample_entry(1, "consultar_tiempo"));
    let mut provider =
        TapeReplayProvider::new(tape).map_err(|failure| format!("{failure:?}"))?;
    let outcome = provider.next_effect(1, "operacion_diferente");
    assert_eq!(outcome, Err(ReplayError::Divergence));
    Ok(())
}

#[test]
fn replay_provider_detects_truncated_tape() -> Result<(), String> {
    let mut tape = EffectTape::new(sample_identity());
    tape.append(sample_entry(1, "consultar_tiempo"));
    let mut provider =
        TapeReplayProvider::new(tape).map_err(|failure| format!("{failure:?}"))?;
    assert!(provider.next_effect(1, "consultar_tiempo").is_ok());
    assert_eq!(
        provider.next_effect(2, "otra_operacion"),
        Err(ReplayError::TruncatedTape)
    );
    Ok(())
}

#[test]
fn replay_provider_rejects_non_reproducible_tape() {
    let mut tape = EffectTape::new(sample_identity());
    tape.mark_incomplete();
    let outcome = TapeReplayProvider::new(tape);
    assert_eq!(outcome, Err(ReplayError::NonReproducible));
}

#[test]
fn replay_error_codes_match_specification() {
    assert_eq!(
        ReplayError::IdentityMismatch.code(),
        "replay_identity_mismatch"
    );
    assert_eq!(ReplayError::Divergence.code(), "replay_divergence");
    assert_eq!(ReplayError::TruncatedTape.code(), "replay_truncated_tape");
    assert_eq!(ReplayError::CorruptedTape.code(), "replay_corrupted_tape");
    assert_eq!(
        ReplayError::NonReproducible.code(),
        "replay_non_reproducible"
    );
}
