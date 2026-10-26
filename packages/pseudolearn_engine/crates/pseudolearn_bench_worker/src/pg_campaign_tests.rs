use crate::pg_campaign::{PROTOCOL, invalidations};
use serde_json::{Value, json};

fn sample() -> Value {
    json!({
        "workload": "generic-10",
        "candidate_nanoseconds": 120,
        "control_nanoseconds": 100,
        "candidate_output": "abc",
        "control_output": "abc"
    })
}

fn process(identity: u64, machine: &str) -> Value {
    json!({
        "process": identity,
        "machine": machine,
        "clock_resolution_nanoseconds": 1.0,
        "samples": vec![sample(); 30]
    })
}

fn campaign(processes: Vec<Value>) -> Value {
    json!({"protocol": PROTOCOL, "experiment": "E-PG-03", "processes": processes})
}

fn set(campaign: &mut Value, pointer: &str, value: Value) {
    if let Some(slot) = campaign.pointer_mut(pointer) {
        *slot = value;
    }
}

fn valid() -> Value {
    campaign(
        (0..10)
            .map(|identity| process(identity, "reference"))
            .collect(),
    )
}

#[test]
fn accepts_ten_processes_of_thirty_matching_samples() {
    assert!(invalidations(&valid()).is_empty());
}

#[test]
fn rejects_missing_processes() {
    let campaign = campaign(
        (0..9)
            .map(|identity| process(identity, "reference"))
            .collect(),
    );
    assert!(!invalidations(&campaign).is_empty());
}

#[test]
fn rejects_missing_samples() {
    let mut campaign = valid();
    set(
        &mut campaign,
        "/processes/3/samples",
        json!(vec![sample(); 29]),
    );
    let problems = invalidations(&campaign);
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("29 samples"))
    );
}

#[test]
fn rejects_an_incorrect_output_even_when_the_timing_is_faster() {
    let mut campaign = valid();
    set(
        &mut campaign,
        "/processes/0/samples/5/candidate_output",
        json!("different"),
    );
    set(
        &mut campaign,
        "/processes/0/samples/5/candidate_nanoseconds",
        json!(1),
    );
    let problems = invalidations(&campaign);
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("outputs differ"))
    );
}

#[test]
fn rejects_mixed_machines() {
    let mut processes: Vec<Value> = (0..9)
        .map(|identity| process(identity, "reference"))
        .collect();
    processes.push(process(9, "laptop"));
    let problems = invalidations(&campaign(processes));
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("mix machines"))
    );
}

#[test]
fn rejects_zero_clock_resolution_and_repeated_process_identity() {
    let mut campaign = valid();
    set(
        &mut campaign,
        "/processes/1/clock_resolution_nanoseconds",
        json!(0.0),
    );
    set(&mut campaign, "/processes/2/process", json!(0));
    let problems = invalidations(&campaign);
    assert!(
        problems
            .iter()
            .any(|problem| problem.contains("clock resolution"))
    );
    assert!(problems.iter().any(|problem| problem.contains("repeated")));
}

#[test]
fn rejects_an_unknown_experiment_and_protocol() {
    let mut campaign = valid();
    set(&mut campaign, "/experiment", json!("E-PG-99"));
    set(&mut campaign, "/protocol", json!("other/1"));
    assert_eq!(invalidations(&campaign).len(), 2);
}
