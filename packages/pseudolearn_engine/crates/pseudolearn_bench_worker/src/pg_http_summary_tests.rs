use crate::pg_http_summary::{bootstrap_interval, invalidations, nanoseconds_to_float};
use serde_json::{Value, json};

fn sample(duration: u64, output: &str) -> Value {
    json!({
        "nanoseconds": duration,
        "output": output,
        "termination": {"kind": "completed"}
    })
}

fn process(identity: u64, samples: Vec<Value>) -> Value {
    json!({
        "protocol": "pg-http/1",
        "process": identity,
        "machine": "reference",
        "clock_resolution_nanoseconds": 1,
        "workload": "http-body-1024",
        "category": "http_body",
        "body_bytes": 1024,
        "input_bytes": 0,
        "json_nodes": 0,
        "expected_output": "1024\n",
        "samples": samples
    })
}

fn valid_processes() -> Vec<Value> {
    (0..10_u64)
        .map(|identity| process(identity, vec![sample(100, "1024\n"); 30]))
        .collect()
}

#[test]
fn accepts_ten_distinct_processes_with_thirty_valid_samples() {
    assert!(invalidations(&valid_processes(), "http-body-1024").is_empty());
}

#[test]
fn computes_bootstrap_interval_deterministically() {
    assert_eq!(
        bootstrap_interval(&[10.0, 20.0, 30.0]),
        bootstrap_interval(&[10.0, 20.0, 30.0])
    );
}

#[test]
fn rejects_repeated_processes_and_incorrect_sample_results() -> Result<(), String> {
    let mut processes = valid_processes();
    let repeated = processes.get_mut(9).ok_or("missing final process")?;
    set_field(repeated, "process", json!(0))?;
    let changed = processes.get_mut(2).ok_or("missing changed process")?;
    let samples = changed
        .get_mut("samples")
        .and_then(Value::as_array_mut)
        .ok_or("missing sample array")?;
    let first_sample = samples.first_mut().ok_or("missing first sample")?;
    *first_sample = sample(0, "incorrect\n");
    let problems = invalidations(&processes, "http-body-1024");
    assert!(problems.iter().any(|problem| problem.contains("repeated")));
    assert!(problems.iter().any(|problem| problem.contains("duration")));
    assert!(problems.iter().any(|problem| problem.contains("differs")));
    Ok(())
}

#[test]
fn rejects_mixed_machines_protocols_and_short_process_sets() -> Result<(), String> {
    let mut processes = valid_processes();
    processes.pop();
    let first = processes.first_mut().ok_or("missing first process")?;
    set_field(first, "protocol", json!("other/1"))?;
    let second = processes.get_mut(1).ok_or("missing second process")?;
    set_field(second, "machine", json!("different"))?;
    let problems = invalidations(&processes, "http-body-1024");
    assert!(problems.iter().any(|problem| problem.contains("processes")));
    assert!(problems.iter().any(|problem| problem.contains("protocol")));
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("one machine"))
    );
    Ok(())
}

#[test]
fn converts_nanoseconds_using_bounded_integer_parts() {
    assert_eq!(nanoseconds_to_float(1_000_000), 1_000_000.0);
}

fn set_field(document: &mut Value, name: &str, value: Value) -> Result<(), String> {
    let object = document
        .as_object_mut()
        .ok_or_else(|| "expected JSON object".to_owned())?;
    object.insert(name.to_owned(), value);
    Ok(())
}
