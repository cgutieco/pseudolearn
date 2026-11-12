use crate::service::workspace_campaign::comparison::{
    Outcome, equivalent, merge, p95, within_threshold,
};
use crate::service::workspace_campaign::observation::Published;
use crate::service::workspace_campaign::scenario::Scenario;
use serde_json::{Value, json};

fn outcome(uri: &str, message: &str, response: Value) -> Outcome {
    let mut published = Published::new();
    published.insert(uri.to_owned(), json!([{"message": message}]));
    Outcome {
        published,
        response,
    }
}

#[test]
fn identical_outcomes_are_equivalent() {
    let candidate = outcome("a", "x", json!([]));
    assert!(equivalent(&candidate, &outcome("a", "x", json!([]))).is_ok());
}

#[test]
fn a_changed_diagnostic_is_a_difference() {
    let result = equivalent(&outcome("a", "x", json!([])), &outcome("a", "y", json!([])));
    assert!(result.is_err());
}

#[test]
fn missing_and_extra_published_files_are_differences() {
    let control = outcome("a", "x", json!([]));
    assert!(equivalent(&outcome("b", "x", json!([])), &control).is_err());
    let mut wider = outcome("a", "x", json!([]));
    wider.published.insert("b".to_owned(), json!([]));
    assert!(equivalent(&wider, &control).is_err());
}

#[test]
fn a_changed_barrier_response_is_a_difference() {
    let result = equivalent(
        &outcome("a", "x", json!([1])),
        &outcome("a", "x", json!([2])),
    );
    assert!(result.is_err());
}

#[test]
fn merge_keeps_the_latest_publication_per_file() {
    let mut setup = Published::new();
    setup.insert("a".to_owned(), json!(["old"]));
    setup.insert("b".to_owned(), json!(["kept"]));
    let mut step = Published::new();
    step.insert("a".to_owned(), json!(["new"]));
    let merged = merge(setup, step);
    assert_eq!(merged.get("a"), Some(&json!(["new"])));
    assert_eq!(merged.get("b"), Some(&json!(["kept"])));
}

#[test]
fn thresholds_are_100_ms_for_diagnostics_and_500_ms_for_rename() {
    assert_eq!(
        within_threshold(Scenario::BodyEdit, "files-10", 100.0),
        Some(true)
    );
    assert_eq!(
        within_threshold(Scenario::BodyEdit, "files-10", 100.5),
        Some(false)
    );
    assert_eq!(
        within_threshold(Scenario::Rename, "files-10", 499.0),
        Some(true)
    );
    assert_eq!(
        within_threshold(Scenario::Rename, "files-10", 501.0),
        Some(false)
    );
    assert_eq!(
        within_threshold(Scenario::StaleSource, "files-10", 1e9),
        None
    );
}

#[test]
fn the_extended_load_scales_only_the_diagnostic_threshold() {
    let load = "files-1000-extended";
    assert_eq!(
        within_threshold(Scenario::ClosedFileChange, load, 300.0),
        Some(true)
    );
    assert_eq!(
        within_threshold(Scenario::ClosedFileChange, load, 300.5),
        Some(false)
    );
    assert_eq!(within_threshold(Scenario::Rename, load, 501.0), Some(false));
    assert_eq!(
        within_threshold(Scenario::BodyEdit, "unknown-load", 100.5),
        Some(false)
    );
}

#[test]
fn p95_of_no_samples_is_absent_and_of_one_sample_is_that_sample() {
    assert_eq!(p95(&[]), None);
    assert_eq!(p95(&[7.0]), Some(7.0));
}
