use crate::service::help_campaign::latency::ITERATIONS;
use crate::service::help_campaign::summary::{
    COLD_METRICS, HOT_METRICS, body, process_files, raw_digests, read_json, resolution_of,
    samples_of,
};
use serde_json::Value;
use std::path::Path;

pub const MINIMUM_PROCESSES: usize = 10;

pub fn invalidations(directory: &Path) -> Result<Vec<String>, String> {
    let mut problems = Vec::new();
    for (series, metrics) in [("hot", &HOT_METRICS[..]), ("cold", &COLD_METRICS[..1])] {
        let files = process_files(directory, series)?;
        if files.len() < MINIMUM_PROCESSES {
            problems.push(format!(
                "{series}: {} processes, {MINIMUM_PROCESSES} required",
                files.len()
            ));
        }
        for file in files {
            problems.extend(process_problems(&read_json(&file)?, series, metrics, &file));
        }
    }
    problems.extend(functional_problems(directory));
    Ok(problems)
}

fn process_problems(process: &Value, series: &str, metrics: &[&str], file: &Path) -> Vec<String> {
    let mut problems = Vec::new();
    let label = file.display();
    if resolution_of(process) <= 0.0 {
        problems.push(format!("{label}: clock resolution missing or zero"));
    }
    if process.get("series").and_then(Value::as_str) != Some(series) {
        problems.push(format!("{label}: series does not match its file"));
    }
    if process.get("seed").and_then(Value::as_u64)
        != Some(crate::service::help_campaign::documents::SEED)
    {
        problems.push(format!("{label}: unexpected seed"));
    }
    let documents = process
        .get("documents")
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    for document in 0..documents {
        for metric in metrics {
            let count = samples_of(process, document, metric).len();
            if count < ITERATIONS {
                problems.push(format!(
                    "{label}: document {document} {metric} has {count} samples"
                ));
            }
        }
    }
    problems
}

fn functional_problems(directory: &Path) -> Vec<String> {
    let Ok(summary) = read_json(&directory.join("functional/summary.json")) else {
        return vec!["functional campaign summary missing".to_owned()];
    };
    let mut problems = Vec::new();
    for transport in ["api", "lsp"] {
        let number = |key: &str| {
            summary
                .pointer(&format!("/transports/{transport}/{key}"))
                .and_then(Value::as_u64)
        };
        if number("expected") != number("completed") || number("expected").unwrap_or(0) == 0 {
            problems.push(format!(
                "{transport}: expected and completed queries differ or are empty"
            ));
        }
        if number("wrong") != Some(0) {
            problems.push(format!("{transport}: {:?} wrong answers", number("wrong")));
        }
    }
    if summary
        .pointer("/transports/lsp/parity_mismatches")
        .and_then(Value::as_u64)
        != Some(0)
    {
        problems.push("lsp: parity mismatches with the API".to_owned());
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
