use crate::{EffectTape, ExecutionIdentity, ReplayError, TAPE_SCHEMA_V1, TapeEntry};
use sha2::{Digest, Sha256};

pub fn encode_effect_tape(tape: &EffectTape) -> Result<Vec<u8>, ReplayError> {
    serde_json::to_vec(tape).map_err(|_| ReplayError::CorruptedTape)
}

pub fn decode_effect_tape(bytes: &[u8]) -> Result<EffectTape, ReplayError> {
    let mut tape: EffectTape =
        serde_json::from_slice(bytes).map_err(|_| ReplayError::CorruptedTape)?;
    validate(&tape)?;
    tape.budget.current_bytes = encoded_size(&tape);
    Ok(tape)
}

pub(crate) fn encoded_size(tape: &EffectTape) -> usize {
    encode_effect_tape(tape).map_or(usize::MAX, |bytes| bytes.len())
}

pub(crate) fn identity_hash(identity: &ExecutionIdentity) -> String {
    let mut digest = Sha256::new();
    digest.update(TAPE_SCHEMA_V1.as_bytes());
    if let Ok(bytes) = serde_json::to_vec(identity) {
        digest.update(bytes);
    }
    format!("{:x}", digest.finalize())
}

pub fn tape_entry_hash(previous: &str, entry: &TapeEntry) -> String {
    let mut digest = Sha256::new();
    digest.update(previous.as_bytes());
    let fields = (
        &entry.effect_seq,
        &entry.task_id,
        &entry.source_node_id,
        &entry.capability_kind,
        &entry.operation,
        &entry.request_digest,
        &entry.secret_reference,
        &entry.outcome,
        &entry.payload_bytes,
    );
    if let Ok(bytes) = serde_json::to_vec(&fields) {
        digest.update(bytes);
    }
    if let Some(delivery) = entry.delivery_seq {
        digest.update(delivery.to_be_bytes());
    }
    format!("{:x}", digest.finalize())
}

fn exceeds_budget(tape: &EffectTape) -> bool {
    tape.status != crate::ReproducibilityStatus::NonReproducibleTruncated
        && encoded_size(tape) > tape.budget.max_bytes
}

pub(crate) fn validate(tape: &EffectTape) -> Result<(), ReplayError> {
    if tape.version != TAPE_SCHEMA_V1 || exceeds_budget(tape) {
        return Err(ReplayError::CorruptedTape);
    }
    let mut previous = identity_hash(&tape.identity);
    let mut seen = std::collections::BTreeSet::new();
    for (index, entry) in tape.entries.iter().enumerate() {
        let position = u64::try_from(index)
            .ok()
            .and_then(|index| index.checked_add(1));
        if !delivery_matches(entry, position)
            || !seen.insert(entry.effect_seq)
            || entry.entry_hash != tape_entry_hash(&previous, entry)
            || !(["committed", "failed", "uncertain", "abandoned"]
                .contains(&entry.outcome.as_str())
                || entry.outcome == "requested" && !tape.is_reproducible())
        {
            return Err(ReplayError::CorruptedTape);
        }
        previous.clone_from(&entry.entry_hash);
    }
    Ok(())
}

fn delivery_matches(entry: &TapeEntry, position: Option<u64>) -> bool {
    match entry.delivery_seq {
        None => position == Some(entry.effect_seq),
        Some(delivery) => position == Some(delivery) && entry.effect_seq != delivery,
    }
}
