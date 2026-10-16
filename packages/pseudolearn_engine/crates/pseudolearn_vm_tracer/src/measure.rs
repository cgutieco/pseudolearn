#![forbid(unsafe_code)]

use std::time::Instant;

use pseudolearn_api::compile_source_to_ir;
use pseudolearn_bytecode::{
    SuperInstruction, VerifiedBytecode, compile_text, compile_text_with_superinstructions,
};
use pseudolearn_vm::{Fuel, RunExit, RunResult, load, run_loaded, run_profiled};

use crate::Workload;

const ITERATIONS_PER_PROCESS: u32 = 30;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct MeasuredSample {
    pub iteration: u32,
    pub nanoseconds: u64,
}

pub fn prepare_workload(workload: &Workload) -> Result<VerifiedBytecode, String> {
    prepare_workload_with_superinstructions(workload, &[])
}

pub fn prepare_workload_with_superinstructions(
    workload: &Workload,
    selected: &[SuperInstruction],
) -> Result<VerifiedBytecode, String> {
    let ir_text = compile_source_to_ir(&workload.source, "es", "flexible")
        .map_err(|diagnostics| format!("source compilation failed: {diagnostics:?}"))?;
    let compiled = if selected.is_empty() {
        compile_text(&ir_text)
    } else {
        compile_text_with_superinstructions(&ir_text, selected)
    };
    compiled.map_err(|error| format!("bytecode compilation failed: {error:?}\n{ir_text}"))
}

pub fn measure_workload(
    workload: &Workload,
    bytecode: &VerifiedBytecode,
) -> Result<Vec<MeasuredSample>, String> {
    let loaded = load(bytecode)
        .map_err(|trap| format!("workload failed to load: {} at {:?}", trap.code, trap.span))?;
    validate_result(workload, run_loaded(&loaded, Fuel::unlimited()))?;
    let mut samples = Vec::with_capacity(30);
    for iteration in 0..ITERATIONS_PER_PROCESS {
        let started = Instant::now();
        let result = run_loaded(&loaded, Fuel::unlimited());
        let nanoseconds = u64::try_from(started.elapsed().as_nanos())
            .map_err(|_| "sample duration exceeds the supported range".to_owned())?;
        validate_result(workload, result)?;
        if nanoseconds == 0 {
            return Err("clock resolution is insufficient for a positive sample".to_owned());
        }
        samples.push(MeasuredSample {
            iteration,
            nanoseconds,
        });
    }
    Ok(samples)
}

pub fn profile_workload(
    workload: &Workload,
    bytecode: &VerifiedBytecode,
) -> Result<serde_json::Value, String> {
    let (result, profile) = run_profiled(bytecode, Fuel::unlimited());
    validate_result(workload, result)?;
    Ok(serde_json::json!({
        "backend": "vm",
        "workload": workload.identifier,
        "opcodeCounts": profile.opcode_counts,
        "pairCounts": profile.pair_counts
    }))
}

fn validate_result(workload: &Workload, result: RunResult) -> Result<(), String> {
    match result.exit {
        RunExit::Completed(None) if result.output == workload.expected_output => Ok(()),
        RunExit::Completed(Some(_)) => Err("workload returned an unexpected value".to_owned()),
        RunExit::Service(_) => Err("workload exhausted VM service fuel".to_owned()),
        RunExit::Trap(trap) => Err(format!(
            "workload trapped: {} at {:?}",
            trap.code, trap.span
        )),
        RunExit::Completed(None) => Err(format!(
            "workload output {:?} differs from expected {:?}",
            result.output, workload.expected_output
        )),
        RunExit::AwaitingInput => Err("workload awaited input".to_owned()),
        RunExit::Cancelled => Err("workload was cancelled".to_owned()),
        RunExit::LimitReached { .. } => Err("workload reached execution limit".to_owned()),
    }
}
