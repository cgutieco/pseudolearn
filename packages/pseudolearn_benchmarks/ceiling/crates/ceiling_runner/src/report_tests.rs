use super::{averages, family_report, group};
use std::collections::BTreeMap;

#[test]
fn rejects_incomplete_processes_and_groups() {
    assert!(group(&[]).is_err());
    assert!(averages(&BTreeMap::new()).is_err());
    let processes = BTreeMap::from([(0, vec![1.0; 30])]);
    assert!(averages(&processes).is_err());
}

#[test]
fn unfavorable_family_is_retained_with_review_gate() -> Result<(), String> {
    let families = BTreeMap::from([(("objects".to_owned(), 2), vec![vec![1.5; 10]])]);
    let report = family_report(families)?;
    assert_eq!(
        report
            .pointer("/objects~1V2/reviewBeforeR5")
            .and_then(serde_json::Value::as_bool),
        Some(true)
    );
    Ok(())
}
