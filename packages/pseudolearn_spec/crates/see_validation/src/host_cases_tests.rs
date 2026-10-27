use crate::host_cases::check;
use see_model::Block;
use serde_json::{Value, json};
use std::collections::BTreeMap;

fn errors(host: Value) -> Vec<String> {
    let block = Block {
        kind: "caso".to_owned(),
        fields: BTreeMap::from([("anfitrion".to_owned(), host)]),
    };
    let mut found = Vec::new();
    check(&block, &mut found);
    found
}

fn fault(operation: &str, uncertain: bool) -> Value {
    json!({"faults":[{"operation":operation,"code":"interrumpido","uncertain":uncertain}]})
}

#[test]
fn uncertain_fault_is_accepted_on_every_mutating_operation() {
    for operation in [
        "file_open",
        "file_write_bytes",
        "file_write_text",
        "file_close",
        "directory_close",
        "console_write",
    ] {
        assert!(errors(fault(operation, true)).is_empty(), "{operation}");
    }
}

#[test]
fn uncertain_fault_is_rejected_on_read_only_operations() {
    for operation in ["file_read_text", "file_read_bytes", "clock_now", "arguments_values"] {
        assert_eq!(errors(fault(operation, true)).len(), 1, "{operation}");
    }
}

#[test]
fn certain_fault_is_accepted_on_read_only_operations() {
    assert!(errors(fault("file_read_text", false)).is_empty());
}

#[test]
fn invalid_memory_paths_are_rejected() {
    assert_eq!(errors(json!({"files":{"../a":"x"}})).len(), 1);
    assert_eq!(errors(json!({"files":{"a":[256]}})).len(), 1);
    assert!(errors(json!({"files":{"a/b":[0,255]}})).is_empty());
}
