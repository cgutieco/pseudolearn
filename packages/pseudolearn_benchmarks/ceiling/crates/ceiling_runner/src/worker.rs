use crate::corpus::Workload;
use ceiling_kernels::variant::Experiment;
use serde_json::json;
use std::time::{Duration, Instant};

pub fn run() -> Result<(), String> {
    run_variants(&[0, 1, 2, 3])
}

pub fn run_remanso() -> Result<(), String> {
    run_variants(&[0, 1, 2, 3, 4, 5, 6, 7, 8])
}

fn run_variants(variants: &[u8]) -> Result<(), String> {
    for workload in crate::corpus::load("medicion")? {
        for iteration in 0_u8..30 {
            emit_iteration(&workload, variants, iteration)?;
        }
    }
    Ok(())
}

fn emit_iteration(workload: &Workload, variants: &[u8], iteration: u8) -> Result<(), String> {
    for offset in 0..variants.len() {
        let index = offset
            .wrapping_add(usize::from(iteration))
            .checked_rem(variants.len())
            .ok_or("Empty variant selection")?;
        let variant = *variants.get(index).ok_or("Invalid variant selection")?;
        let sample = measure(workload, variant)?;
        println!(
            "{}",
            json!({
                "workload": workload.name, "family": workload.family,
                "variant": variant, "iteration": iteration,
                "nanoseconds": sample.0, "repetitions": sample.1, "checkpoints": sample.2,
            })
        );
    }
    Ok(())
}

pub fn measure(workload: &Workload, variant: u8) -> Result<(f64, u32, u64), String> {
    let mut experiment = Experiment::new(variant).map_err(|error| format!("{error:?}"))?;
    let mut elapsed = Duration::ZERO;
    let mut repetitions = 0_u32;
    let requires_checkpoint = [3, 7, 8].contains(&variant);
    while elapsed < Duration::from_millis(5)
        || (requires_checkpoint && experiment.checkpoints() == 0)
    {
        let start = Instant::now();
        let output = experiment
            .run(&workload.name, std::hint::black_box(workload.size))
            .map_err(|error| format!("{} V{variant}: {error:?}", workload.name))?;
        elapsed = elapsed.saturating_add(start.elapsed());
        validate(&output, &workload.expected)?;
        if elapsed > Duration::from_secs(1) && requires_checkpoint && experiment.checkpoints() == 0
        {
            return Err("Observed variant failed to record a checkpoint".to_owned());
        }
        repetitions = repetitions.checked_add(1).ok_or("Repetition overflow")?;
    }
    std::hint::black_box(experiment.services());
    let nanoseconds = elapsed.as_secs_f64() * 1_000_000_000.0 / f64::from(repetitions);
    Ok((nanoseconds, repetitions, experiment.checkpoints()))
}

pub fn validate(output: &str, expected: &str) -> Result<(), String> {
    if output != expected {
        return Err(format!(
            "Output mismatch: {output:?}, expected {expected:?}"
        ));
    }
    Ok(())
}

#[cfg(test)]
#[path = "worker_tests.rs"]
mod worker_tests;
