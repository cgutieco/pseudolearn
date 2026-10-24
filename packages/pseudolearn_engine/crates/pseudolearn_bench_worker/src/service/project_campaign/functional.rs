use crate::service::help_campaign::digest::Digest;
use crate::service::help_campaign::documents::SEED;
use crate::service::project_campaign::catalogue::{Case, PROTOCOL, entries};
use crate::service::project_campaign::datasets::Dataset;
use crate::service::project_campaign::profiles::{modules_dataset, pairs_dataset};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub struct Report {
    pub programs: usize,
    pub digest: String,
    pub failures: Vec<String>,
}

pub fn all_datasets() -> Vec<Dataset> {
    let mut found = vec![
        modules_dataset(true),
        modules_dataset(false),
        pairs_dataset(true),
        pairs_dataset(false),
    ];
    for entry in entries() {
        if entry.case == Case::Cold {
            found.push(entry.base());
        } else if entry.count < 1000 && entry.case != Case::Same {
            found.push(entry.edited());
        }
    }
    found
}

pub fn judge(dataset: &Dataset) -> Option<String> {
    let mut session = ApiSession::default();
    let response = session.call("execute_project", &dataset.arguments("1"));
    let Some(value) = response.get("value") else {
        return Some(format!("{}: call failed: {response}", dataset.name));
    };
    let clean = value
        .get("diagnostics")
        .and_then(Value::as_array)
        .is_some_and(Vec::is_empty)
        && value
            .get("project_errors")
            .and_then(Value::as_array)
            .is_some_and(Vec::is_empty);
    let output = value.get("output").and_then(Value::as_str).unwrap_or("");
    let completed = value.pointer("/termination/kind").and_then(Value::as_str) == Some("completed");
    if clean && completed && output == dataset.expected_output {
        return None;
    }
    Some(format!(
        "{}: expected {:?}, got {output:?} (clean: {clean}, completed: {completed})",
        dataset.name, dataset.expected_output
    ))
}

pub fn run() -> Report {
    let datasets = all_datasets();
    let mut digest = Digest::new();
    let mut failures = Vec::new();
    for dataset in &datasets {
        dataset.digest(&mut digest);
        failures.extend(judge(dataset));
    }
    failures.extend(control_mismatches());
    Report {
        programs: datasets.len(),
        digest: digest.hex(),
        failures,
    }
}

fn control_mismatches() -> Vec<String> {
    let pairs = [
        (modules_dataset(true), modules_dataset(false)),
        (pairs_dataset(true), pairs_dataset(false)),
    ];
    pairs
        .iter()
        .filter(|(mixed, control)| mixed.expected_output != control.expected_output)
        .map(|(mixed, control)| format!("{} and {} disagree", mixed.name, control.name))
        .collect()
}

pub fn write_new(path: &str, value: &Value) -> Result<(), String> {
    if std::path::Path::new(path).exists() {
        return Err(format!(
            "{path} already exists; campaigns are never overwritten"
        ));
    }
    let text = serde_json::to_string_pretty(value).map_err(|error| error.to_string())?;
    std::fs::write(path, format!("{text}\n")).map_err(|error| error.to_string())
}

pub fn write(directory: &str) -> Result<(), String> {
    let report = run();
    let folder = format!("{directory}/functional");
    std::fs::create_dir_all(&folder).map_err(|error| error.to_string())?;
    let summary = json!({
        "format": "e-pg-13-functional/1",
        "protocol": PROTOCOL,
        "programs": report.programs,
        "dataset_digest": report.digest,
        "seed": SEED,
        "failure_count": report.failures.len(),
    });
    write_new(&format!("{folder}/summary.json"), &summary)?;
    write_new(&format!("{folder}/failures.json"), &json!(report.failures))?;
    if report.failures.is_empty() {
        Ok(())
    } else {
        Err(format!(
            "{} functional failures; see {folder}/failures.json",
            report.failures.len()
        ))
    }
}
