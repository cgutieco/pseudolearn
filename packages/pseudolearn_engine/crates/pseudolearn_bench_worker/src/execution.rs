use pseudolearn_api::{ExecuteRequest, PreparedProgram, execute_prepared, prepare_program};
use serde_json::{Value, json};
use std::time::Instant;

struct Workload {
    name: String,
    request: ExecuteRequest,
    program: PreparedProgram,
    output: String,
}

pub fn collect() -> Result<(), String> {
    for workload in workloads()? {
        for iteration in 0..30 {
            let start = Instant::now();
            let response =
                std::hint::black_box(execute_prepared(&workload.program, &workload.request));
            let nanoseconds = start.elapsed().as_nanos();
            if response.output != workload.output
                || response.termination.get("kind").and_then(Value::as_str) != Some("completed")
            {
                return Err(format!(
                    "Invalid execution of {}: {:?}",
                    workload.name, response
                ));
            }
            println!(
                "{}",
                json!({"workload":workload.name,"iteration":iteration,"nanoseconds":nanoseconds,
                "wallMicroseconds":nanoseconds.checked_div(1000).unwrap_or(0),"observed":false})
            );
        }
    }
    Ok(())
}

fn workloads() -> Result<Vec<Workload>, String> {
    crate::corpus::awfy_cases()?
        .into_iter()
        .map(|case| {
            let request = ExecuteRequest {
                program: case.source,
                inputs: case.inputs,
                ..Default::default()
            };
            let program = prepare_program(&request)
                .map_err(|diagnostics| format!("{}: {diagnostics:?}", case.name))?;
            Ok(Workload {
                name: case.name,
                request,
                program,
                output: case.expected_output,
            })
        })
        .collect()
}
