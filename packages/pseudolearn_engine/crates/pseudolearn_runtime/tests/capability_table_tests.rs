use pseudolearn_abi::CapabilityKind;
use pseudolearn_runtime::{
    CapabilityError, CapabilityTable, CommitOutcome, EffectPhase, ReproducibilityStatus, RightsMask,
};

#[test]
fn allocation_and_validation_succeed() -> Result<(), String> {
    let mut table = CapabilityTable::new();
    let token = table.allocate(CapabilityKind::Console, RightsMask::READ_WRITE);
    let entry = table
        .validate(&token)
        .map_err(|failure| format!("{failure:?}"))?;
    assert_eq!(entry.kind, CapabilityKind::Console);
    assert_eq!(entry.rights, RightsMask::READ_WRITE);
    assert!(!entry.closed);
    Ok(())
}

#[test]
fn closing_capability_invalidates_token() -> Result<(), String> {
    let mut table = CapabilityTable::new();
    let token = table.allocate(CapabilityKind::Clock, RightsMask::READ_ONLY);
    assert!(table.validate(&token).is_ok());
    table
        .close(&token)
        .map_err(|failure| format!("{failure:?}"))?;
    let post_close = table.validate(&token);
    assert_eq!(post_close, Err(CapabilityError::Closed));
    Ok(())
}

#[test]
fn close_all_invalidates_all_active_tokens() {
    let mut table = CapabilityTable::new();
    let first = table.allocate(CapabilityKind::Console, RightsMask::READ_ONLY);
    let second = table.allocate(CapabilityKind::Timer, RightsMask::READ_WRITE);
    table.close_all();
    assert_eq!(table.validate(&first), Err(CapabilityError::Closed));
    assert_eq!(table.validate(&second), Err(CapabilityError::Closed));
}

#[test]
fn rights_mask_subset_and_amplification_checks() {
    let read_only = RightsMask::READ_ONLY;
    let read_write = RightsMask::READ_WRITE;
    assert!(read_only.is_subset_of(read_write));
    assert!(!read_write.is_subset_of(read_only));
}

#[test]
fn effect_phases_and_commit_outcomes_represented() {
    let requested = EffectPhase::Requested;
    let resolved = EffectPhase::Resolved;
    assert_ne!(requested, resolved);
    let committed = CommitOutcome::Committed;
    let failed = CommitOutcome::Failed;
    let uncertain = CommitOutcome::Uncertain;
    assert_ne!(committed, failed);
    assert_ne!(committed, uncertain);
}

#[test]
fn reproducibility_status_behavior() {
    let reproducible = ReproducibilityStatus::Reproducible;
    assert!(reproducible.is_reproducible());
    assert_eq!(reproducible.as_str(), "reproducible");
    let uncertain = ReproducibilityStatus::UncertainExternalState;
    assert!(!uncertain.is_reproducible());
    assert_eq!(uncertain.as_str(), "uncertain_external_state");
}
