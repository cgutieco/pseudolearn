use std::time::Instant;

use pseudolearn_timeline::CheckpointStore;
use pseudolearn_vm::{Machine, RunExit, TwinMode};
use serde_json::{Value, json};

use super::programs::depth_case;
use super::runner::{machine_for, nanoseconds};

const FRAMES: usize = 100_000;
const SHALLOW_FRAMES: usize = 1_000;
const PROGRAM_DEPTH: usize = 200_000;
const BLOCK_WORDS: usize = 64;
const STEPS_BETWEEN_POINTS: usize = 2_000;

fn descend(machine: &mut Machine<'_>, depth: usize) -> Result<(), String> {
    while machine.active_frames_count() < depth {
        if let Some(exit) = machine.step_instruction() {
            return Err(format!("Stopped before depth: {exit:?}"));
        }
    }
    Ok(())
}

fn advance(machine: &mut Machine<'_>) -> Result<(), String> {
    for _ in 0..STEPS_BETWEEN_POINTS {
        match machine.step_instruction() {
            None => {}
            Some(RunExit::Completed(_)) => return Ok(()),
            Some(other) => return Err(format!("Unexpected exit: {other:?}")),
        }
    }
    Ok(())
}

struct PointCost {
    frames: usize,
    copied_slots: usize,
    copied_bank_slots: usize,
    nanoseconds: f64,
}

fn cost_at(depth: usize, repetitions: usize) -> Result<(PointCost, f64), String> {
    let case = depth_case(PROGRAM_DEPTH)?;
    let mut machine = machine_for(&case, TwinMode::Probed)?;
    descend(&mut machine, depth)?;
    let mut store = CheckpointStore::new(8);
    store
        .record(&machine, 0)
        .map_err(|error| error.to_string())?;
    advance(&mut machine)?;
    let mut samples = Vec::with_capacity(repetitions);
    let mut recorded_cost = None;
    for index in 0..repetitions {
        let started = Instant::now();
        store
            .record(&machine, index.saturating_add(1))
            .map_err(|error| error.to_string())?;
        samples.push(nanoseconds(started));
        recorded_cost = Some(store.stats().last_cost);
    }
    let p95_ns = super::stats::percentile(&samples, 0.95);
    let cost = recorded_cost.ok_or_else(|| "No measurements".to_owned())?;
    let p95_us = p95_ns / 1_000.0;
    Ok((
        PointCost {
            frames: machine.active_frames_count(),
            copied_slots: cost.copied_slots,
            copied_bank_slots: cost.copied_bank_slots,
            nanoseconds: p95_ns,
        },
        p95_us,
    ))
}

fn document(cost: &PointCost) -> Value {
    json!({"frames":cost.frames,"copiedSlots":cost.copied_slots,
        "copiedBankSlots":cost.copied_bank_slots,"captureNanoseconds":cost.nanoseconds})
}

pub fn measure() -> Result<Value, String> {
    let (shallow, _) = cost_at(SHALLOW_FRAMES, 5)?;
    let (deep, capture_p95_us) = cost_at(FRAMES, 30)?;
    let allowance = shallow
        .copied_slots
        .saturating_add(shallow.copied_slots / 2)
        .saturating_add(BLOCK_WORDS);
    Ok(
        json!({"id":"E06-STACK","name":"checkpoint cost with deep stack",
        "criterion":"slots copied with 100000 frames <= 1.5x slots copied with 1000 frames plus one block, for the same executed interval; capture p95 <= 50 µs",
        "stepsBetweenPoints":STEPS_BETWEEN_POINTS,"shallow":document(&shallow),
        "deep":document(&deep),"capture_p95_us":capture_p95_us,
        "passed":deep.copied_slots <= allowance && capture_p95_us <= 50.0}),
    )
}
