use crate::aot::statistics::{Sampler, mean, percentile};
use crate::pg_campaign::invalidations;
use crate::pg_workloads::{COMBINATIONS, MAXIMUM_INSTANCES};
use serde_json::{Value, json};
use std::path::Path;

const BOOTSTRAP_DRAWS: usize = 2000;
const TRAVERSAL_THRESHOLD: f64 = 1.10;
const INDIRECT_CALL_THRESHOLD: f64 = 1.25;

pub fn summarize(arguments: &[String]) -> Result<(), String> {
    let [experiment, directory] = arguments else {
        return Err("Usage: pg-summary <E-PG-03|E-PG-04> <directory>".to_owned());
    };
    let names = workload_names(experiment)?;
    let mut results = Vec::new();
    for name in &names {
        results.push(workload_result(experiment, directory, name)?);
    }
    let growth = if experiment == "E-PG-03" {
        growth(directory, &results)?
    } else {
        Value::Null
    };
    let summary = json!({
        "protocol": "e-pg-2/1",
        "experiment": experiment,
        "workloads": results,
        "growth": growth,
    });
    let path = Path::new(directory).join("summary.json");
    std::fs::write(&path, summary.to_string()).map_err(|error| error.to_string())?;
    println!("Summary written: {}", path.display());
    Ok(())
}

fn workload_names(experiment: &str) -> Result<Vec<String>, String> {
    match experiment {
        "E-PG-03" => Ok(COMBINATIONS
            .iter()
            .map(|count| format!("generic-{count}"))
            .collect()),
        "E-PG-04" => Ok(vec!["closure-call".to_owned(), "closure-create".to_owned()]),
        _ => Err("Unknown experiment".to_owned()),
    }
}

fn threshold_of(name: &str) -> Option<f64> {
    match name {
        "closure-call" => Some(INDIRECT_CALL_THRESHOLD),
        "closure-create" => None,
        _ => Some(TRAVERSAL_THRESHOLD),
    }
}

fn load_processes(directory: &str, name: &str) -> Result<Vec<Value>, String> {
    let folder = Path::new(directory).join(name);
    let mut paths: Vec<_> = std::fs::read_dir(&folder)
        .map_err(|error| format!("{}: {error}", folder.display()))?
        .filter_map(|entry| entry.ok().map(|entry| entry.path()))
        .filter(|path| {
            path.extension()
                .is_some_and(|extension| extension == "json")
        })
        .collect();
    paths.sort();
    paths
        .iter()
        .map(|path| {
            let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
            serde_json::from_str(&text).map_err(|error| error.to_string())
        })
        .collect()
}

fn process_mean(process: &Value, field: &str) -> f64 {
    let times: Vec<f64> = process
        .get("samples")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice)
        .iter()
        .filter_map(|sample| sample.get(field).and_then(Value::as_f64))
        .collect();
    mean(&times)
}

fn bootstrap(pairs: &[(f64, f64)]) -> (f64, f64) {
    let mut sampler = Sampler::seeded(42);
    let mut ratios = Vec::new();
    for _ in 0..BOOTSTRAP_DRAWS {
        let candidate = sampler.resample(&pairs.iter().map(|pair| pair.0).collect::<Vec<_>>());
        let control = sampler.resample(&pairs.iter().map(|pair| pair.1).collect::<Vec<_>>());
        ratios.push(mean(&candidate) / mean(&control));
    }
    (percentile(&ratios, 0.025), percentile(&ratios, 0.975))
}

fn workload_result(experiment: &str, directory: &str, name: &str) -> Result<Value, String> {
    let processes = load_processes(directory, name)?;
    let campaign =
        json!({"protocol": "e-pg-2/1", "experiment": experiment, "processes": processes});
    let problems = invalidations(&campaign);
    if !problems.is_empty() {
        return Err(format!("{name}: invalid campaign\n{}", problems.join("\n")));
    }
    let pairs: Vec<(f64, f64)> = processes
        .iter()
        .map(|process| {
            (
                process_mean(process, "candidate_nanoseconds"),
                process_mean(process, "control_nanoseconds"),
            )
        })
        .collect();
    let ratio = mean(&pairs.iter().map(|pair| pair.0).collect::<Vec<_>>())
        / mean(&pairs.iter().map(|pair| pair.1).collect::<Vec<_>>());
    let (lower, upper) = bootstrap(&pairs);
    let threshold = threshold_of(name);
    Ok(json!({
        "workload": name,
        "processes": processes.len(),
        "ratio": ratio,
        "interval95": [lower, upper],
        "threshold": threshold,
        "within_threshold": threshold.map(|limit| ratio <= limit),
        "stressed_output_matches": stressed_matches(&processes),
        "shape": processes.first().and_then(|process| process.get("shape")).cloned(),
    }))
}

fn stressed_matches(processes: &[Value]) -> bool {
    processes.iter().all(|process| {
        process
            .get("samples")
            .and_then(Value::as_array)
            .is_some_and(|samples| {
                samples.iter().all(|sample| {
                    sample
                        .get("stressed_output_matches")
                        .and_then(Value::as_bool)
                        == Some(true)
                })
            })
    })
}

fn shape_bytes(result: &Value, field: &str) -> Option<u64> {
    result
        .pointer(&format!("/shape/candidate/{field}"))?
        .as_u64()
}

fn growth(directory: &str, results: &[Value]) -> Result<Value, String> {
    let base = results
        .first()
        .and_then(|result| shape_bytes(result, "object_bytes"))
        .ok_or("Missing base object size")?;
    let proportional = results.iter().zip(COMBINATIONS).all(|(result, count)| {
        shape_bytes(result, "object_bytes")
            .is_some_and(|bytes| bytes <= base.saturating_mul(u64::from(count)))
    });
    let expansive = std::fs::read_to_string(Path::new(directory).join("expansive/process-00.json"))
        .map_err(|error| error.to_string())?;
    let rejected = serde_json::from_str::<Value>(&expansive)
        .ok()
        .and_then(|record| record.get("rejected").and_then(Value::as_bool))
        .unwrap_or(false);
    Ok(json!({
        "object_growth_at_most_proportional": proportional,
        "expansive_rejected_by_typed_limit": rejected,
        "maximum_instances": MAXIMUM_INSTANCES,
    }))
}
