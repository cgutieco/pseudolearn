use crate::service::project_campaign::summary::{SERIES, write};
use crate::service::project_campaign::verification::{invalidations, verify};
use serde_json::{Value, json};
use std::path::{Path, PathBuf};

fn directory(name: &str) -> Result<PathBuf, String> {
    let path = std::env::temp_dir().join(format!("e-pg-13-{}-{name}", std::process::id()));
    let _ = std::fs::remove_dir_all(&path);
    std::fs::create_dir_all(path.join("functional")).map_err(|error| error.to_string())?;
    Ok(path)
}

fn process(series: &str, metrics: &[&str], index: usize, samples: usize) -> Value {
    let values: Vec<f64> = (0..samples)
        .map(|step| 0.5 + f64::from(u32::try_from(step).unwrap_or(0)) * 0.001)
        .collect();
    let documents: Vec<Value> = (0..4)
        .map(|document| {
            let mut fields = serde_json::Map::new();
            fields.insert("name".to_owned(), json!(format!("document-{document}")));
            fields.insert("lines".to_owned(), json!(10));
            for metric in metrics {
                fields.insert((*metric).to_owned(), json!(values));
            }
            Value::Object(fields)
        })
        .collect();
    json!({
        "format": "e-pg-13-process/1", "protocol": "e-pg-13/1", "machine": "test-machine",
        "dataset_digest": "digest", "series": series, "process": index.to_string(),
        "seed": 42, "iterations": 30, "clock_resolution_ns": "41", "documents": documents,
    })
}

fn put(path: &Path, value: &Value) -> Result<(), String> {
    std::fs::write(path, value.to_string()).map_err(|error| error.to_string())
}

fn write_campaign(path: &Path, processes: usize) -> Result<(), String> {
    let summary = json!({"protocol": "e-pg-13/1", "programs": 3, "dataset_digest": "digest", "failure_count": 0});
    put(&path.join("functional/summary.json"), &summary)?;
    put(&path.join("functional/failures.json"), &json!([]))?;
    for (series, metrics) in SERIES {
        for index in 0..processes {
            let file = path.join(format!("{series}-process-{index:02}.json"));
            put(&file, &process(series, metrics, index, 30))?;
        }
    }
    write(&path.display().to_string())
}

fn edit(path: &Path, name: &str, change: impl Fn(&mut Value)) -> Result<(), String> {
    let text = std::fs::read_to_string(path.join(name)).map_err(|error| error.to_string())?;
    let mut value: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    change(&mut value);
    put(&path.join(name), &value)
}

fn reasons(path: &Path) -> Result<String, String> {
    Ok(invalidations(path)?.join("\n"))
}

#[test]
fn a_complete_campaign_verifies_and_survives_recomputation() -> Result<(), String> {
    let path = directory("valid")?;
    write_campaign(&path, 10)?;
    verify(&path.display().to_string())
}

#[test]
fn a_missing_process_is_invalid() -> Result<(), String> {
    let path = directory("process")?;
    write_campaign(&path, 9)?;
    assert!(reasons(&path)?.contains("9 processes"));
    assert!(verify(&path.display().to_string()).is_err());
    Ok(())
}

#[test]
fn a_missing_sample_is_invalid() -> Result<(), String> {
    let path = directory("sample")?;
    write_campaign(&path, 10)?;
    edit(&path, "project-process-03.json", |value| {
        if let Some(samples) = value
            .pointer_mut("/documents/1/analyze_ms")
            .and_then(Value::as_array_mut)
        {
            samples.pop();
        }
    })?;
    assert!(reasons(&path)?.contains("29 samples"));
    Ok(())
}

#[test]
fn altered_raw_samples_no_longer_match_the_summary() -> Result<(), String> {
    let path = directory("altered")?;
    write_campaign(&path, 10)?;
    edit(&path, "profiles-process-00.json", |value| {
        if let Some(sample) = value.pointer_mut("/documents/0/analyze_ms/0") {
            *sample = json!(9.0);
        }
    })?;
    let verdict = verify(&path.display().to_string());
    assert!(
        verdict
            .is_err_and(|message| message.contains("digests") && message.contains("recomputation"))
    );
    Ok(())
}

#[test]
fn mixed_machines_and_protocols_are_invalid() -> Result<(), String> {
    let path = directory("mixed")?;
    write_campaign(&path, 10)?;
    edit(&path, "project-process-01.json", |value| {
        value["machine"] = json!("other-machine")
    })?;
    edit(&path, "resolution-process-02.json", |value| {
        value["protocol"] = json!("e-pg-13/2")
    })?;
    let message = reasons(&path)?;
    assert!(message.contains("mix machines") && message.contains("protocol differs"));
    Ok(())
}

#[test]
fn time_below_the_clock_resolution_and_a_zero_clock_are_invalid() -> Result<(), String> {
    let path = directory("clock")?;
    write_campaign(&path, 10)?;
    edit(&path, "profiles-process-04.json", |value| {
        value["clock_resolution_ns"] = json!("0")
    })?;
    edit(&path, "project-process-05.json", |value| {
        if let Some(sample) = value.pointer_mut("/documents/2/analyze_ms/7") {
            *sample = json!(0.0);
        }
    })?;
    let message = reasons(&path)?;
    assert!(message.contains("clock resolution") && message.contains("non-positive"));
    Ok(())
}

#[test]
fn an_empty_or_failing_functional_campaign_never_turns_green() -> Result<(), String> {
    let path = directory("functional")?;
    write_campaign(&path, 10)?;
    edit(&path, "functional/summary.json", |value| {
        value["programs"] = json!(0);
        value["failure_count"] = json!(2);
    })?;
    let message = reasons(&path)?;
    assert!(message.contains("empty dataset") && message.contains("has failures"));
    Ok(())
}

#[test]
fn a_dataset_that_differs_from_the_functional_campaign_is_invalid() -> Result<(), String> {
    let path = directory("digest")?;
    write_campaign(&path, 10)?;
    edit(&path, "resolution-process-00.json", |value| {
        value["dataset_digest"] = json!("other")
    })?;
    assert!(reasons(&path)?.contains("dataset digest differs"));
    Ok(())
}
