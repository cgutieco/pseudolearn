use crate::service::measurement_file::{Measurement, entry, record};
use crate::service::statistics::summarize;
use crate::service::thresholds::threshold;
use pseudolearn_api::service::{DocumentSession, Position, Profile, Range, TextEdit};
use serde_json::{Value, json};
use std::time::Instant;

const SPECIFICATION: &str = "TOOL.SERVICE.INCREMENTAL";

fn edit_at(line: u32, original: &str, replacement: &str) -> (TextEdit, TextEdit) {
    let width = u32::try_from(original.len()).unwrap_or(1);
    let range = |length: u32| Range {
        start: Position { line, column: 1 },
        end: Position {
            line,
            column: 1_u32.saturating_add(length),
        },
    };
    (
        TextEdit {
            range: range(width),
            new_text: replacement.to_owned(),
        },
        TextEdit {
            range: range(u32::try_from(replacement.len()).unwrap_or(1)),
            new_text: original.to_owned(),
        },
    )
}

fn measure(workload_name: &str) -> Result<(Value, f64), String> {
    let workload = crate::workloads::load()?
        .into_iter()
        .find(|entry| entry.name == workload_name)
        .ok_or_else(|| format!("Missing workload {workload_name}"))?;
    let program = workload
        .requests
        .first()
        .map(|request| request.program.clone())
        .ok_or("Empty workload")?;
    let mut session = DocumentSession::new(program, Profile::Spanish, true);
    let (forward, backward) = edit_at(
        10,
        "accumulator <- accumulator + 1;",
        "accumulator <- accumulator + 2;",
    );
    let mut samples = Vec::new();
    for round in 0..60 {
        let change = if round % 2 == 0 { &forward } else { &backward };
        let started = Instant::now();
        let report = session.apply_text_edits(std::slice::from_ref(change));
        samples.push(started.elapsed().as_secs_f64() * 1000.0);
        if report.affected_count == 0 && report.unchanged_count == 0 {
            return Err("Edit did not reach the document".to_owned());
        }
    }
    let summary = summarize(samples.get(2..).unwrap_or(&samples)).ok_or("No samples")?;
    Ok((
        json!({ "lines": workload.lines, "update_ms": summary.to_json() }),
        summary.p95,
    ))
}

pub fn run(output: &str, measurements_path: &str) -> Result<(), String> {
    let (small, small_p95) = measure("generated-es-strict-1000-false")?;
    let (large, large_p95) = measure("generated-es-strict-10000-false")?;
    let limit = threshold(SPECIFICATION, "M1")?;
    let passed = large_p95 <= limit;
    let report = json!({
        "experiment": "service-incremental-latency",
        "status": if passed { "passed" } else { "failed" },
        "machine": crate::service::corpus::machine_description(),
        "protocol": "PERF.PROTOCOL#R1",
        "threshold_p95_ms_10000_lines": limit,
        "documents": { "1000": small, "10000": large },
        "observed_p95_ms": { "1000": small_p95, "10000": large_p95 },
    });
    let text = serde_json::to_string_pretty(&report).map_err(|error| error.to_string())?;
    std::fs::write(output, format!("{text}\n")).map_err(|error| error.to_string())?;
    record(
        measurements_path,
        vec![entry(
            &Measurement {
                reference: "TOOL.SERVICE.INCREMENTAL@0.1.0#M1",
                metric: "latencia_p95",
                unit: "milisegundos",
                comparator: "<=",
            },
            (limit, large_p95),
        )],
    )?;
    if passed {
        Ok(())
    } else {
        Err(format!("Incremental latency above {limit} ms: {large_p95}"))
    }
}
