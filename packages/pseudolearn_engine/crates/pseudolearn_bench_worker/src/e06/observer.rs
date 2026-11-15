use std::time::Instant;

use pseudolearn_timeline::{CheckpointStore, CostScheduler, SchedulerOptions, StoreBudget};
use pseudolearn_vm::{Machine, TwinMode, machine_remaining_fuel};
use serde_json::{Value, json};

use super::programs::CompiledCase;
use super::runner::{machine_for, nanoseconds, run_chunked};
use super::stats::{geometric_mean, median};

pub struct Recorder {
    pub store: CheckpointStore,
    scheduler: CostScheduler,
}

impl Recorder {
    pub fn new(budget: StoreBudget) -> Self {
        Self {
            store: CheckpointStore::with_budget(budget),
            scheduler: CostScheduler::new(SchedulerOptions::default()),
        }
    }

    pub fn after_step(&mut self, machine: &Machine<'_>, steps: u64) -> Result<(), String> {
        let consumed = u64::MAX.saturating_sub(machine_remaining_fuel(machine).statements);
        if !self.store.has_checkpoints() || self.scheduler.should_checkpoint(consumed) {
            let ordinal = usize::try_from(steps).unwrap_or(usize::MAX);
            self.store
                .record(machine, ordinal)
                .map_err(|error| error.to_string())?;
            self.scheduler
                .record_checkpoint(consumed, self.store.stats().live_words);
        }
        Ok(())
    }
}

pub const DEFAULT_BUDGET: StoreBudget = StoreBudget {
    max_checkpoints: 64,
    max_retained_slots: 1 << 22,
};

fn timed_run(case: &CompiledCase, recording: bool) -> Result<f64, String> {
    let mut machine = machine_for(case, TwinMode::Fast)?;
    let mut recorder = Recorder::new(DEFAULT_BUDGET);
    let started = Instant::now();
    run_chunked(&mut machine, |current, steps| {
        if recording {
            recorder.after_step(current, steps)?;
        }
        Ok(true)
    })?;
    let elapsed = nanoseconds(started);
    std::hint::black_box(&recorder.store);
    Ok(elapsed)
}

pub fn measure(cases: &[CompiledCase], iterations: usize) -> Result<Value, String> {
    let mut ratios = Vec::new();
    let mut per_case = Vec::new();
    for case in cases {
        let mut baseline = Vec::new();
        let mut recorded = Vec::new();
        for iteration in 0..iterations {
            let recorded_first = !iteration.is_multiple_of(2);
            let first = timed_run(case, recorded_first)?;
            let second = timed_run(case, !recorded_first)?;
            let (without, with) = if recorded_first {
                (second, first)
            } else {
                (first, second)
            };
            baseline.push(without);
            recorded.push(with);
        }
        let ratio = median(&recorded) / median(&baseline);
        ratios.push(ratio);
        per_case.push(json!({"workload":case.name,"ratio":ratio,
            "baselineNanoseconds":baseline,"recordedNanoseconds":recorded}));
    }
    let geometric = geometric_mean(&ratios);
    Ok(json!({"id":"M4","name":"paused observer overhead",
        "criterion":"geometric mean of recorded/baseline <= 1.02",
        "value":geometric,"passed":geometric <= 1.02,"workloads":per_case}))
}
