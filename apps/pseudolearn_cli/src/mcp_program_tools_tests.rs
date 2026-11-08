use crate::mcp_program_tools::{check, format, run, step_limit, translate};
use serde_json::{Value, json};

#[test]
fn step_limit_is_clamped_and_defaults() {
    assert_eq!(step_limit(&json!({})), 10_000);
    assert_eq!(step_limit(&json!({"step_limit": 0})), 1);
    assert_eq!(step_limit(&json!({"step_limit": 9_000_000})), 100_000);
}

#[test]
fn a_program_with_errors_is_not_run() {
    let (payload, failed) = run(&json!({"source": "Algoritmo P\n  Si x >\nFinAlgoritmo\n"}));
    assert!(failed);
    assert_eq!(payload.get("executable"), Some(&Value::Bool(false)));
}

#[test]
fn check_reports_diagnostics_with_positions() {
    let (payload, failed) =
        check(&json!({"source": "Algoritmo P\n  Si x >\nFinAlgoritmo\n", "profile": "es"}));
    assert!(!failed);
    assert!(payload.pointer("/diagnostics/0/line").is_some());
}

#[test]
fn format_and_translate_refuse_broken_programs() {
    let broken = json!({"source": "Algoritmo P\n  Si x >\nFinAlgoritmo\n", "target_profile": "en"});
    assert_eq!(
        format(&broken).0.get("error"),
        Some(&Value::from("syntax_errors"))
    );
    assert_eq!(
        translate(&broken).0.get("error"),
        Some(&Value::from("translation_rejected"))
    );
    assert_eq!(
        translate(&json!({"source": "x"})).0.get("error"),
        Some(&Value::from("invalid_arguments"))
    );
}
