use std::time::Instant;

use pseudolearn_timeline::StoreBudget;
use pseudolearn_vm::{TwinMode, machine_remaining_fuel};
use serde_json::{Value, json};

use super::observer::Recorder;
use super::programs::{LOOP_SOURCE, compile_case};
use super::runner::{machine_for, nanoseconds, run_chunked};

const BUDGET: StoreBudget = StoreBudget {
    max_checkpoints: 64,
    max_retained_slots: 1 << 20,
};

pub fn target_statements() -> u64 {
    std::env::var("E06_RETENTION_STATEMENTS")
        .ok()
        .and_then(|text| text.parse().ok())
        .unwrap_or(1_000_000_000)
}

pub fn measure() -> Result<Value, String> {
    let target = target_statements();
    let case = compile_case("retention-loop", LOOP_SOURCE, vec![i64::MAX.to_string()])?;
    let mut machine = machine_for(&case, TwinMode::Fast)?;
    let mut recorder = Recorder::new(BUDGET);
    let started = Instant::now();
    let mut peak_retained = 0_usize;
    let steps = run_chunked(&mut machine, |current, ordinal| {
        recorder.after_step(current, ordinal)?;
        peak_retained = peak_retained.max(recorder.store.stats().retained_slots);
        let consumed = u64::MAX.saturating_sub(machine_remaining_fuel(current).statements);
        Ok(consumed < target)
    })?;
    let elapsed = nanoseconds(started);
    let stats = recorder.store.stats();
    let horizon_exact = horizon_is_exact(&recorder, stats.horizon);
    let within_budget =
        peak_retained <= BUDGET.max_retained_slots && stats.checkpoints <= BUDGET.max_checkpoints;
    Ok(
        json!({"id":"E06-RETENTION","name":"retained memory over long runs",
        "criterion":"retained slots and checkpoints within configured budget; horizon declared and exact",
        "targetStatements":target,"steps":steps,"elapsedNanoseconds":elapsed,
        "checkpoints":stats.checkpoints,"maxCheckpoints":BUDGET.max_checkpoints,
        "retainedSlots":stats.retained_slots,"peakRetainedSlots":peak_retained,
        "maxRetainedSlots":BUDGET.max_retained_slots,"horizon":stats.horizon,
        "horizonExact":horizon_exact,"passed":within_budget && horizon_exact}),
    )
}

fn horizon_is_exact(recorder: &Recorder, horizon: usize) -> bool {
    let first_reachable = recorder.store.image_at(horizon).is_ok();
    let before_unreachable = horizon
        .checked_sub(1)
        .is_none_or(|before| recorder.store.image_at(before).is_err());
    first_reachable && before_unreachable
}
