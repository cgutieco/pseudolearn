use crate::service::workspace_campaign::comparison::{p95, within_threshold};
use crate::service::workspace_campaign::record::validate;
use crate::service::workspace_campaign::scenario::Scenario;
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};

pub const MIN_PROCESSES: usize = 10;

fn text<'record>(record: &'record Value, field: &str) -> &'record str {
    record.get(field).and_then(Value::as_str).unwrap_or("")
}

fn pooled(records: &[&Value], field: &str) -> Vec<f64> {
    records
        .iter()
        .filter_map(|record| record.get(field).and_then(Value::as_array))
        .flatten()
        .filter_map(Value::as_f64)
        .collect()
}

fn distinct(records: &[&Value], field: &str) -> BTreeSet<String> {
    records
        .iter()
        .map(|record| {
            record
                .get(field)
                .map_or_else(String::new, ToString::to_string)
        })
        .collect()
}

fn group_summary(key: &str, records: &[&Value]) -> Result<Value, String> {
    if distinct(records, "process").len() < MIN_PROCESSES {
        return Err(format!("{key}: fewer than {MIN_PROCESSES} processes"));
    }
    for field in ["case_digest", "machine"] {
        if distinct(records, field).len() != 1 {
            return Err(format!("{key}: mixed {field}"));
        }
    }
    let first = records.first().ok_or("empty group")?;
    let scenario = Scenario::from_name(text(first, "scenario")).ok_or("unknown scenario")?;
    let candidate = p95(&pooled(records, "samples_ms")).ok_or("no samples")?;
    let control = p95(&pooled(records, "control_ms")).ok_or("no control samples")?;
    Ok(json!({
        "group": key,
        "processes": distinct(records, "process").len(),
        "candidate_p95_ms": candidate,
        "cold_control_p95_ms": control,
        "threshold_ms": scenario.threshold_millis(),
        "within_threshold": within_threshold(scenario, candidate),
    }))
}

pub fn summarize(records: &[Value]) -> Result<Value, String> {
    let mut groups: BTreeMap<String, Vec<&Value>> = BTreeMap::new();
    for record in records {
        validate(record)?;
        let key = format!("{}/{}", text(record, "load"), text(record, "scenario"));
        groups.entry(key).or_default().push(record);
    }
    if groups.is_empty() {
        return Err("no records to summarize".to_owned());
    }
    let summaries: Result<Vec<Value>, String> = groups
        .iter()
        .map(|(key, members)| group_summary(key, members))
        .collect();
    let summaries = summaries?;
    let passed = summaries
        .iter()
        .all(|group| group.get("within_threshold") != Some(&Value::Bool(false)));
    Ok(json!({"protocol": "pg-service/1", "groups": summaries, "all_within_threshold": passed}))
}
