use crate::{EffectTape, TapeEntry};

const WRITING_MARKERS: [&str; 8] = [
    "write", "delete", "remove", "create", "rename", "append", "truncate", "make",
];

pub fn operation_may_write(identity: &str) -> bool {
    WRITING_MARKERS
        .iter()
        .any(|marker| identity.contains(marker))
}

fn is_requested_by_program(entry: &TapeEntry) -> bool {
    !(entry.capability_kind == "console" && matches!(entry.operation.as_str(), "write" | "read"))
}

pub fn delivery_order(tape: &EffectTape) -> Vec<u64> {
    let mut requested: Vec<u64> = tape
        .entries
        .iter()
        .filter(|entry| is_requested_by_program(entry))
        .map(|entry| entry.effect_seq)
        .collect();
    requested.sort_unstable();
    tape.entries
        .iter()
        .filter(|entry| is_requested_by_program(entry))
        .filter_map(|entry| requested.binary_search(&entry.effect_seq).ok())
        .map(|rank| u64::try_from(rank).unwrap_or(u64::MAX).saturating_add(1))
        .collect()
}
