use crate::service::help_campaign::bootstrap::{
    RESAMPLES, confidence_interval, mean, mean_of_means,
};
use crate::service::help_campaign::digest::digest_text;
use crate::service::help_campaign::documents::SEED;
use crate::service::help_campaign::summary::{
    metric_summary, process_files, read_json, resolution_of, samples_of,
};
use crate::service::project_campaign::catalogue::PROTOCOL;
use crate::service::statistics::round;
use serde_json::{Value, json};
use std::path::Path;

pub const SERIES: [(&str, &[&str]); 3] = [
    ("profiles", &["analyze_ms", "execute_ms"]),
    ("project", &["analyze_ms"]),
    ("resolution", &["build_ms", "resolve_ms"]),
];
const PROFILE_PAIRS: [(usize, usize); 2] = [(0, 1), (2, 3)];

pub fn processes_of(directory: &Path, series: &str) -> Result<Vec<Value>, String> {
    process_files(directory, series)?
        .iter()
        .map(|path| read_json(path))
        .collect()
}

fn series_summary(directory: &Path, series: &str, metrics: &[&str]) -> Result<Value, String> {
    let processes = processes_of(directory, series)?;
    let resolution = processes.iter().map(resolution_of).fold(0.0_f64, f64::max);
    let documents = processes
        .first()
        .and_then(|process| process.get("documents"))
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    let mut report = Vec::new();
    for document in 0..documents {
        let mut entry = serde_json::Map::new();
        let name = processes
            .first()
            .and_then(|process| process.pointer(&format!("/documents/{document}/name")))
            .cloned()
            .unwrap_or(Value::Null);
        let lines = processes
            .first()
            .and_then(|process| process.pointer(&format!("/documents/{document}/lines")))
            .cloned()
            .unwrap_or(Value::Null);
        entry.insert("document".to_owned(), name);
        entry.insert("size".to_owned(), lines);
        for metric in metrics {
            let groups: Vec<Vec<f64>> = processes
                .iter()
                .map(|process| samples_of(process, document, metric))
                .collect();
            entry.insert((*metric).to_owned(), metric_summary(&groups, resolution));
        }
        report.push(Value::Object(entry));
    }
    Ok(
        json!({"processes": processes.len(), "clock_resolution_ns": resolution, "documents": report}),
    )
}

fn control_ratios(directory: &Path) -> Result<Value, String> {
    let processes = processes_of(directory, "profiles")?;
    let mut ratios = Vec::new();
    for (mixed, control) in PROFILE_PAIRS {
        for metric in SERIES[0].1 {
            let per_process: Vec<Vec<f64>> = processes
                .iter()
                .filter_map(|process| {
                    let top = mean(&samples_of(process, mixed, metric))?;
                    let bottom = mean(&samples_of(process, control, metric))?;
                    (bottom > 0.0).then(|| vec![top / bottom])
                })
                .collect();
            let interval = confidence_interval(&per_process, SEED, mean_of_means);
            ratios.push(json!({
                "mixed_document": mixed, "control_document": control, "metric": metric,
                "mean_ratio": mean_of_means(&per_process).map(round),
                "ci95": interval.map(|(low, high)| [round(low), round(high)]),
            }));
        }
    }
    Ok(json!(ratios))
}

pub fn raw_digests(directory: &Path) -> Result<Value, String> {
    let mut digests = serde_json::Map::new();
    for (series, _) in SERIES {
        for path in process_files(directory, series)? {
            let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
            let name = path
                .file_name()
                .and_then(|name| name.to_str())
                .unwrap_or_default();
            digests.insert(name.to_owned(), json!(digest_text(&text)));
        }
    }
    for name in ["functional/summary.json", "functional/failures.json"] {
        if let Ok(text) = std::fs::read_to_string(directory.join(name)) {
            digests.insert(name.to_owned(), json!(digest_text(&text)));
        }
    }
    Ok(Value::Object(digests))
}

pub fn body(directory: &Path) -> Result<Value, String> {
    let mut series = serde_json::Map::new();
    for (name, metrics) in SERIES {
        series.insert(name.to_owned(), series_summary(directory, name, metrics)?);
    }
    Ok(json!({
        "experiment": "E-PG-01 and project part of E-PG-02",
        "protocol": PROTOCOL,
        "seed": SEED,
        "bootstrap_resamples": RESAMPLES,
        "functional": read_json(&directory.join("functional/summary.json")).ok(),
        "series": series,
        "profile_control_ratios": control_ratios(directory)?,
        "incremental_latency": {
            "status": "not measurable",
            "reason": "no incremental project API exists; the cases report full reanalysis",
        },
        "candidate_budgets": {
            "contracts": false,
            "note": "observed values only; the person reviews budgets later",
        },
    }))
}

pub fn write(directory: &str) -> Result<(), String> {
    let path = Path::new(directory);
    let summary = json!({
        "format": "e-pg-13-summary/1",
        "raw_digests": raw_digests(path)?,
        "body": body(path)?,
    });
    let text = serde_json::to_string_pretty(&summary).map_err(|error| error.to_string())?;
    std::fs::write(path.join("summary.json"), format!("{text}\n"))
        .map_err(|error| error.to_string())
}
