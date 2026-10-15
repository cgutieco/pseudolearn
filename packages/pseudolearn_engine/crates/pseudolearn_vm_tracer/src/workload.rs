#![forbid(unsafe_code)]

use std::fs;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Workload {
    pub identifier: String,
    pub source: String,
    pub expected_output: String,
}

pub fn load_workload(path: &str, identifier: &str) -> Result<Workload, String> {
    let content = fs::read_to_string(path).map_err(|error| error.to_string())?;
    let document: serde_json::Value =
        serde_json::from_str(&content).map_err(|error| error.to_string())?;
    let entries = document
        .get("workloads")
        .and_then(serde_json::Value::as_array)
        .ok_or_else(|| "workload list is missing".to_owned())?;
    let entry = entries
        .iter()
        .find(|entry| entry.get("id").and_then(serde_json::Value::as_str) == Some(identifier))
        .ok_or_else(|| "workload identifier is missing".to_owned())?;
    parse_workload(entry)
}

fn parse_workload(entry: &serde_json::Value) -> Result<Workload, String> {
    let identifier = required_string(entry, "id")?;
    let source = required_string(entry, "source")?;
    let expected_output = required_string(entry, "expectedOutput")?;
    let inputs = entry
        .get("inputs")
        .and_then(serde_json::Value::as_array)
        .ok_or_else(|| "workload inputs are missing".to_owned())?;
    if !inputs.is_empty() {
        return Err("VM tracer workloads must not require external input".to_owned());
    }
    Ok(Workload {
        identifier,
        source,
        expected_output,
    })
}

fn required_string(entry: &serde_json::Value, field: &str) -> Result<String, String> {
    entry
        .get(field)
        .and_then(serde_json::Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("workload field {field} is missing"))
}
