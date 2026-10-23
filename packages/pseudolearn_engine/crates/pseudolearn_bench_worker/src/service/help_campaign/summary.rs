use crate::service::help_campaign::bootstrap::{
    change_points, confidence_interval, mean, mean_of_means, percentile, pooled_percentile,
};
use crate::service::help_campaign::digest::digest_text;
use crate::service::help_campaign::documents::SEED;
use crate::service::statistics::round;
use serde_json::{Value, json};
use std::path::{Path, PathBuf};

pub const CRITERION_P95_MS: f64 = 20.0;
pub const HOT_METRICS: [&str; 3] = ["api_ms", "core_ms", "render_ms"];
pub const COLD_METRICS: [&str; 2] = ["cold_ms", "first_in_series_ms"];

pub fn read_json(path: &Path) -> Result<Value, String> {
    let text =
        std::fs::read_to_string(path).map_err(|error| format!("{}: {error}", path.display()))?;
    serde_json::from_str(&text).map_err(|error| format!("{}: {error}", path.display()))
}

pub fn process_files(directory: &Path, series: &str) -> Result<Vec<PathBuf>, String> {
    let prefix = format!("{series}-process-");
    let mut files: Vec<PathBuf> = std::fs::read_dir(directory)
        .map_err(|error| format!("{}: {error}", directory.display()))?
        .filter_map(Result::ok)
        .map(|entry| entry.path())
        .filter(|path| {
            path.file_name()
                .and_then(|name| name.to_str())
                .is_some_and(|name| name.starts_with(&prefix) && name.ends_with(".json"))
        })
        .collect();
    files.sort();
    Ok(files)
}

pub fn samples_of(process: &Value, document: usize, metric: &str) -> Vec<f64> {
    process
        .pointer(&format!("/documents/{document}/{metric}"))
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_f64)
        .collect()
}

pub fn resolution_of(process: &Value) -> f64 {
    process
        .get("clock_resolution_ns")
        .and_then(Value::as_str)
        .and_then(|text| text.parse::<f64>().ok())
        .unwrap_or(0.0)
}

fn metric_summary(groups: &[Vec<f64>], resolution_ns: f64) -> Value {
    let pooled: Vec<f64> = groups.iter().flatten().copied().collect();
    let below = pooled
        .iter()
        .filter(|sample| **sample * 1_000_000.0 < resolution_ns)
        .count();
    let mean_interval = confidence_interval(groups, SEED, mean_of_means);
    let p95_interval =
        confidence_interval(groups, SEED, |resample| pooled_percentile(resample, 95));
    let points: Vec<Value> = groups
        .iter()
        .enumerate()
        .map(|(index, group)| json!({"process": index, "candidates": change_points(group)}))
        .collect();
    json!({
        "processes": groups.len(),
        "samples": pooled.len(),
        "median_ms": percentile(&pooled, 50).map(round),
        "p95_ms": pooled_percentile(groups, 95).map(round),
        "p95_ci95_ms": p95_interval.map(|(low, high)| [round(low), round(high)]),
        "mean_of_process_means_ms": mean_of_means(groups).map(round),
        "mean_ci95_ms": mean_interval.map(|(low, high)| [round(low), round(high)]),
        "minimum_ms": pooled.iter().copied().min_by(f64::total_cmp).map(round),
        "maximum_ms": pooled.iter().copied().max_by(f64::total_cmp).map(round),
        "below_clock_resolution": below,
        "mean_of_all_ms": mean(&pooled).map(round),
        "change_point_candidates": points,
    })
}

fn series_summary(directory: &Path, series: &str, metrics: &[&str]) -> Result<Value, String> {
    let processes: Vec<Value> = process_files(directory, series)?
        .iter()
        .map(|path| read_json(path))
        .collect::<Result<_, _>>()?;
    let resolution = processes.iter().map(resolution_of).fold(0.0_f64, f64::max);
    let documents = processes
        .first()
        .and_then(|process| process.get("documents"))
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    let mut report = Vec::new();
    for document in 0..documents {
        let name = processes
            .first()
            .and_then(|process| process.pointer(&format!("/documents/{document}/name")))
            .cloned()
            .unwrap_or(Value::Null);
        let mut entry = serde_json::Map::new();
        entry.insert("document".to_owned(), name);
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

pub fn raw_digests(directory: &Path) -> Result<Value, String> {
    let mut digests = serde_json::Map::new();
    for series in ["hot", "cold"] {
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
    let functional = read_json(&directory.join("functional/summary.json")).ok();
    let hot = series_summary(directory, "hot", &HOT_METRICS)?;
    let cold = series_summary(directory, "cold", &COLD_METRICS)?;
    let observed = hot
        .pointer("/documents")
        .and_then(Value::as_array)
        .and_then(|documents| documents.last())
        .and_then(|document| document.pointer("/api_ms/p95_ms"))
        .and_then(Value::as_f64);
    let core = hot
        .pointer("/documents")
        .and_then(Value::as_array)
        .and_then(|documents| documents.last())
        .and_then(|document| document.pointer("/core_ms/p95_ms"))
        .and_then(Value::as_f64);
    Ok(json!({
        "experiment": "E-PG-11",
        "seed": SEED,
        "bootstrap_resamples": crate::service::help_campaign::bootstrap::RESAMPLES,
        "candidate_criterion_p95_ms": CRITERION_P95_MS,
        "functional": functional,
        "hot": hot,
        "cold": cold,
        "large_document_p95_ms": {"api": observed, "core": core},
        "meets_candidate_criterion": observed.zip(core).is_some_and(|(api, core)| api <= CRITERION_P95_MS && core <= CRITERION_P95_MS),
    }))
}

pub fn write(directory: &str) -> Result<(), String> {
    let path = Path::new(directory);
    let summary = json!({
        "format": "e-pg-11-summary/1",
        "raw_digests": raw_digests(path)?,
        "body": body(path)?,
    });
    let text = serde_json::to_string_pretty(&summary).map_err(|error| error.to_string())?;
    std::fs::write(path.join("summary.json"), format!("{text}\n"))
        .map_err(|error| error.to_string())
}
