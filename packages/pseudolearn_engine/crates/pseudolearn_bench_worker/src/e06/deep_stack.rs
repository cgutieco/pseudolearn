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

fn cost_at(depth: usize) -> Result<PointCost, String> {
    let case = depth_case(PROGRAM_DEPTH)?;
    let mut machine = machine_for(&case, TwinMode::Probed)?;
    descend(&mut machine, depth)?;
    let mut store = CheckpointStore::new(8);
    store
        .record(&machine, 0)
        .map_err(|error| error.to_string())?;
    advance(&mut machine)?;
    let started = Instant::now();
    store
        .record(&machine, 1)
        .map_err(|error| error.to_string())?;
    let nanoseconds = nanoseconds(started);
    let cost = store.stats().last_cost;
    Ok(PointCost {
        frames: machine.active_frames_count(),
        copied_slots: cost.copied_slots,
        copied_bank_slots: cost.copied_bank_slots,
        nanoseconds,
    })
}

fn document(cost: &PointCost) -> Value {
    json!({"frames":cost.frames,"copiedSlots":cost.copied_slots,
        "copiedBankSlots":cost.copied_bank_slots,"captureNanoseconds":cost.nanoseconds})
}

pub fn measure() -> Result<Value, String> {
    let shallow = cost_at(SHALLOW_FRAMES)?;
    let deep = cost_at(FRAMES)?;
    let allowance = shallow
        .copied_slots
        .saturating_add(shallow.copied_slots / 2)
        .saturating_add(BLOCK_WORDS);
    Ok(
        json!({"id":"E06-STACK","name":"checkpoint cost with deep stack",
        "criterion":"slots copied with 100000 frames <= 1.5x slots copied with 1000 frames plus one block, for the same executed interval",
        "stepsBetweenPoints":STEPS_BETWEEN_POINTS,"shallow":document(&shallow),
        "deep":document(&deep),"passed":deep.copied_slots <= allowance}),
    )
}
