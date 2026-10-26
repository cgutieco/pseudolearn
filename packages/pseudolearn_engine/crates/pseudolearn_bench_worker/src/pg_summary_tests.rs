use crate::pg_summary::summarize;
use serde_json::{Value, json};
use std::path::{Path, PathBuf};

fn scratch(label: &str) -> PathBuf {
    let path = std::env::temp_dir().join(format!("pg_summary_{label}_{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&path);
    path
}

fn sample(candidate: u64, control: u64, candidate_output: &str) -> Value {
    json!({
        "workload": "closure-call",
        "candidate_nanoseconds": candidate,
        "control_nanoseconds": control,
        "candidate_output": candidate_output,
        "control_output": "7",
        "stressed_output_matches": true
    })
}

fn write_workload(root: &Path, name: &str, candidate: u64, candidate_output: &str) {
    let folder = root.join(name);
    let _ = std::fs::create_dir_all(&folder);
    for process in 0..10_u64 {
        let record = json!({
            "process": process,
            "machine": "reference",
            "clock_resolution_nanoseconds": 1.0,
            "samples": vec![sample(candidate, 100, candidate_output); 30],
            "shape": {"candidate": {"object_bytes": 10}}
        });
        let _ = std::fs::write(
            folder.join(format!("process-{process:02}.json")),
            record.to_string(),
        );
    }
}

fn run(root: &Path) -> Result<Value, String> {
    summarize(&["E-PG-04".to_owned(), root.display().to_string()])?;
    let text =
        std::fs::read_to_string(root.join("summary.json")).map_err(|error| error.to_string())?;
    serde_json::from_str(&text).map_err(|error| error.to_string())
}

fn verdict(summary: &Value, index: usize) -> Option<bool> {
    summary
        .pointer(&format!("/workloads/{index}/within_threshold"))
        .and_then(Value::as_bool)
}

#[test]
fn indirect_call_within_threshold_passes() -> Result<(), String> {
    let root = scratch("pass");
    write_workload(&root, "closure-call", 110, "7");
    write_workload(&root, "closure-create", 300, "7");
    let summary = run(&root)?;
    assert_eq!(verdict(&summary, 0), Some(true));
    assert_eq!(verdict(&summary, 1), None);
    Ok(())
}

#[test]
fn indirect_call_just_above_threshold_is_reported_not_adjusted() -> Result<(), String> {
    let root = scratch("fail");
    write_workload(&root, "closure-call", 126, "7");
    write_workload(&root, "closure-create", 300, "7");
    assert_eq!(verdict(&run(&root)?, 0), Some(false));
    Ok(())
}

#[test]
fn a_wrong_output_invalidates_the_whole_campaign() {
    let root = scratch("wrong");
    write_workload(&root, "closure-call", 100, "8");
    write_workload(&root, "closure-create", 300, "7");
    assert!(run(&root).is_err());
}

#[test]
fn a_missing_workload_directory_is_an_error() {
    let root = scratch("missing");
    assert!(run(&root).is_err());
}
