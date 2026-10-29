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
    for operation in [
        "file_read_text",
        "file_read_bytes",
        "clock_now",
        "arguments_values",
    ] {
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

fn case_errors(fields: BTreeMap<String, Value>) -> Vec<String> {
    let block = Block {
        kind: "caso".to_owned(),
        fields,
    };
    let mut found = Vec::new();
    check(&block, &mut found);
    found
}

#[test]
fn pending_effect_expectation_requires_awaiting_effect_termination() {
    let invalid = BTreeMap::from([(
        "espera".to_owned(),
        json!({"terminacion":"completed","efecto_pendiente":{"effect_seq":1}}),
    )]);
    assert_eq!(case_errors(invalid).len(), 1);
    let valid = BTreeMap::from([(
        "espera".to_owned(),
        json!({"terminacion":"awaiting_effect","efecto_pendiente":{"effect_seq":1}}),
    )]);
    assert!(case_errors(valid).is_empty());
}

#[test]
fn non_increasing_expected_effect_sequence_is_rejected() {
    let invalid = BTreeMap::from([(
        "espera".to_owned(),
        json!({
            "anfitrion_observado": {
                "efectos": [
                    {"effect_seq": 2, "capability_kind": "clock", "operation": "clock_now", "outcome": "committed"},
                    {"effect_seq": 2, "capability_kind": "clock", "operation": "clock_now", "outcome": "committed"}
                ]
            }
        }),
    )]);
    assert_eq!(case_errors(invalid).len(), 1);
}

#[test]
fn incompatible_replay_and_alteration_options_are_rejected() {
    let missing_failure = BTreeMap::from([(
        "anfitrion".to_owned(),
        json!({"alterar_cinta":"truncar_entrada"}),
    )]);
    assert_eq!(case_errors(missing_failure).len(), 1);
    let conflicting = BTreeMap::from([
        (
            "anfitrion".to_owned(),
            json!({"grabar_y_reproducir":true,"alterar_cinta":"truncar_entrada"}),
        ),
        (
            "espera".to_owned(),
            json!({"anfitrion_observado":{"reproduccion_fallo":"replay_truncated_tape"}}),
        ),
    ]);
    assert_eq!(case_errors(conflicting).len(), 1);
}

use crate::host_cases::check_effect_sequence;

fn effect_errors_for(effects: &[Value]) -> usize {
    let mut errors = Vec::new();
    check_effect_sequence(effects, &mut errors);
    errors.len()
}

#[test]
fn ordered_effects_without_delivery_marks_are_accepted() {
    assert_eq!(
        effect_errors_for(&[json!({"effect_seq": 1}), json!({"effect_seq": 2})]),
        0
    );
}

#[test]
fn repeated_or_decreasing_effects_without_delivery_marks_are_rejected() {
    assert_eq!(
        effect_errors_for(&[json!({"effect_seq": 2}), json!({"effect_seq": 1})]),
        1
    );
    assert_eq!(
        effect_errors_for(&[json!({"effect_seq": 1}), json!({"effect_seq": 1})]),
        1
    );
}

#[test]
fn out_of_order_delivery_is_accepted_when_marks_increase() {
    let effects = [
        json!({"effect_seq": 3, "delivery_seq": 1}),
        json!({"effect_seq": 1, "delivery_seq": 3}),
    ];
    assert_eq!(effect_errors_for(&effects), 0);
}

#[test]
fn out_of_order_delivery_is_rejected_for_duplicate_requests_or_decreasing_marks() {
    let duplicate = [
        json!({"effect_seq": 2, "delivery_seq": 1}),
        json!({"effect_seq": 2, "delivery_seq": 3}),
    ];
    assert_eq!(effect_errors_for(&duplicate), 1);
    let decreasing = [
        json!({"effect_seq": 3, "delivery_seq": 5}),
        json!({"effect_seq": 1, "delivery_seq": 3}),
    ];
    assert_eq!(effect_errors_for(&decreasing), 1);
}

#[test]
fn an_empty_effect_list_is_accepted() {
    assert_eq!(effect_errors_for(&[]), 0);
}
