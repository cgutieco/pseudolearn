use crate::workloads::Workload;
use pseudolearn_api::{AnalyzeResponse, execute_analyze};
use serde_json::json;
use std::time::Instant;

pub fn collect() -> Result<(), String> {
    let resolution = timer_resolution();
    for workload in crate::workloads::load()? {
        for iteration in 0..30 {
            let start = Instant::now();
            let results: Vec<_> = workload.requests.iter().map(execute_analyze).collect();
            let nanoseconds = start.elapsed().as_nanos();
            for result in &results {
                validate(result, &workload)?;
            }
            println!(
                "{}",
                json!({"workload": workload.name, "iteration": iteration, "nanoseconds": nanoseconds, "timerResolutionNanoseconds": resolution, "lines": workload.lines, "bytes": workload.bytes, "programs": results.len(), "incomplete": workload.incomplete, "corpus": workload.corpus})
            );
        }
    }
    Ok(())
}

pub fn profile() -> Result<(), String> {
    let workload = crate::workloads::load()?
        .into_iter()
        .find(|workload| workload.name == "generated-es-strict-10000-false")
        .ok_or("Missing profile workload")?;
    for _ in 0..1000 {
        for request in &workload.requests {
            validate(&std::hint::black_box(execute_analyze(request)), &workload)?;
        }
    }
    Ok(())
}

pub(crate) fn validate(response: &AnalyzeResponse, workload: &Workload) -> Result<(), String> {
    if !response.tree
        || response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "internalFault")
    {
        return Err(format!("Invalid analysis of {}", workload.name));
    }
    if workload.corpus {
        return Ok(());
    }
    let has_error = response
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == "error");
    let unterminated = response
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.code == "unterminatedString");
    if workload.incomplete && unterminated || !workload.incomplete && !has_error {
        return Ok(());
    }
    Err(format!(
        "Unexpected diagnostics in {}: {:?}",
        workload.name, response.diagnostics
    ))
}

fn timer_resolution() -> u128 {
    (0..1000)
        .map(|_| Instant::now().elapsed().as_nanos())
        .filter(|duration| *duration > 0)
        .min()
        .unwrap_or(0)
}
