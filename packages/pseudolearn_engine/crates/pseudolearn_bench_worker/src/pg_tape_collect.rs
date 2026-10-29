use crate::pg_tape_loads::{EffectLoad, effect_loads, grows_linearly};
use pseudolearn_api::{ExecuteRequest, execute_prepared, prepare_program};
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::path::Path;
use std::time::Instant;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let [directory, process, machine] = arguments else {
        return Err("Usage: pg-tape <directory> <process> <machine>".to_owned());
    };
    let process: u64 = process.parse().map_err(|_| "Invalid process".to_owned())?;
    let mut records = Vec::new();
    for load in effect_loads() {
        records.push(measure(&load)?);
    }
    let linear = linearity(&records)?;
    let path = Path::new(directory).join(format!("tape-growth-{process:02}.json"));
    if path.exists() {
        return Err(format!("Refusing to overwrite {}", path.display()));
    }
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    let document =
        json!({"process": process, "machine": machine, "loads": records, "linear": linear});
    std::fs::write(&path, document.to_string()).map_err(|error| error.to_string())?;
    if linear.values().all(|holds| *holds) {
        Ok(())
    } else {
        Err(format!("Tape growth is not linear: {linear:?}"))
    }
}

pub fn measure(load: &EffectLoad) -> Result<Value, String> {
    let request = ExecuteRequest {
        program: load.source.clone(),
        host: Some(load.host.clone()),
        ..Default::default()
    };
    let program = prepare_program(&request).map_err(|diagnostics| format!("{diagnostics:?}"))?;
    let start = Instant::now();
    let response = execute_prepared(&program, &request);
    let nanoseconds = u64::try_from(start.elapsed().as_nanos()).unwrap_or(u64::MAX);
    if response.termination.get("kind").and_then(Value::as_str) != Some("completed") {
        return Err(format!(
            "{} {}: {:?}",
            load.name, load.count, response.termination
        ));
    }
    let tape = response.effect_tape.ok_or("Missing effect tape")?;
    let entries = tape
        .get("entries")
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    let tape_bytes = u64::try_from(tape.to_string().len()).unwrap_or(u64::MAX);
    let reproducible = tape.get("status").and_then(Value::as_str) == Some("reproducible");
    Ok(json!({
        "kind": load.name,
        "requested_effects": load.count,
        "recorded_entries": entries,
        "tape_bytes": tape_bytes,
        "reproducible": reproducible,
        "nanoseconds": nanoseconds,
    }))
}

pub fn linearity(records: &[Value]) -> Result<BTreeMap<String, bool>, String> {
    let mut series: BTreeMap<String, Vec<(u64, u64)>> = BTreeMap::new();
    for record in records {
        let kind = record
            .get("kind")
            .and_then(Value::as_str)
            .ok_or("Missing kind")?;
        let entries = record
            .get("recorded_entries")
            .and_then(Value::as_u64)
            .ok_or("Missing entries")?;
        let bytes = record
            .get("tape_bytes")
            .and_then(Value::as_u64)
            .ok_or("Missing bytes")?;
        series
            .entry(kind.to_owned())
            .or_default()
            .push((entries, bytes));
    }
    Ok(series
        .into_iter()
        .map(|(kind, points)| (kind, grows_linearly(&points)))
        .collect())
}
