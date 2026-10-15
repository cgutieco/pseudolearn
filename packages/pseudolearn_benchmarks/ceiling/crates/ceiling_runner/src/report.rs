use ceiling_statistics::{confidence, geometric, mean, ratio};
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::path::Path;

type Samples = BTreeMap<(String, String, u8), BTreeMap<u64, Vec<f64>>>;

pub fn write(output: &Path) -> Result<(), String> {
    write_experiment(output, &[(1, 0, "V1"), (2, 1, "V2"), (3, 2, "V3")], 12000)
}

pub fn write_remanso(output: &Path) -> Result<(), String> {
    let comparisons = [
        (2, 1, "V2/V1"),
        (3, 2, "V3/V2"),
        (4, 1, "V1F/V1"),
        (5, 4, "V2R/V1F"),
        (6, 5, "V2R-unchecked/V2R"),
        (7, 5, "V3R/V2R"),
        (8, 5, "V3R-cards/V2R"),
    ];
    write_experiment(output, &comparisons, 27000)
}

fn write_experiment(
    output: &Path,
    comparisons: &[(u8, u8, &str)],
    expected: usize,
) -> Result<(), String> {
    let text =
        std::fs::read_to_string(output.join("raw.json")).map_err(|error| error.to_string())?;
    let rows: Vec<Value> = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let samples = group(&rows, expected)?;
    let (kernels, families) = summaries(&samples, comparisons)?;
    let families = family_report(families)?;
    crate::collection::save(
        output,
        "summary.json",
        &json!({
            "samples": rows.len(), "kernels": kernels, "families": families,
            "samplesDiscarded": 0, "stationarity": "not_proven",
            "comparisons": comparisons,
            "decision": "Report all measured ratios; acceptance is evaluated against the declared experiment criteria"
        }),
    )
}

fn group(rows: &[Value], expected: usize) -> Result<Samples, String> {
    if rows.len() != expected {
        return Err("Expected ten complete processes".to_owned());
    }
    let mut samples = Samples::new();
    for row in rows {
        let (kernel, family, variant, process, value) = sample(row)?;
        samples
            .entry((kernel, family, variant))
            .or_default()
            .entry(process)
            .or_default()
            .push(value);
    }
    Ok(samples)
}

fn averages(processes: &BTreeMap<u64, Vec<f64>>) -> Result<Vec<f64>, String> {
    if processes.len() != 10 || processes.values().any(|values| values.len() != 30) {
        return Err("Incomplete group".to_owned());
    }
    processes.values().map(|values| mean(values)).collect()
}

fn interval(ratios: &[f64]) -> Result<[f64; 2], String> {
    let logarithms: Vec<_> = ratios.iter().map(|value| value.ln()).collect();
    Ok(confidence(&logarithms)?.map(f64::exp))
}

fn family_report(families: BTreeMap<(String, String), Vec<Vec<f64>>>) -> Result<Value, String> {
    let mut report = serde_json::Map::new();
    for ((family, variant), kernels) in families {
        let mut paired = Vec::new();
        for process in 0..10 {
            let values: Vec<_> = kernels
                .iter()
                .filter_map(|values| values.get(process).copied())
                .collect();
            paired.push(geometric(&values)?);
        }
        let estimate = geometric(&paired)?;
        report.insert(
            format!("{family}/{variant}"),
            json!({
                "ratio": estimate, "confidence95": interval(&paired)?,
                "reviewBeforeR5": variant == "V2" && estimate > 1.30,
            }),
        );
    }
    Ok(Value::Object(report))
}

type Families = BTreeMap<(String, String), Vec<Vec<f64>>>;

fn summaries(
    samples: &Samples,
    comparisons: &[(u8, u8, &str)],
) -> Result<(BTreeMap<String, Value>, Families), String> {
    let mut kernels = BTreeMap::new();
    let mut families: BTreeMap<(String, String), Vec<Vec<f64>>> = BTreeMap::new();
    for ((kernel, family, variant), processes) in samples {
        let Some((_, denominator_variant, label)) = comparisons
            .iter()
            .find(|comparison| comparison.0 == *variant)
        else {
            continue;
        };
        let previous = samples
            .get(&(kernel.clone(), family.clone(), *denominator_variant))
            .ok_or("Missing previous variant")?;
        let numerator = averages(processes)?;
        let denominator = averages(previous)?;
        let ratios = ratio(&numerator, &denominator)?;
        let changes = changes(processes)?;
        kernels.insert(
            format!("{kernel}/{label}"),
            json!({
                "ratio": geometric(&ratios)?, "confidence95": interval(&ratios)?,
                "nanoseconds": mean(&numerator)?, "changePointsByProcess": changes,
            }),
        );
        families
            .entry((family.clone(), (*label).to_owned()))
            .or_default()
            .push(ratios);
    }
    Ok((kernels, families))
}

fn changes(processes: &BTreeMap<u64, Vec<f64>>) -> Result<BTreeMap<String, Vec<usize>>, String> {
    let changes: BTreeMap<_, _> = processes
        .iter()
        .map(|(process, values)| {
            Ok((
                process.to_string(),
                ceiling_statistics::change_points::detect(values)?,
            ))
        })
        .collect::<Result<_, String>>()?;
    Ok(changes)
}

fn sample(row: &Value) -> Result<(String, String, u8, u64, f64), String> {
    let kernel = row
        .get("workload")
        .unwrap_or(&Value::Null)
        .as_str()
        .ok_or("Missing workload")?
        .to_owned();
    let family = row
        .get("family")
        .unwrap_or(&Value::Null)
        .as_str()
        .ok_or("Missing family")?
        .to_owned();
    let variant = u8::try_from(
        row.get("variant")
            .unwrap_or(&Value::Null)
            .as_u64()
            .ok_or("Missing variant")?,
    )
    .map_err(|error| error.to_string())?;
    let process = row
        .get("process")
        .unwrap_or(&Value::Null)
        .as_u64()
        .ok_or("Missing process")?;
    let value = row
        .get("nanoseconds")
        .unwrap_or(&Value::Null)
        .as_f64()
        .ok_or("Missing duration")?;
    Ok((kernel, family, variant, process, value))
}

#[cfg(test)]
#[path = "report_tests.rs"]
mod report_tests;
