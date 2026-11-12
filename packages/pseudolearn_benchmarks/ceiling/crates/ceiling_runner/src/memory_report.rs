use ceiling_statistics::{confidence, geometric, mean};
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};
use std::path::Path;

type Groups = BTreeMap<(String, String), Vec<Value>>;

pub fn write(output: &Path) -> Result<(), String> {
    let text =
        std::fs::read_to_string(output.join("raw.json")).map_err(|error| error.to_string())?;
    let rows: Vec<Value> = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let groups = group(&rows)?;
    let mut reports = Vec::new();
    for collector in ["SizeClasses", "Lines", "ReferenceCounts"] {
        reports.push(summarize(&groups, collector)?);
    }
    let selected = select(&reports)?;
    let report = json!({"samples":rows.len(),"processes":10,"iterations":30,"workloads":12,
        "selected":selected,"candidates":reports,"samplesDiscarded":0,
        "model":"Native checked algorithms with common frame roots, fixed allocation collection cadence and 4096-operation checkpoints",
        "limits":"Prototype measurements do not establish VM throughput or timeline replay performance"});
    crate::collection::save(output, "summary.json", &report)?;
    Ok(())
}

fn group(rows: &[Value]) -> Result<Groups, String> {
    if rows.len() != 10800 {
        return Err("Expected ten complete memory processes".to_owned());
    }
    let mut groups = Groups::new();
    let mut identities = BTreeSet::new();
    for row in rows {
        let workload = string(row, "workload")?;
        let collector = string(row, "collector")?;
        let process = row
            .get("process")
            .and_then(Value::as_u64)
            .ok_or("Missing process")?;
        let iteration = row
            .get("iteration")
            .and_then(Value::as_u64)
            .ok_or("Missing iteration")?;
        if process >= 10
            || iteration >= 30
            || !identities.insert((workload.clone(), collector.clone(), process, iteration))
        {
            return Err("Duplicate or invalid memory sample".to_owned());
        }
        if row.get("validated") != Some(&json!(true))
            || row.get("forcedOutputVerified") != Some(&json!(true))
        {
            return Err("Unverified memory sample".to_owned());
        }
        groups
            .entry((workload, collector))
            .or_default()
            .push(row.clone());
    }
    if groups.len() != 36 || groups.values().any(|group| group.len() != 300) {
        return Err("Incomplete memory group".to_owned());
    }
    Ok(groups)
}

fn summarize(groups: &Groups, collector: &str) -> Result<Value, String> {
    let mut ratios = Vec::new();
    let mut eligible = true;
    let mut workloads = Vec::new();
    for ((workload, candidate), rows) in groups {
        if candidate != collector {
            continue;
        }
        let baseline = groups
            .get(&(workload.clone(), "SizeClasses".to_owned()))
            .ok_or("Missing baseline")?;
        let paired = paired_time(rows, baseline)?;
        let ratio = geometric(&paired)?;
        let pause_ratio = quotient(
            quantile(rows, "nanoseconds", true, 95)?,
            quantile(baseline, "nanoseconds", true, 95)?,
        );
        let changes_ratio = quotient(
            quantile(rows, "changedBlocks", false, 95)?,
            quantile(baseline, "changedBlocks", false, 95)?,
        );
        eligible &= pause_ratio <= 2.0 && changes_ratio <= 1.5;
        ratios.push(paired);
        workloads.push(json!({"workload":workload,"timeRatio":ratio,
            "pauseP95Ratio":pause_ratio,"changedBlocksP95Ratio":changes_ratio,
            "pauseMaxNanoseconds":quantile(rows,"nanoseconds",true,100)?,
            "pauseP95Nanoseconds":quantile(rows,"nanoseconds",true,95)?,
            "markedWordsP95":quantile(rows,"markedWords",true,95)?,
            "sweptWordsP95":quantile(rows,"sweptWords",true,95)?,
            "peakWords":rows.iter().filter_map(|row| row.get("peakWords").and_then(Value::as_u64)).max()}));
    }
    let paired = process_ratios(&ratios)?;
    let interval =
        confidence(&paired.iter().map(|ratio| ratio.ln()).collect::<Vec<_>>())?.map(f64::exp);
    Ok(
        json!({"collector":collector,"timeRatio":geometric(&paired)?,"confidence95":interval,"eligible":eligible,"workloads":workloads}),
    )
}

fn paired_time(rows: &[Value], baseline: &[Value]) -> Result<Vec<f64>, String> {
    let mut ratios = Vec::new();
    for process in 0_u64..10 {
        let selected = |entries: &[Value]| {
            entries
                .iter()
                .filter(|row| row.get("process").and_then(Value::as_u64) == Some(process))
                .map(|row| number(row, "nanoseconds"))
                .collect::<Result<Vec<_>, _>>()
        };
        ratios.push(mean(&selected(rows)?)? / mean(&selected(baseline)?)?);
    }
    Ok(ratios)
}

fn quantile(rows: &[Value], field: &str, pauses: bool, percent: usize) -> Result<f64, String> {
    let mut values = Vec::new();
    for row in rows {
        let entries = row
            .get(if pauses { "pauses" } else { field })
            .and_then(Value::as_array)
            .ok_or("Missing metrics")?;
        for entry in entries {
            values.push(if pauses {
                number(entry, field)?
            } else {
                entry.as_f64().ok_or("Invalid block count")?
            });
        }
    }
    values.sort_by(f64::total_cmp);
    let index = values
        .len()
        .saturating_sub(1)
        .saturating_mul(percent)
        .checked_div(100)
        .ok_or("Invalid quantile")?;
    values
        .get(index)
        .copied()
        .ok_or_else(|| "Empty metric samples".to_owned())
}

fn quotient(numerator: f64, denominator: f64) -> f64 {
    if denominator == 0.0 {
        if numerator == 0.0 { 1.0 } else { f64::MAX }
    } else {
        numerator / denominator
    }
}

fn string(row: &Value, field: &str) -> Result<String, String> {
    row.get(field)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("Missing {field}"))
}

fn number(row: &Value, field: &str) -> Result<f64, String> {
    row.get(field)
        .and_then(Value::as_f64)
        .filter(|value| value.is_finite())
        .ok_or_else(|| format!("Invalid {field}"))
}

fn process_ratios(workloads: &[Vec<f64>]) -> Result<Vec<f64>, String> {
    (0..10)
        .map(|process| {
            let ratios = workloads
                .iter()
                .map(|workload| {
                    workload
                        .get(process)
                        .copied()
                        .ok_or("Missing paired process".to_owned())
                })
                .collect::<Result<Vec<_>, _>>()?;
            geometric(&ratios)
        })
        .collect()
}

fn select(reports: &[Value]) -> Result<&Value, String> {
    let mut selected = None;
    for report in reports {
        if report.get("eligible") != Some(&json!(true)) {
            continue;
        }
        let upper = report
            .pointer("/confidence95/1")
            .and_then(Value::as_f64)
            .ok_or("Missing confidence interval")?;
        let better = selected
            .and_then(|selected: &Value| selected.pointer("/confidence95/0"))
            .and_then(Value::as_f64)
            .is_none_or(|lower| upper < lower);
        if better {
            selected = Some(report);
        }
    }
    selected
        .and_then(|selected| selected.get("collector"))
        .ok_or_else(|| "No eligible collector".to_owned())
}

#[cfg(test)]
#[path = "memory_report_tests.rs"]
mod memory_report_tests;
