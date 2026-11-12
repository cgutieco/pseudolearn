use crate::service::workspace_campaign::loads::Load;
use crate::service::workspace_campaign::record::{RecordInput, build};
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::selection::Selection;
use crate::service::workspace_campaign::summary::summarize;
use serde_json::Value;

fn records(count: usize, millis: f64, machine: &str) -> Vec<Value> {
    (0..count)
        .map(|process| {
            let mut record = group_record("files-10", Scenario::BodyEdit, process, millis);
            if let Some(fields) = record.as_object_mut() {
                fields.insert("machine".to_owned(), Value::from(machine));
            }
            record
        })
        .collect()
}

fn group_record(load: &str, scenario: Scenario, process: usize, millis: f64) -> Value {
    let samples = vec![millis; 30];
    build(&RecordInput {
        load,
        scenario,
        process,
        machine: "m1",
        resolution_nanos: 41,
        digest: format!("{load}-{}", scenario.name()),
        candidate_millis: &samples,
        control_millis: &samples,
    })
}

fn selected(arguments: &[&str]) -> Result<Selection, String> {
    Selection::parse(
        &arguments
            .iter()
            .map(|value| (*value).to_owned())
            .collect::<Vec<_>>(),
    )
}

#[test]
fn ten_processes_on_one_machine_summarize_within_the_threshold() -> Result<(), String> {
    let summary = summarize(
        &records(10, 12.0, "m1"),
        &selected(&["--load", "files-10", "--scenario", "body-edit"])?,
    )?;
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
    let selection = selected(&["--load", "files-10", "--scenario", "body-edit"])?;
    let summary = summarize(&records(10, 101.0, "m1"), &selection)?;
    assert_eq!(
        summary.get("all_within_threshold"),
        Some(&Value::Bool(false))
    );
    Ok(())
}

#[test]
fn fewer_processes_empty_input_and_mixed_machines_are_rejected() -> Result<(), String> {
    let selection = selected(&["--load", "files-10", "--scenario", "body-edit"])?;
    assert!(summarize(&records(9, 1.0, "m1"), &selection).is_err());
    assert!(summarize(&[], &selection).is_err());
    let mut mixed = records(9, 1.0, "m1");
    let mut other_machine = group_record("files-10", Scenario::BodyEdit, 99, 1.0);
    if let Some(fields) = other_machine.as_object_mut() {
        fields.insert("machine".to_owned(), Value::from("m2"));
    }
    mixed.push(other_machine);
    assert!(summarize(&mixed, &selection).is_err());
    Ok(())
}

#[test]
fn an_absent_selected_group_is_rejected() -> Result<(), String> {
    let selection = selected(&[
        "--load",
        "files-10",
        "--scenario",
        "body-edit",
        "--scenario",
        "rename",
    ])?;
    assert!(summarize(&records(10, 12.0, "m1"), &selection).is_err());
    Ok(())
}

#[test]
fn partial_and_complete_summaries_declare_their_scope() -> Result<(), String> {
    let selection = selected(&["--load", "files-10", "--scenario", "body-edit"])?;
    let partial = summarize(&records(10, 12.0, "m1"), &selection)?;
    assert_eq!(partial.get("partial"), Some(&Value::Bool(true)));
    assert_eq!(
        partial.get("included_groups"),
        Some(&Value::from(vec![Value::from("files-10/body-edit")]))
    );
    let complete_selection = Selection::parse(&[])?;
    let complete_records = all_group_records(complete_selection.expected_groups());
    let complete = summarize(&complete_records, &complete_selection)?;
    assert_eq!(complete.get("partial"), Some(&Value::Bool(false)));
    assert_eq!(
        complete
            .get("included_groups")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(28)
    );
    Ok(())
}

fn all_group_records(groups: Vec<(&'static Load, Scenario)>) -> Vec<Value> {
    groups
        .into_iter()
        .flat_map(|(load, scenario)| {
            (0..10).map(move |process| group_record(load.name, scenario, process, 12.0))
        })
        .collect()
}
