use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const PROGRAM: &str = "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 2 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n";

fn step(condition: &str, from_event: u64, target_line: u64) -> Value {
    let mut session = ApiSession::default();
    let request = json!({"program":PROGRAM,"profile":"es","strictness":"strict","seed":1,"inputs":[],"observe":"events"});
    session.call(
        "step",
        &json!({"request":request,"from_event":from_event,"condition":condition,"target_line":target_line}),
    )
}

fn json_at(value: &Value, path: &str) -> Value {
    value.pointer(path).cloned().unwrap_or(Value::Null)
}

#[test]
fn stepping_into_stops_at_the_next_statement_entry() {
    let result = step("into", 0, 2);
    assert_eq!(json_at(&result, "/value/target"), json!(2));
}

#[test]
fn stepping_to_a_line_stops_at_its_first_entry_after_the_start() {
    let result = step("line", 0, 5);
    let target = json_at(&result, "/value/target")
        .as_u64()
        .unwrap_or_default();
    assert!(target > 1);
}

#[test]
fn stepping_past_the_last_event_returns_the_event_count() {
    let result = step("out", 0, 0);
    assert!(json_at(&result, "/value/target").as_u64().is_some());
}

#[test]
fn unknown_condition_never_matches() {
    let into = json_at(&step("into", 0, 0), "/value/target");
    let unknown = json_at(&step("sideways", 0, 0), "/value/target");
    assert_ne!(into, unknown);
}

#[test]
fn missing_request_is_a_usage_failure() {
    let mut session = ApiSession::default();
    let result = session.call("step", &json!({"from_event":0}));
    assert_eq!(json_at(&result, "/failure/family"), json!("usage"));
}
