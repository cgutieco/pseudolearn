use serde_json::{Value, json};

use super::report::{EXPECTED_METRICS, all_passed};

fn metrics(passed: bool, count: usize) -> Vec<Value> {
    (0..count).map(|_| json!({"passed":passed})).collect()
}

#[test]
fn every_metric_passing_is_required_for_a_green_report() {
    assert!(all_passed(&metrics(true, EXPECTED_METRICS)));
}

#[test]
fn a_single_failing_metric_fails_the_report() {
    let mut failing = metrics(true, EXPECTED_METRICS);
    failing.push(json!({"passed":false}));
    failing.remove(0);
    assert!(!all_passed(&failing));
    assert!(!all_passed(&metrics(false, EXPECTED_METRICS)));
}

#[test]
fn missing_metrics_or_missing_verdicts_fail_the_report() {
    assert!(!all_passed(&metrics(true, EXPECTED_METRICS - 1)));
    assert!(!all_passed(&[]));
    let mut unjudged = metrics(true, EXPECTED_METRICS);
    unjudged.push(json!({"value":1}));
    unjudged.remove(0);
    assert!(!all_passed(&unjudged));
}
