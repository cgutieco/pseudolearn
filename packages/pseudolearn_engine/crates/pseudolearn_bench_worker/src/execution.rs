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
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let specifications = corpus
        .get("specifications")
        .and_then(Value::as_array)
        .ok_or("Missing specifications")?;
    let suite = specifications
        .iter()
        .find(|specification| {
            specification
                .pointer("/metadata/id")
                .and_then(Value::as_str)
                == Some("PERF.SUITE.AWFY-CORE")
        })
        .ok_or("Missing AWFY suite")?;
    let mut workloads = Vec::new();
    for block in suite
        .get("blocks")
        .and_then(Value::as_array)
        .ok_or("Missing cases")?
    {
        let fields = block.get("fields").ok_or("Missing fields")?;
        let Some(tags) = fields.get("etiquetas").and_then(Value::as_array) else {
            continue;
        };
        if tags.iter().any(|tag| tag.as_str() == Some("medicion")) {
            workloads.push(workload(fields, tags)?);
        }
    }
    if workloads.len() != 10 {
        return Err("Expected ten AWFY workloads".to_owned());
    }
    Ok(workloads)
}

fn workload(fields: &Value, tags: &[Value]) -> Result<Workload, String> {
    let name = tags
        .last()
        .and_then(Value::as_str)
        .ok_or("Missing workload name")?
        .to_owned();
    let request = ExecuteRequest {
        program: fields
            .get("programa")
            .and_then(Value::as_str)
            .ok_or("Missing source")?
            .to_owned(),
        inputs: serde_json::from_value(fields.get("entradas").cloned().ok_or("Missing inputs")?)
            .map_err(|error| error.to_string())?,
        ..Default::default()
    };
    let program =
        prepare_program(&request).map_err(|diagnostics| format!("{name}: {diagnostics:?}"))?;
    let output = fields
        .pointer("/espera/salida")
        .and_then(Value::as_str)
        .ok_or("Missing expectation")?
        .to_owned();
    Ok(Workload {
        name,
        request,
        program,
        output,
    })
}
