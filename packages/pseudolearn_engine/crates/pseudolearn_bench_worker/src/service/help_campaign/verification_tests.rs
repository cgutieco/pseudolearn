use crate::service::help_campaign::summary::write;
use crate::service::help_campaign::verification::verify;
use serde_json::{Value, json};
use std::path::{Path, PathBuf};

fn directory(name: &str) -> Result<PathBuf, String> {
    let path = std::env::temp_dir().join(format!("e-pg-11-{}-{name}", std::process::id()));
    let _ = std::fs::remove_dir_all(&path);
    std::fs::create_dir_all(path.join("functional")).map_err(|error| error.to_string())?;
    Ok(path)
}

fn process(series: &str, index: usize, samples: usize, resolution: &str) -> Value {
    let values: Vec<f64> = (0..samples)
        .map(|step| 0.5 + f64::from(u32::try_from(step).unwrap_or(0)) * 0.001)
        .collect();
    let metrics: &[&str] = if series == "hot" {
        &["api_ms", "core_ms", "render_ms"]
    } else {
        &["cold_ms", "first_in_series_ms"]
    };
    let mut document = serde_json::Map::new();
    document.insert("name".to_owned(), json!("synthetic"));
    for metric in metrics {
        document.insert((*metric).to_owned(), json!(values));
    }
    json!({
        "format": "e-pg-11-process/1", "series": series, "process": index.to_string(),
        "seed": 42, "iterations": 30, "clock_resolution_ns": resolution,
        "documents": [document.clone(), document],
    })
}

fn functional(wrong: u64, completed: u64) -> Value {
    let transport = |wrong: u64| json!({"expected": 100, "completed": completed, "wrong": wrong, "parity_mismatches": 0});
    json!({"transports": {"api": transport(wrong), "lsp": transport(0)}})
}

fn write_campaign(
    path: &Path,
    processes: usize,
    samples: usize,
    resolution: &str,
    summary: Value,
) -> Result<(), String> {
    for series in ["hot", "cold"] {
        for index in 0..processes {
            let text = serde_json::to_string(&process(series, index, samples, resolution))
                .map_err(|error| error.to_string())?;
            std::fs::write(path.join(format!("{series}-process-{index:02}.json")), text)
                .map_err(|error| error.to_string())?;
        }
    }
    let text = serde_json::to_string(&summary).map_err(|error| error.to_string())?;
    std::fs::write(path.join("functional/summary.json"), text)
        .map_err(|error| error.to_string())?;
    write(&path.to_string_lossy())
}

fn reject(path: &Path, needle: &str) -> Result<(), String> {
    match verify(&path.to_string_lossy()) {
        Ok(()) => Err(format!("expected a rejection mentioning {needle}")),
        Err(message) if message.contains(needle) => Ok(()),
        Err(message) => Err(format!("wrong rejection: {message}")),
    }
}

#[test]
fn a_complete_unaltered_campaign_verifies() -> Result<(), String> {
    let path = directory("valid")?;
    write_campaign(&path, 10, 30, "41", functional(0, 100))?;
    verify(&path.to_string_lossy())
}

#[test]
fn a_wrong_answer_invalidates_the_campaign() -> Result<(), String> {
    let path = directory("wrong")?;
    write_campaign(&path, 10, 30, "41", functional(1, 100))?;
    reject(&path, "wrong answers")
}

#[test]
fn a_missing_sample_invalidates_the_campaign() -> Result<(), String> {
    let path = directory("missing")?;
    write_campaign(&path, 10, 29, "41", functional(0, 100))?;
    reject(&path, "samples")
}

#[test]
fn fewer_than_ten_processes_invalidate_the_campaign() -> Result<(), String> {
    let path = directory("few")?;
    write_campaign(&path, 9, 30, "41", functional(0, 100))?;
    reject(&path, "required")
}

#[test]
fn a_clock_without_resolution_invalidates_the_campaign() -> Result<(), String> {
    let path = directory("clock")?;
    write_campaign(&path, 10, 30, "0", functional(0, 100))?;
    reject(&path, "clock resolution")
}

#[test]
fn queries_that_were_never_completed_invalidate_the_campaign() -> Result<(), String> {
    let path = directory("incomplete")?;
    write_campaign(&path, 10, 30, "41", functional(0, 99))?;
    reject(&path, "differ or are empty")
}

#[test]
fn an_altered_summary_is_detected() -> Result<(), String> {
    let path = directory("summary")?;
    write_campaign(&path, 10, 30, "41", functional(0, 100))?;
    let stored =
        std::fs::read_to_string(path.join("summary.json")).map_err(|error| error.to_string())?;
    let altered = stored.replace(
        "\"meets_candidate_criterion\": true",
        "\"meets_candidate_criterion\": false",
    );
    assert_ne!(stored, altered);
    std::fs::write(path.join("summary.json"), altered).map_err(|error| error.to_string())?;
    reject(&path, "recomputation")
}

#[test]
fn an_altered_raw_sample_is_detected_by_its_digest() -> Result<(), String> {
    let path = directory("raw")?;
    write_campaign(&path, 10, 30, "41", functional(0, 100))?;
    let file = path.join("hot-process-00.json");
    let stored = std::fs::read_to_string(&file).map_err(|error| error.to_string())?;
    std::fs::write(&file, stored.replacen("0.5,", "0.4,", 1)).map_err(|error| error.to_string())?;
    reject(&path, "digests")
}

#[test]
fn a_missing_functional_summary_invalidates_the_campaign() -> Result<(), String> {
    let path = directory("nofunctional")?;
    write_campaign(&path, 10, 30, "41", functional(0, 100))?;
    std::fs::remove_file(path.join("functional/summary.json"))
        .map_err(|error| error.to_string())?;
    reject(&path, "functional campaign summary missing")
}
