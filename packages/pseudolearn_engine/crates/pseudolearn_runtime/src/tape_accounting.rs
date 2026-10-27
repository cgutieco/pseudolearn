use crate::{EffectTape, ReproducibilityStatus, TapeEntry};

pub(crate) fn entry_bytes(entry: &TapeEntry) -> usize {
    serde_json::to_vec(entry).map_or(usize::MAX, |bytes| bytes.len())
}

pub(crate) fn set_status(tape: &mut EffectTape, status: ReproducibilityStatus) {
    tape.budget.current_bytes = tape
        .budget
        .current_bytes
        .checked_sub(tape.status.as_str().len())
        .and_then(|bytes| bytes.checked_add(status.as_str().len()))
        .unwrap_or(usize::MAX);
    tape.status = status;
}

pub(crate) fn pop(tape: &mut EffectTape) {
    if let Some(entry) = tape.entries.pop() {
        let bytes = entry_bytes(&entry).saturating_add(usize::from(!tape.entries.is_empty()));
        tape.budget.current_bytes = tape.budget.current_bytes.saturating_sub(bytes);
    }
}

pub(crate) fn truncate(tape: &mut EffectTape) {
    set_status(tape, ReproducibilityStatus::NonReproducibleTruncated);
    while tape.budget.current_bytes > tape.budget.max_bytes && !tape.entries.is_empty() {
        pop(tape);
    }
}
