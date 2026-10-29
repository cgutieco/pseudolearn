use crate::pg_http_summary::{bootstrap_interval, invalidations, linear_fit, nanoseconds_to_float};
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
fn rejects_repeated_processes_and_incorrect_sample_results() {
    let mut processes = valid_processes();
    processes[9]["process"] = json!(0);
    processes[2]["samples"][0] = sample(0, "incorrect\n");
    let problems = invalidations(&processes, "http-body-1024");
    assert!(problems.iter().any(|problem| problem.contains("repeated")));
    assert!(problems.iter().any(|problem| problem.contains("duration")));
    assert!(problems.iter().any(|problem| problem.contains("differs")));
}

#[test]
fn rejects_mixed_machines_protocols_and_short_process_sets() {
    let mut processes = valid_processes();
    processes.pop();
    processes[0]["protocol"] = json!("other/1");
    processes[1]["machine"] = json!("different");
    let problems = invalidations(&processes, "http-body-1024");
    assert!(problems.iter().any(|problem| problem.contains("processes")));
    assert!(problems.iter().any(|problem| problem.contains("protocol")));
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("one machine"))
    );
}

#[test]
fn reports_linear_fit_and_reproducible_bootstrap_interval() {
    let points = [(0, 100.0), (1024, 1124.0), (65_536, 65_636.0)];
    let fit = linear_fit(&points);
    assert!(fit.is_some());
    assert_eq!(
        bootstrap_interval(&[10.0, 20.0, 30.0]),
        bootstrap_interval(&[10.0, 20.0, 30.0])
    );
}

#[test]
fn converts_nanoseconds_using_bounded_integer_parts() {
    assert_eq!(nanoseconds_to_float(1_000_000), 1_000_000.0);
}
