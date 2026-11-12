use see_validation::resources::analysis_limits::check;
use serde_json::json;

#[test]
fn accepts_portable_limits_and_rejects_invalid_or_unknown_fields() {
    assert!(check(&json!({"nesting": 256})).is_ok());
    assert!(check(&json!({"nesting": u32::MAX})).is_ok());
    for malformed in [
        json!(null),
        json!({}),
        json!({"nesting": 0}),
        json!({"nesting": -1}),
        json!({"nesting": 1.5}),
        json!({"nesting": "256"}),
        json!({"nesting": u64::MAX}),
        json!({"nesting": 256, "unknown": 1}),
    ] {
        assert!(check(&malformed).is_err_and(|error| error.starts_with("SEE-ANALYSIS-LIMITS")));
    }
}
