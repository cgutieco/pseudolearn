use super::{group, select};
use serde_json::json;

#[test]
fn rejects_incomplete_memory_processes() {
    assert!(group(&[]).is_err());
    assert!(group(&[json!({"validated":true})]).is_err());
}

#[test]
fn selection_requires_guards_and_resolves_uncertainty_by_simplicity() {
    let reports = [
        json!({"collector":"SizeClasses","eligible":true,"confidence95":[1.0,1.0]}),
        json!({"collector":"Lines","eligible":true,"confidence95":[0.95,1.02]}),
        json!({"collector":"ReferenceCounts","eligible":false,"confidence95":[0.5,0.6]}),
    ];
    assert_eq!(select(&reports), Ok(&json!("SizeClasses")));
    assert!(select(&[json!({"collector":"Lines","eligible":false})]).is_err());
}
