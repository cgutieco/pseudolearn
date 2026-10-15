use see_validation::resources::structural::check;
use serde_json::json;

#[test]
fn validates_structural_catalog_and_rejects_missing_forms() {
    assert!(check(&json!({"sample": {"code": "unsupported", "allow_line": false, "openings": ["interface"], "closings": []}})).is_ok());
    for malformed in [
        json!(null),
        json!({"sample": {}}),
        json!({"sample": {"code": "unsupported", "allow_line": false, "openings": [], "closings": []}}),
        json!({"sample": {"code": "unsupported", "allow_line": false, "openings": ["interface"], "closings": [2]}}),
    ] {
        assert!(check(&malformed).is_err());
    }
}
