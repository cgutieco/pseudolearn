use crate::service::help_campaign::digest::Digest;
use crate::service::help_campaign::latency::ITERATIONS;
use crate::service::workspace_campaign::case::Case;
use crate::service::workspace_campaign::scenario::Scenario;
use serde_json::{Value, json};
use std::path::Path;

pub const PROTOCOL: &str = "pg-service/1";
pub const BOUNDARY: &str = "pseudo-lsp-stdio";
pub const SEED: u64 = 42;

pub struct RecordInput<'input> {
    pub load: &'input str,
    pub scenario: Scenario,
    pub process: usize,
    pub machine: &'input str,
    pub resolution_nanos: u128,
    pub digest: String,
    pub candidate_millis: &'input [f64],
    pub control_millis: &'input [f64],
}

pub fn digest_of(case: &Case) -> String {
    let mut digest = Digest::new();
    for group in [
        &case.base_setup,
        &case.step,
        &case.cold_setup,
        &case.cold_step,
    ] {
        for message in group {
            digest.feed(message.to_string().as_bytes());
        }
    }
    digest.hex()
}

pub fn build(input: &RecordInput) -> Value {
    json!({
        "protocol": PROTOCOL,
        "boundary": BOUNDARY,
        "seed": SEED,
        "load": input.load,
        "scenario": input.scenario.name(),
        "process": input.process,
        "machine": input.machine,
        "clock_resolution_ns": input.resolution_nanos.to_string(),
        "case_digest": input.digest,
        "samples_ms": input.candidate_millis,
        "control_ms": input.control_millis,
        "equivalent": true,
    })
}

fn positive_samples(record: &Value, field: &str) -> Result<usize, String> {
    let samples = record
        .get(field)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("missing {field}"))?;
    let valid = samples.iter().all(|sample| {
        sample
            .as_f64()
            .is_some_and(|value| value.is_finite() && value >= 0.0)
    });
    if !valid {
        return Err(format!("{field} holds a negative or non-numeric sample"));
    }
    Ok(samples.len())
}

pub fn validate(record: &Value) -> Result<(), String> {
    if record.get("protocol").and_then(Value::as_str) != Some(PROTOCOL) {
        return Err("foreign protocol".to_owned());
    }
    if record.get("boundary").and_then(Value::as_str) != Some(BOUNDARY) {
        return Err("foreign measurement boundary".to_owned());
    }
    if record.get("seed").and_then(Value::as_u64) != Some(SEED) {
        return Err("foreign seed".to_owned());
    }
    let known = record
        .get("scenario")
        .and_then(Value::as_str)
        .and_then(Scenario::from_name);
    if known.is_none() {
        return Err("unknown scenario".to_owned());
    }
    let resolution = record
        .get("clock_resolution_ns")
        .and_then(Value::as_str)
        .and_then(|text| text.parse::<u128>().ok());
    if resolution.is_none_or(|nanos| nanos == 0) {
        return Err("clock resolution must be positive".to_owned());
    }
    if record.get("equivalent") != Some(&Value::Bool(true)) {
        return Err("candidate and cold control were not equivalent".to_owned());
    }
    for field in ["samples_ms", "control_ms"] {
        if positive_samples(record, field)? != ITERATIONS {
            return Err(format!("{field} must hold {ITERATIONS} samples"));
        }
    }
    Ok(())
}

pub fn write_new(path: &Path, record: &Value) -> Result<(), String> {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
    }
    let text = serde_json::to_string_pretty(record).map_err(|error| error.to_string())?;
    let mut file = std::fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(path)
        .map_err(|error| format!("{}: {error}", path.display()))?;
    std::io::Write::write_all(&mut file, text.as_bytes()).map_err(|error| error.to_string())
}
