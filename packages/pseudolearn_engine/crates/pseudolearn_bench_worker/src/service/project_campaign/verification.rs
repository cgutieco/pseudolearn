use crate::service::help_campaign::documents::SEED;
use crate::service::help_campaign::latency::ITERATIONS;
use crate::service::help_campaign::summary::{read_json, resolution_of, samples_of};
use crate::service::project_campaign::catalogue::PROTOCOL;
use crate::service::project_campaign::summary::{SERIES, body, processes_of, raw_digests};
use serde_json::Value;
use std::collections::BTreeSet;
use std::path::Path;

pub const MINIMUM_PROCESSES: usize = 10;

pub fn invalidations(directory: &Path) -> Result<Vec<String>, String> {
    let functional = read_json(&directory.join("functional/summary.json")).ok();
    let mut problems = functional_problems(functional.as_ref());
    let mut machines = BTreeSet::new();
    for (series, metrics) in SERIES {
        let processes = processes_of(directory, series)?;
        if processes.len() < MINIMUM_PROCESSES {
            problems.push(format!(
                "{series}: {} processes, {MINIMUM_PROCESSES} required",
                processes.len()
            ));
        }
        for process in &processes {
            problems.extend(process_problems(
                process,
                series,
                metrics,
                functional.as_ref(),
            ));
            machines.insert(text_of(process, "machine"));
        }
    }
    if machines.len() > 1 {
        problems.push(format!("measurements mix machines: {machines:?}"));
    }
    Ok(problems)
}

fn text_of(value: &Value, key: &str) -> String {
    value
        .get(key)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn process_problems(
    process: &Value,
    series: &str,
    metrics: &[&str],
    functional: Option<&Value>,
) -> Vec<String> {
    let mut problems = Vec::new();
    let label = format!("{series} process {}", text_of(process, "process"));
    if resolution_of(process) <= 0.0 {
        problems.push(format!("{label}: clock resolution missing or zero"));
    }
    if text_of(process, "series") != series {
        problems.push(format!("{label}: series does not match its file"));
    }
    if text_of(process, "protocol") != PROTOCOL {
        problems.push(format!("{label}: protocol differs from {PROTOCOL}"));
    }
    if process.get("seed").and_then(Value::as_u64) != Some(SEED) {
        problems.push(format!("{label}: unexpected seed"));
    }
    let recorded = functional
        .and_then(|summary| summary.get("dataset_digest"))
        .and_then(Value::as_str);
    if recorded != process.get("dataset_digest").and_then(Value::as_str) {
        problems.push(format!(
            "{label}: dataset digest differs from the functional campaign"
        ));
    }
    problems.extend(sample_problems(process, metrics, &label));
    problems
}

fn sample_problems(process: &Value, metrics: &[&str], label: &str) -> Vec<String> {
    let documents = process
        .get("documents")
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    let mut problems = Vec::new();
    if documents == 0 {
        problems.push(format!("{label}: no documents"));
    }
    for document in 0..documents {
        for metric in metrics {
            let samples = samples_of(process, document, metric);
            if samples.len() != ITERATIONS {
                problems.push(format!(
                    "{label}: document {document} {metric} has {} samples",
                    samples.len()
                ));
            }
            if samples.iter().any(|sample| *sample <= 0.0) {
                problems.push(format!(
                    "{label}: document {document} {metric} has a non-positive sample"
                ));
            }
        }
    }
    problems
}

fn functional_problems(summary: Option<&Value>) -> Vec<String> {
    let Some(summary) = summary else {
        return vec!["functional campaign summary missing".to_owned()];
    };
    let mut problems = Vec::new();
    if summary.get("programs").and_then(Value::as_u64).unwrap_or(0) == 0 {
        problems.push("functional campaign has an empty dataset".to_owned());
    }
    if summary.get("failure_count").and_then(Value::as_u64) != Some(0) {
        problems.push("functional campaign has failures".to_owned());
    }
    if text_of(summary, "protocol") != PROTOCOL {
        problems.push("functional campaign protocol differs".to_owned());
    }
    problems
}

pub fn verify(directory: &str) -> Result<(), String> {
    let path = Path::new(directory);
    let stored = read_json(&path.join("summary.json"))?;
    let mut problems = invalidations(path)?;
    if stored.get("raw_digests") != Some(&raw_digests(path)?) {
        problems.push("raw files differ from the digests recorded in the summary".to_owned());
    }
    if stored.get("body") != Some(&body(path)?) {
        problems.push("the summary does not match a recomputation from the raw files".to_owned());
    }
    if problems.is_empty() {
        Ok(())
    } else {
        Err(format!("Campaign invalid:\n{}", problems.join("\n")))
    }
}
