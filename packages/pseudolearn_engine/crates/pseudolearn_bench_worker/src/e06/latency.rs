use std::time::Instant;

use pseudolearn_timeline::{ExecutionTimeline, SchedulerOptions};
use pseudolearn_vm::{Machine, RunExit, TwinMode, machine_events};
use serde_json::{Value, json};

use super::programs::{CompiledCase, options, storage_case};
use super::runner::{machine_for, nanoseconds};
use super::stats::{count_to_float, percentile};

const SAMPLE_EVERY: usize = 16;
const REWIND_QUERIES: usize = 30;
const TIMELINE_CHECKPOINTS: usize = 64;

fn query_top_frame(machine: &Machine<'_>) -> Result<(), String> {
    let top = machine.active_frames_count().saturating_sub(1);
    pseudolearn_timeline::capture_frame(machine, top)
        .map(std::hint::black_box)
        .map(|_| ())
        .map_err(|error| error.to_string())
}

fn sample_steps(case: &CompiledCase) -> Result<Vec<f64>, String> {
    let mut machine = machine_for(case, TwinMode::Probed)?;
    let mut samples = Vec::new();
    let mut seen = 0_usize;
    let mut ordinal = 0_usize;
    loop {
        let started = Instant::now();
        let finished = loop {
            match machine.step_instruction() {
                None if machine_events(&machine).len() > seen => break false,
                None => {}
                Some(RunExit::Completed(_)) => break true,
                Some(other) => return Err(format!("Unexpected exit: {other:?}")),
            }
        };
        if finished {
            return Ok(samples);
        }
        seen = machine_events(&machine).len();
        ordinal = ordinal.saturating_add(1);
        if ordinal.is_multiple_of(SAMPLE_EVERY) {
            query_top_frame(&machine)?;
            samples.push(nanoseconds(started));
        }
    }
}

pub fn measure_step(cases: &[CompiledCase]) -> Result<Value, String> {
    let mut all = Vec::new();
    let mut per_case = Vec::new();
    for case in cases {
        let samples = sample_steps(case)?;
        per_case.push(json!({"workload":case.name,"samples":samples.len(),
            "p95Nanoseconds":percentile(&samples,0.95)}));
        all.extend(samples);
    }
    let p95 = percentile(&all, 0.95);
    Ok(json!({"id":"M2","name":"observed step plus query latency",
        "criterion":"p95 <= 0.1 ms","p95Milliseconds":p95 / 1_000_000.0,
        "passed":p95 <= 100_000.0,"workloads":per_case}))
}

fn record_timeline<'program>(
    case: &'program CompiledCase,
) -> Result<(ExecutionTimeline<'program>, usize), String> {
    let run_options = options(TwinMode::Probed, &case.inputs);
    let mut machine = machine_for(case, TwinMode::Probed)?;
    let mut timeline = ExecutionTimeline::new(
        &case.program,
        run_options,
        SchedulerOptions::default(),
        TIMELINE_CHECKPOINTS,
    );
    let mut recorded = 0_usize;
    loop {
        match machine.step_instruction() {
            None => {
                let count = machine_events(&machine).len();
                if count > recorded {
                    recorded = count;
                    timeline
                        .record_step(&machine, count.saturating_sub(1))
                        .map_err(|error| error.to_string())?;
                }
            }
            Some(RunExit::Completed(_)) => return Ok((timeline, recorded)),
            Some(other) => return Err(format!("Unexpected exit: {other:?}")),
        }
    }
}

fn rewind_samples(case: &CompiledCase) -> Result<Vec<f64>, String> {
    let (mut timeline, total) = record_timeline(case)?;
    let horizon = pseudolearn_timeline::timeline_horizon(&timeline);
    let span = total.saturating_sub(horizon).max(1);
    let mut state = 0x9E37_79B9_7F4A_7C15_u64;
    let mut samples = Vec::new();
    for _ in 0..REWIND_QUERIES {
        state = state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        let offset = usize::try_from(state >> 33)
            .unwrap_or(0)
            .checked_rem(span)
            .unwrap_or(0);
        let event = horizon.saturating_add(offset).min(total.saturating_sub(1));
        let started = Instant::now();
        let frames = timeline
            .query_frames(event)
            .map_err(|error| error.to_string())?;
        std::hint::black_box(frames);
        samples.push(nanoseconds(started));
    }
    Ok(samples)
}

pub fn measure_rewind(cases: &[CompiledCase]) -> Result<Value, String> {
    let large = storage_case(10)?;
    let mut all = Vec::new();
    let mut per_case = Vec::new();
    for case in cases.iter().chain(std::iter::once(&large)) {
        let samples = rewind_samples(case)?;
        per_case.push(json!({"workload":case.name,"queries":samples.len(),
            "p95Milliseconds":percentile(&samples,0.95) / 1_000_000.0,
            "samplesNanoseconds":samples}));
        all.extend(samples);
    }
    let p95 = percentile(&all, 0.95) / 1_000_000.0;
    Ok(
        json!({"id":"M3","name":"rewind latency","criterion":"p95 <= 50 ms",
        "p95Milliseconds":p95,"queries":count_to_float(all.len()),
        "passed":p95 <= 50.0,"workloads":per_case}),
    )
}
