use serde_json::{Value, json};
use std::path::Path;

pub fn collect() -> Result<(), String> {
    let output = Path::new("../results/e02");
    std::fs::create_dir_all(output).map_err(|error| error.to_string())?;
    save(output, "capture.json", &crate::capture::provenance()?)?;
    crate::capture::command("cargo", &["build", "--release", "-p", "ceiling_runner"])?;
    let mut records = Vec::new();
    let mut metrics = Vec::new();
    for process in 0..10 {
        eprintln!("E-02: process {process}/10");
        let result = std::process::Command::new("/usr/bin/time")
            .args(["-lp", "target/release/ceiling", "run"])
            .output()
            .map_err(|error| error.to_string())?;
        if !result.status.success() {
            return Err(String::from_utf8_lossy(&result.stderr).into_owned());
        }
        append(
            &String::from_utf8_lossy(&result.stdout),
            process,
            &mut records,
        )?;
        metrics.push(json!({"process": process,
            "timeMetrics": String::from_utf8_lossy(&result.stderr)}));
        save(output, "raw.json", &json!(records))?;
    }
    save(output, "processes.json", &json!(metrics))?;
    crate::report::write(output)
}

fn append(text: &str, process: u32, records: &mut Vec<Value>) -> Result<(), String> {
    let mut rows = Vec::new();
    for line in text.lines() {
        let mut row: Value = serde_json::from_str(line).map_err(|error| error.to_string())?;
        row.as_object_mut()
            .ok_or("Expected sample object")?
            .insert("process".to_owned(), json!(process));
        rows.push(row);
    }
    if rows.len() != 1200 {
        return Err("Incomplete E-02 process".to_owned());
    }
    records.extend(rows);
    Ok(())
}

pub fn save(output: &Path, name: &str, value: &Value) -> Result<(), String> {
    let bytes = serde_json::to_vec_pretty(value).map_err(|error| error.to_string())?;
    std::fs::write(output.join(name), bytes).map_err(|error| error.to_string())
}
