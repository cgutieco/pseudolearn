use crate::corpus::Workload;
use ceiling_kernels::variant::Experiment;
use serde_json::json;
use std::time::{Duration, Instant};

pub fn run() -> Result<(), String> {
    for workload in crate::corpus::load("medicion")? {
        for iteration in 0..30 {
            for offset in 0_u8..4 {
                let variant = (offset.wrapping_add(iteration)) & 3;
                let sample = measure(&workload, variant)?;
                println!(
                    "{}",
                    json!({
                        "workload": workload.name, "family": workload.family,
                        "variant": variant, "iteration": iteration,
                        "nanoseconds": sample.0, "repetitions": sample.1,
                        "checkpoints": sample.2,
                    })
                );
            }
        }
    }
    Ok(())
}

pub fn measure(workload: &Workload, variant: u8) -> Result<(f64, u32, u64), String> {
    let mut experiment = Experiment::new(variant).map_err(|error| format!("{error:?}"))?;
    let mut elapsed = Duration::ZERO;
    let mut repetitions = 0_u32;
    while elapsed < Duration::from_millis(5) {
        let start = Instant::now();
        let output = experiment
            .run(&workload.name, std::hint::black_box(workload.size))
            .map_err(|error| format!("{} V{variant}: {error:?}", workload.name))?;
        elapsed = elapsed.saturating_add(start.elapsed());
        validate(&output, &workload.expected)?;
        repetitions = repetitions.checked_add(1).ok_or("Repetition overflow")?;
    }
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
