use crate::service::workspace_campaign::comparison::{p95, within_threshold};
use crate::service::workspace_campaign::record::validate;
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::selection::Selection;
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

fn collect_groups<'record>(
    records: &'record [Value],
    selection: &Selection,
) -> Result<BTreeMap<String, Vec<&'record Value>>, String> {
    let mut groups: BTreeMap<String, Vec<&Value>> = BTreeMap::new();
    for record in records {
        if selection.is_partial() {
            let load = text(record, "load");
            let scenario = text(record, "scenario");
            if Scenario::from_name(scenario).is_some_and(|value| !selection.includes(load, value)) {
                continue;
            }
        }
        validate(record)?;
        let key = format!("{}/{}", text(record, "load"), text(record, "scenario"));
        groups.entry(key).or_default().push(record);
    }
    if groups.is_empty() {
        return Err("no records to summarize".to_owned());
    }
    Ok(groups)
}

fn expected_group_names(selection: &Selection) -> BTreeSet<String> {
    selection
        .expected_groups()
        .into_iter()
        .map(|(load, scenario)| format!("{}/{}", load.name, scenario.name()))
        .collect()
}

fn validate_group_names(
    expected: &BTreeSet<String>,
    included: &BTreeSet<String>,
) -> Result<(), String> {
    if expected == included {
        return Ok(());
    }
    let missing = expected.difference(included).next();
    Err(missing.map_or_else(
        || "summary contains groups outside its selection".to_owned(),
        |group| format!("missing group {group}"),
    ))
}

pub fn summarize(records: &[Value], selection: &Selection) -> Result<Value, String> {
    let groups = collect_groups(records, selection)?;
    let expected = expected_group_names(selection);
    let included: BTreeSet<String> = groups.keys().cloned().collect();
    validate_group_names(&expected, &included)?;
    let summaries: Result<Vec<Value>, String> = groups
        .iter()
        .map(|(key, members)| group_summary(key, members))
        .collect();
    let summaries = summaries?;
    let passed = summaries
        .iter()
        .all(|group| group.get("within_threshold") != Some(&Value::Bool(false)));
    Ok(json!({
        "protocol": "pg-service/1",
        "partial": selection.is_partial(),
        "included_groups": included,
        "groups": summaries,
        "all_within_threshold": passed
    }))
}
