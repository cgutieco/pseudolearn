use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";

fn request() -> serde_json::Value {
    json!({"program":PROGRAM,"profile":"es","strictness":"strict","seed":1,"inputs":[],"observe":"events"})
}

fn json_at(value: &Value, path: &str) -> Value {
    value.pointer(path).cloned().unwrap_or(Value::Null)
}

#[test]
fn every_injected_stage_is_contained_as_an_internal_failure() {
    let mut session = ApiSession::default();
    let stages = session.call("fault_stages", &json!({}));
    let stages = json_at(&stages, "/value")
        .as_array()
        .cloned()
        .unwrap_or_default();
    assert!(!stages.is_empty());
    for stage in stages {
        let result = session.call("inject_fault", &json!({"stage":stage,"request":request()}));
        assert_eq!(
            json_at(&result, "/failure/family"),
            json!("internal"),
            "{stage}"
        );
        assert!(session.call("version", &json!({})).get("value").is_some());
    }
}

#[test]
fn unknown_stage_is_a_usage_failure() {
    let mut session = ApiSession::default();
    let result = session.call(
        "inject_fault",
        &json!({"stage":"nowhere","request":request()}),
    );
    assert_eq!(json_at(&result, "/failure/family"), json!("usage"));
}

#[test]
fn missing_request_is_a_usage_failure() {
    let mut session = ApiSession::default();
    let result = session.call("inject_fault", &json!({"stage":"analysis"}));
    assert_eq!(json_at(&result, "/failure/family"), json!("usage"));
}
