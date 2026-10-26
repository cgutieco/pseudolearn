use serde_json::Value;
use std::collections::BTreeSet;

pub const PROTOCOL: &str = "e-pg-2/1";
pub const MINIMUM_PROCESSES: usize = 10;
pub const SAMPLES_PER_PROCESS: usize = 30;
const EXPERIMENTS: [&str; 2] = ["E-PG-03", "E-PG-04"];

pub fn verify(path: &str) -> Result<(), String> {
    let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    let campaign: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let problems = invalidations(&campaign);
    if problems.is_empty() {
        println!("Campaign is valid: {path}");
        return Ok(());
    }
    Err(problems.join("\n"))
}

pub fn invalidations(campaign: &Value) -> Vec<String> {
    let mut problems = Vec::new();
    if text_of(campaign, "protocol") != PROTOCOL {
        problems.push(format!("protocol is not {PROTOCOL}"));
    }
    if !EXPERIMENTS.contains(&text_of(campaign, "experiment").as_str()) {
        problems.push("experiment is not E-PG-03 or E-PG-04".to_owned());
    }
    let processes = campaign
        .get("processes")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice);
    if processes.len() < MINIMUM_PROCESSES {
        problems.push(format!(
            "{} processes, {MINIMUM_PROCESSES} required",
            processes.len()
        ));
    }
    let mut machines = BTreeSet::new();
    let mut identities = BTreeSet::new();
    for process in processes {
        let identity = process.get("process").and_then(Value::as_u64);
        if identity.is_none_or(|identity| !identities.insert(identity)) {
            problems.push("process identity is missing or repeated".to_owned());
        }
        machines.insert(text_of(process, "machine"));
        problems.extend(process_problems(process, identity));
    }
    if machines.len() > 1 {
        problems.push(format!("measurements mix machines: {machines:?}"));
    }
    problems
}

fn process_problems(process: &Value, identity: Option<u64>) -> Vec<String> {
    let label = format!(
        "process {}",
        identity.map_or_else(|| "?".to_owned(), |id| id.to_string())
    );
    let mut problems = Vec::new();
    if process
        .get("clock_resolution_nanoseconds")
        .and_then(Value::as_f64)
        .is_none_or(|resolution| resolution <= 0.0)
    {
        problems.push(format!("{label}: clock resolution missing or zero"));
    }
    let samples = process
        .get("samples")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice);
    if samples.len() != SAMPLES_PER_PROCESS {
        problems.push(format!(
            "{label}: {} samples, {SAMPLES_PER_PROCESS} required",
            samples.len()
        ));
    }
    for (position, sample) in samples.iter().enumerate() {
        problems.extend(sample_problems(
            sample,
            &format!("{label} sample {position}"),
        ));
    }
    problems
}

fn sample_problems(sample: &Value, label: &str) -> Vec<String> {
    let mut problems = Vec::new();
    for field in ["candidate_nanoseconds", "control_nanoseconds"] {
        if sample
            .get(field)
            .and_then(Value::as_u64)
            .is_none_or(|time| time == 0)
        {
            problems.push(format!("{label}: {field} missing or zero"));
        }
    }
    let candidate = text_of(sample, "candidate_output");
    if candidate.is_empty() || candidate != text_of(sample, "control_output") {
        problems.push(format!("{label}: candidate and control outputs differ"));
    }
    if text_of(sample, "workload").is_empty() {
        problems.push(format!("{label}: workload missing"));
    }
    problems
}

fn text_of(value: &Value, key: &str) -> String {
    value
        .get(key)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}
