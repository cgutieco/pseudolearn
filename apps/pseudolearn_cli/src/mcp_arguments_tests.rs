use crate::mcp_arguments::conform;
use serde_json::json;

fn schema() -> (serde_json::Value, serde_json::Value) {
    (
        json!({
            "source": {"type": "string"},
            "profile": {"type": "string", "enum": ["es", "en"]},
            "inputs": {"type": "array", "items": {"type": "string"}},
            "step_limit": {"type": "integer"}
        }),
        json!(["source"]),
    )
}

#[test]
fn well_formed_arguments_conform() {
    let (properties, required) = schema();
    let arguments = json!({"source": "x", "profile": "en", "inputs": ["1"], "step_limit": -3});
    assert!(conform(&arguments, &properties, &required));
    assert!(conform(
        &json!({"source": "", "extra": 1}),
        &properties,
        &required
    ));
}

#[test]
fn missing_or_mistyped_arguments_do_not_conform() {
    let (properties, required) = schema();
    for arguments in [
        json!({}),
        json!(null),
        json!([]),
        json!({"source": 7}),
        json!({"source": "x", "profile": "fr"}),
        json!({"source": "x", "inputs": "1"}),
        json!({"source": "x", "inputs": [1]}),
        json!({"source": "x", "step_limit": "5"}),
        json!({"source": "x", "step_limit": 1.5}),
    ] {
        assert!(!conform(&arguments, &properties, &required), "{arguments}");
    }
}
