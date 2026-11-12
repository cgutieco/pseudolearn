#![forbid(unsafe_code)]

use std::io::Write;
use std::process::ExitCode;

use pseudolearn_bytecode::SuperInstruction;
use pseudolearn_vm_tracer::{
    load_workload, measure_workload, prepare_workload, prepare_workload_with_superinstructions,
    profile_workload,
};

fn main() -> ExitCode {
    match worker_result() {
        Ok(output) => match write_output(&output) {
            Ok(()) => ExitCode::SUCCESS,
            Err(error) => fail(error),
        },
        Err(error) => fail(error),
    }
}

fn worker_result() -> Result<serde_json::Value, String> {
    let arguments = std::env::args().skip(1).collect::<Vec<_>>();
    match arguments.first().map(String::as_str) {
        Some("worker") => worker_result_for(&arguments),
        Some("profile") => profile_result_for(&arguments),
        _ => Err("usage: vm-tracer worker|profile <workloads> <identifier> [process]".to_owned()),
    }
}

fn worker_result_for(arguments: &[String]) -> Result<serde_json::Value, String> {
    if arguments.len() != 5 {
        return Err("worker requires a dataset, workload, process, and profile".to_owned());
    }
    let path = arguments
        .get(1)
        .ok_or_else(|| "workload file is missing".to_owned())?;
    let identifier = arguments
        .get(2)
        .ok_or_else(|| "workload identifier is missing".to_owned())?;
    let process = arguments
        .get(3)
        .and_then(|value| value.parse::<u32>().ok())
        .ok_or_else(|| "process index is invalid".to_owned())?;
    let profile_path = arguments
        .get(4)
        .ok_or_else(|| "superinstruction profile is missing".to_owned())?;
    let workload = load_workload(path, identifier)?;
    let selected = load_superinstructions(profile_path)?;
    let bytecode = prepare_workload_with_superinstructions(&workload, &selected)?;
    let samples = measure_workload(&workload, &bytecode)?;
    let serialized_samples = samples
        .iter()
        .map(|sample| {
            serde_json::json!({
                "iteration": sample.iteration,
                "nanoseconds": sample.nanoseconds,
                "validated": true
            })
        })
        .collect::<Vec<_>>();
    Ok(serde_json::json!({
        "backend": "vm",
        "workload": workload.identifier,
        "process": process,
        "samples": serialized_samples
    }))
}

fn load_superinstructions(path: &str) -> Result<Vec<SuperInstruction>, String> {
    let content = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    let profile: serde_json::Value =
        serde_json::from_str(&content).map_err(|error| error.to_string())?;
    let selected = profile
        .get("selected")
        .and_then(serde_json::Value::as_array)
        .ok_or_else(|| "profile selection list is missing".to_owned())?;
    selected
        .iter()
        .map(|value| match value.as_str() {
            Some("compareBranch") => Ok(SuperInstruction::CompareBranch),
            Some("fusedArithmetic") => Ok(SuperInstruction::FusedArithmetic),
            _ => Err("profile contains an unknown superinstruction".to_owned()),
        })
        .collect()
}

fn profile_result_for(arguments: &[String]) -> Result<serde_json::Value, String> {
    if arguments.len() != 3 {
        return Err("profile requires a dataset and workload".to_owned());
    }
    let path = arguments
        .get(1)
        .ok_or_else(|| "workload file is missing".to_owned())?;
    let identifier = arguments
        .get(2)
        .ok_or_else(|| "workload identifier is missing".to_owned())?;
    let workload = load_workload(path, identifier)?;
    let bytecode = prepare_workload(&workload)?;
    profile_workload(&workload, &bytecode)
}

fn write_output(value: &serde_json::Value) -> Result<(), String> {
    let output = serde_json::to_vec(value).map_err(|error| error.to_string())?;
    let mut writer = std::io::stdout().lock();
    writer
        .write_all(&output)
        .and_then(|()| writer.write_all(b"\n"))
        .map_err(|error| error.to_string())
}

fn fail(error: String) -> ExitCode {
    eprintln!("{error}");
    ExitCode::FAILURE
}
