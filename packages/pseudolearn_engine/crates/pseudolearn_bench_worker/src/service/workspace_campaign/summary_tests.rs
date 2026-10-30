use crate::service::workspace_campaign::record::{RecordInput, build};
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::summary::summarize;
use serde_json::Value;

fn records(count: usize, millis: f64, machine: &str) -> Vec<Value> {
    (0..count)
        .map(|process| {
            let samples = vec![millis; 30];
            build(&RecordInput {
                load: "files-10",
                scenario: Scenario::BodyEdit,
                process,
                machine,
                resolution_nanos: 41,
                digest: "abc".to_owned(),
                candidate_millis: &samples,
                control_millis: &samples,
            })
        })
        .collect()
}

#[test]
fn ten_processes_on_one_machine_summarize_within_the_threshold() -> Result<(), String> {
    let summary = summarize(&records(10, 12.0, "m1"))?;
    assert_eq!(
        summary.get("all_within_threshold"),
        Some(&Value::Bool(true))
    );
    assert_eq!(
        summary.pointer("/groups/0/candidate_p95_ms"),
        Some(&Value::from(12.0))
    );
    Ok(())
}

#[test]
fn an_exceeded_threshold_is_reported_not_adjusted() -> Result<(), String> {
    let summary = summarize(&records(10, 101.0, "m1"))?;
    assert_eq!(
        summary.get("all_within_threshold"),
        Some(&Value::Bool(false))
    );
    Ok(())
}

#[test]
fn fewer_than_ten_processes_empty_input_and_mixed_machines_are_rejected() {
    assert!(summarize(&records(9, 1.0, "m1")).is_err());
    assert!(summarize(&[]).is_err());
    let mut mixed = records(10, 1.0, "m1");
    mixed.truncate(9);
    mixed.extend(records(1, 1.0, "m2").into_iter().map(|mut record| {
        if let Some(fields) = record.as_object_mut() {
            fields.insert("process".to_owned(), Value::from(99));
        }
        record
    }));
    assert!(summarize(&mixed).is_err());
}
