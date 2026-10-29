use crate::aot::statistics::{Sampler, mean, percentile};
use crate::pg_http_growth::{linear_fit, points_for};
use crate::pg_http_workloads::{JSON_DEPTHS, workload_names};
use serde_json::{Value, json};
use std::collections::BTreeSet;
use std::path::{Path, PathBuf};

const PROTOCOL: &str = "pg-http/1";
const MINIMUM_PROCESSES: usize = 10;
const SAMPLES_PER_PROCESS: usize = 30;
const BOOTSTRAP_DRAWS: usize = 2000;

pub fn summarize(arguments: &[String]) -> Result<(), String> {
    let [directory] = arguments else {
        return Err("Usage: pg-http-summary <directory>".to_owned());
    };
    let output = Path::new(directory).join("summary.json");
    if output.exists() {
        return Err(format!("Refusing to overwrite {}", output.display()));
    }
    let mut results = Vec::new();
    for name in workload_names() {
        results.push(workload_summary(directory, &name)?);
    }
    let body_points = points_for(&results, "http_body", None);
    let json_fits = JSON_DEPTHS
        .iter()
        .filter_map(|depth| {
            linear_fit(&points_for(&results, "json_parse", Some(*depth)))
                .map(|fit| json!({"depth": depth, "fit": fit}))
        })
        .collect::<Vec<_>>();
    let summary = json!({
        "protocol": PROTOCOL,
        "candidate_metric": "PERF.PG.HTTP",
        "approval_state": "pending_P6",
        "status": "measurement_only",
        "transport_measured": false,
        "resident_memory_measured": false,
        "json_memory_measured": false,
        "body_growth_fit": linear_fit(&body_points),
        "json_growth_by_depth": json_fits,
        "workloads": results,
    });
    let parent = output
        .parent()
        .ok_or_else(|| "Invalid summary path".to_owned())?;
    std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
    let bytes = serde_json::to_vec(&summary).map_err(|error| error.to_string())?;
    std::fs::write(&output, bytes).map_err(|error| error.to_string())
}

fn workload_summary(directory: &str, name: &str) -> Result<Value, String> {
    let processes = load_processes(directory, name)?;
    let problems = invalidations(&processes, name);
    if !problems.is_empty() {
        return Err(format!("{name}: invalid campaign\n{}", problems.join("\n")));
    }
    let mut process_means = Vec::with_capacity(processes.len());
    let mut sample_times = Vec::new();
    for process in &processes {
        let samples = process
            .get("samples")
            .and_then(Value::as_array)
            .map_or(&[][..], Vec::as_slice);
        let times = samples
            .iter()
            .filter_map(|sample| sample.get("nanoseconds").and_then(Value::as_u64))
            .map(nanoseconds_to_float)
            .collect::<Vec<_>>();
        process_means.push(mean(&times));
        sample_times.extend(times);
    }
    let (lower, upper) = bootstrap_interval(&process_means);
    let first = processes.first().ok_or("No workload processes")?;
    Ok(json!({
        "workload": name,
        "category": text_of(first, "category"),
        "processes": processes.len(),
        "samples_per_process": SAMPLES_PER_PROCESS,
        "mean_process_nanoseconds": mean(&process_means),
        "median_sample_nanoseconds": percentile(&sample_times, 0.5),
        "interval95_mean_nanoseconds": [lower, upper],
        "body_bytes": number_of(first, "body_bytes"),
        "input_bytes": number_of(first, "input_bytes"),
        "json_nodes": number_of(first, "json_nodes"),
    }))
}

fn load_processes(directory: &str, name: &str) -> Result<Vec<Value>, String> {
    let folder = Path::new(directory).join(name);
    let mut paths: Vec<PathBuf> = std::fs::read_dir(&folder)
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
            let source = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
            serde_json::from_str(&source).map_err(|error| error.to_string())
        })
        .collect()
}

pub(super) fn invalidations(processes: &[Value], name: &str) -> Vec<String> {
    let mut problems = Vec::new();
    if processes.len() < MINIMUM_PROCESSES {
        problems.push(format!(
            "{} processes, {MINIMUM_PROCESSES} required",
            processes.len()
        ));
    }
    let mut identities = BTreeSet::new();
    let mut machines = BTreeSet::new();
    for process in processes {
        let identity = process.get("process").and_then(Value::as_u64);
        if identity.is_none_or(|value| !identities.insert(value)) {
            problems.push("process identity is missing or repeated".to_owned());
        }
        machines.insert(text_of(process, "machine"));
        problems.extend(process_invalidations(process, name));
    }
    if machines.len() != 1 {
        problems.push("processes do not share one machine identity".to_owned());
    }
    problems
}

fn process_invalidations(process: &Value, name: &str) -> Vec<String> {
    let mut problems = Vec::new();
    if text_of(process, "protocol") != PROTOCOL {
        problems.push("protocol does not match pg-http/1".to_owned());
    }
    if text_of(process, "workload") != name {
        problems.push(format!("workload is not {name}"));
    }
    if process
        .get("clock_resolution_nanoseconds")
        .and_then(Value::as_u64)
        .is_none_or(|resolution| resolution == 0)
    {
        problems.push("clock resolution is missing or zero".to_owned());
    }
    let samples = process
        .get("samples")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice);
    if samples.len() != SAMPLES_PER_PROCESS {
        problems.push(format!(
            "{} samples, {SAMPLES_PER_PROCESS} required",
            samples.len()
        ));
    }
    problems.extend(sample_invalidations(
        samples,
        text_of(process, "expected_output").as_str(),
    ));
    problems
}

fn sample_invalidations(samples: &[Value], expected_output: &str) -> Vec<String> {
    let mut problems = Vec::new();
    for sample in samples {
        if sample
            .get("nanoseconds")
            .and_then(Value::as_u64)
            .is_none_or(|duration| duration == 0)
        {
            problems.push("sample duration is missing or zero".to_owned());
        }
        if sample
            .get("termination")
            .and_then(|value| value.get("kind"))
            != Some(&json!("completed"))
            || text_of(sample, "output") != expected_output
        {
            problems.push("sample output or termination differs from expectation".to_owned());
        }
    }
    problems
}

pub(super) fn bootstrap_interval(process_means: &[f64]) -> (f64, f64) {
    let mut sampler = Sampler::seeded(42);
    let mut estimates = Vec::with_capacity(BOOTSTRAP_DRAWS);
    for _ in 0..BOOTSTRAP_DRAWS {
        estimates.push(mean(&sampler.resample(process_means)));
    }
    (percentile(&estimates, 0.025), percentile(&estimates, 0.975))
}

pub(super) fn nanoseconds_to_float(value: u64) -> f64 {
    let high = u32::try_from(value >> 32).unwrap_or(u32::MAX);
    let low = u32::try_from(value & 0xffff_ffff).unwrap_or(u32::MAX);
    f64::from(high) * 4_294_967_296.0 + f64::from(low)
}

fn text_of(value: &Value, name: &str) -> String {
    value
        .get(name)
        .and_then(Value::as_str)
        .map_or_else(String::new, str::to_owned)
}

fn number_of(value: &Value, name: &str) -> usize {
    value
        .get(name)
        .and_then(Value::as_u64)
        .and_then(|number| usize::try_from(number).ok())
        .unwrap_or(0)
}
