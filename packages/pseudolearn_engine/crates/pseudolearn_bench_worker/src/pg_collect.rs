use crate::pg_campaign::SAMPLES_PER_PROCESS;
use crate::pg_workloads::{Workload, closures, expansive_generic_source, generics, inactive_effects};
use pseudolearn_api::{
    ExecuteRequest, PreparedProgram, build_benchmark_object, compile_source_to_ir,
    conformance_build_request, execute_prepared, prepare_program,
};
use serde_json::{Value, json};
use std::path::Path;
use std::time::Instant;

struct Prepared {
    request: ExecuteRequest,
    program: PreparedProgram,
}

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let [experiment, directory, process, machine] = arguments else {
        return Err(
            "Usage: pg-collect <E-PG-03|E-PG-04|E-PG-05> <directory> <process> <machine>".to_owned(),
        );
    };
    let process: u64 = process.parse().map_err(|_| "Invalid process".to_owned())?;
    let workloads = match experiment.as_str() {
        "E-PG-03" => generics(),
        "E-PG-04" => closures(),
        "E-PG-05" => inactive_effects(),
        _ => return Err("Unknown experiment".to_owned()),
    };
    for workload in &workloads {
        let record = measure(workload, process, machine)?;
        write_record(directory, &workload.name, process, &record)?;
    }
    if experiment == "E-PG-03" && process == 0 {
        write_record(directory, "expansive", 0, &expansive_record())?;
    }
    Ok(())
}

fn write_record(
    directory: &str,
    workload: &str,
    process: u64,
    record: &Value,
) -> Result<(), String> {
    let folder = Path::new(directory).join(workload);
    std::fs::create_dir_all(&folder).map_err(|error| error.to_string())?;
    let path = folder.join(format!("process-{process:02}.json"));
    if path.exists() {
        return Err(format!("Refusing to overwrite {}", path.display()));
    }
    std::fs::write(&path, record.to_string()).map_err(|error| error.to_string())
}

fn prepare(source: &str) -> Result<Prepared, String> {
    let request = ExecuteRequest {
        program: source.to_owned(),
        ..Default::default()
    };
    let program = prepare_program(&request).map_err(|diagnostics| format!("{diagnostics:?}"))?;
    Ok(Prepared { request, program })
}

fn execute(prepared: &Prepared) -> Result<(u128, String), String> {
    let start = Instant::now();
    let response = std::hint::black_box(execute_prepared(&prepared.program, &prepared.request));
    let nanoseconds = start.elapsed().as_nanos();
    let completed = response.termination.get("kind").and_then(Value::as_str) == Some("completed");
    if !completed {
        return Err(format!("Execution did not complete: {response:?}"));
    }
    Ok((nanoseconds.max(1), response.output))
}

fn measure(workload: &Workload, process: u64, machine: &str) -> Result<Value, String> {
    let candidate = prepare(&workload.candidate)?;
    let control = prepare(&workload.control)?;
    let stressed = ExecuteRequest {
        gc_stress: true,
        ..candidate.request.clone()
    };
    let stressed_output = execute_prepared(&candidate.program, &stressed).output;
    let mut samples = Vec::new();
    for position in 0..SAMPLES_PER_PROCESS {
        let (candidate_time, candidate_output, control_time, control_output) =
            paired(&candidate, &control, position)?;
        samples.push(json!({
            "workload": workload.name,
            "candidate_nanoseconds": u64::try_from(candidate_time).unwrap_or(u64::MAX),
            "control_nanoseconds": u64::try_from(control_time).unwrap_or(u64::MAX),
            "candidate_output": candidate_output,
            "control_output": control_output,
            "stressed_output_matches": stressed_output == candidate_output,
        }));
    }
    Ok(json!({
        "process": process,
        "machine": machine,
        "clock_resolution_nanoseconds": clock_resolution(),
        "samples": samples,
        "shape": {
            "candidate": shape(&workload.candidate)?,
            "control": shape(&workload.control)?,
        },
    }))
}

fn paired(
    candidate: &Prepared,
    control: &Prepared,
    position: usize,
) -> Result<(u128, String, u128, String), String> {
    if position.checked_rem(2) == Some(0) {
        let first = execute(candidate)?;
        let second = execute(control)?;
        return Ok((first.0, first.1, second.0, second.1));
    }
    let second = execute(control)?;
    let first = execute(candidate)?;
    Ok((first.0, first.1, second.0, second.1))
}

fn clock_resolution() -> f64 {
    let mut smallest = u128::MAX;
    for _ in 0..1000 {
        let start = Instant::now();
        let mut elapsed = start.elapsed().as_nanos();
        while elapsed == 0 {
            elapsed = start.elapsed().as_nanos();
        }
        smallest = smallest.min(elapsed);
    }
    u32::try_from(smallest).map_or(f64::MAX, f64::from)
}

fn shape(source: &str) -> Result<Value, String> {
    let start = Instant::now();
    prepare(source)?;
    let compile_nanoseconds = start.elapsed().as_nanos();
    let ir = compile_source_to_ir(source, "es", "strict")
        .map_err(|diagnostics| format!("{diagnostics:?}"))?;
    let request = ExecuteRequest {
        program: source.to_owned(),
        ..Default::default()
    };
    let object = build_benchmark_object(&conformance_build_request(&request))
        .map_err(|error| format!("{error:?}"))?;
    Ok(json!({
        "compile_nanoseconds": u64::try_from(compile_nanoseconds).unwrap_or(u64::MAX),
        "ir_bytes": ir.len(),
        "instances": ir.lines().filter(|line| line.starts_with("func ") && line.contains('<')).count(),
        "object_bytes": object.bytes.len(),
    }))
}

fn expansive_record() -> Value {
    let rejection = prepare(&expansive_generic_source()).err();
    json!({"rejected": rejection.is_some(), "diagnostics": rejection.unwrap_or_default()})
}
