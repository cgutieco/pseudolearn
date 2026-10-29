use crate::pg_http_workloads::{Workload, all};
use pseudolearn_api::{PreparedProgram, execute_prepared, prepare_program};
use serde_json::{Value, json};
use std::path::{Path, PathBuf};
use std::time::Instant;

const PROTOCOL: &str = "pg-http/1";
const SAMPLES_PER_PROCESS: usize = 30;

struct PreparedWorkload {
    workload: Workload,
    program: PreparedProgram,
}

struct ProcessIdentity<'identity> {
    directory: &'identity str,
    process: u64,
    machine: &'identity str,
    resolution: u64,
}

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let [directory, process, machine] = arguments else {
        return Err("Usage: pg-http <new-directory> <process> <machine>".to_owned());
    };
    let process = process
        .parse::<u64>()
        .map_err(|_| "Invalid process identity".to_owned())?;
    if machine.is_empty() {
        return Err("Machine identity cannot be empty".to_owned());
    }
    let workloads = all();
    ensure_new_paths(directory, process, &workloads)?;
    let resolution = clock_resolution()?;
    let prepared = prepare_workloads(workloads)?;
    let identity = ProcessIdentity {
        directory,
        process,
        machine,
        resolution,
    };
    for workload in prepared {
        save_process(&identity, workload)?;
    }
    Ok(())
}

fn ensure_new_paths(directory: &str, process: u64, workloads: &[Workload]) -> Result<(), String> {
    for workload in workloads {
        let path = process_path(directory, &workload.name, process);
        if path.exists() {
            return Err(format!("Refusing to overwrite {}", path.display()));
        }
    }
    Ok(())
}

fn prepare_workloads(workloads: Vec<Workload>) -> Result<Vec<PreparedWorkload>, String> {
    workloads
        .into_iter()
        .map(|workload| {
            let program = prepare_program(&workload.request)
                .map_err(|diagnostics| format!("{}: {diagnostics:?}", workload.name))?;
            Ok(PreparedWorkload { workload, program })
        })
        .collect()
}

fn save_process(identity: &ProcessIdentity<'_>, prepared: PreparedWorkload) -> Result<(), String> {
    let samples = measure(&prepared)?;
    let workload = &prepared.workload;
    let document = json!({
        "protocol": PROTOCOL,
        "process": identity.process,
        "machine": identity.machine,
        "clock_resolution_nanoseconds": identity.resolution,
        "workload": workload.name,
        "category": workload.category,
        "body_bytes": workload.body_bytes,
        "input_bytes": workload.input_bytes,
        "json_nodes": workload.json_nodes,
        "expected_output": workload.expected_output,
        "samples": samples,
    });
    let path = process_path(identity.directory, &workload.name, identity.process);
    let parent = path
        .parent()
        .ok_or_else(|| "Invalid campaign path".to_owned())?;
    std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
    let bytes = serde_json::to_vec(&document).map_err(|error| error.to_string())?;
    std::fs::write(&path, bytes).map_err(|error| error.to_string())
}

fn measure(prepared: &PreparedWorkload) -> Result<Vec<Value>, String> {
    let mut samples = Vec::with_capacity(SAMPLES_PER_PROCESS);
    for _ in 0..SAMPLES_PER_PROCESS {
        let start = Instant::now();
        let response = execute_prepared(&prepared.program, &prepared.workload.request);
        let elapsed = u64::try_from(start.elapsed().as_nanos())
            .map_err(|_| format!("{}: duration overflow", prepared.workload.name))?;
        validate_response(&prepared.workload, &response.termination, &response.output)?;
        if elapsed == 0 {
            return Err(format!(
                "{}: clock returned a zero sample",
                prepared.workload.name
            ));
        }
        samples.push(json!({
            "nanoseconds": elapsed,
            "output": response.output,
            "termination": response.termination,
        }));
    }
    Ok(samples)
}

pub(crate) fn validate_response(
    workload: &Workload,
    termination: &Value,
    output: &str,
) -> Result<(), String> {
    if termination.get("kind").and_then(Value::as_str) != Some("completed")
        || output != workload.expected_output
    {
        return Err(format!(
            "{}: unexpected execution response: {termination} {output:?}",
            workload.name
        ));
    }
    Ok(())
}

fn process_path(directory: &str, name: &str, process: u64) -> PathBuf {
    Path::new(directory)
        .join(name)
        .join(format!("process-{process:02}.json"))
}

pub(crate) fn clock_resolution() -> Result<u64, String> {
    let mut smallest = None;
    for _ in 0..10_000 {
        let start = Instant::now();
        let elapsed = start.elapsed().as_nanos();
        if elapsed > 0 && smallest.is_none_or(|current| elapsed < current) {
            smallest = Some(elapsed);
        }
    }
    smallest
        .and_then(|value| u64::try_from(value).ok())
        .ok_or_else(|| "Clock resolution is zero or unavailable".to_owned())
}
