use crate::projection::project;
use serde_json::json;

#[test]
fn projection_keeps_integer_extremes_and_real_tokens_as_text() {
    let value = json!({"minimum":i64::MIN,"maximum":i64::MAX,"unsigned":u64::MAX,"real":1.5});
    let projected = project(value);
    assert_eq!(
        projected.get("minimum").and_then(serde_json::Value::as_str),
        Some("-9223372036854775808")
    );
    assert_eq!(
        projected.get("maximum").and_then(serde_json::Value::as_str),
        Some("9223372036854775807")
    );
    assert_eq!(
        projected
            .get("unsigned")
            .and_then(serde_json::Value::as_str),
        Some("18446744073709551615")
    );
    assert_eq!(
        projected.get("real").and_then(serde_json::Value::as_str),
        Some("1.5")
    );
}

#[test]
fn projection_retains_text_null_boolean_and_nested_values() {
    let value = json!([null,true,{"text":"18446744073709551615","nested":[0,-1]}]);
    assert_eq!(
        project(value),
        json!([null,true,{"text":"18446744073709551615","nested":["0","-1"]}])
    );
}
