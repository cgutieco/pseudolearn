use pseudolearn_api::probe;
use serde_json::{Value, json};

const LOOP: &str = "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 1 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n";

fn json_at(value: &Value, path: &str) -> Value {
    value.pointer(path).cloned().unwrap_or(Value::Null)
}

#[test]
fn reprint_probe_returns_the_exact_text_including_bom_and_errors() {
    let text = "\u{FEFF}Algoritmo P\r\n@ \"sin cierre";
    let response = probe(&json!({"operation":"reprint","program":text,"profile":"es"}));
    assert_eq!(json_at(&response, "/reprint"), json!(text));
}

#[test]
fn reprint_probe_handles_empty_text() {
    let response = probe(&json!({"operation":"reprint","program":"","profile":"es"}));
    assert_eq!(json_at(&response, "/reprint"), json!(""));
}

#[test]
fn statement_mass_probe_aligns_tree_statements_with_observation_points() {
    let response = probe(&json!({"operation":"statement_mass","program":LOOP,"profile":"es"}));
    assert_eq!(json_at(&response, "/compiled"), json!(true));
    for field in ["statements", "enters", "exits", "mass"] {
        assert_eq!(
            json_at(&response, &format!("/{field}")),
            json!(4),
            "{field}"
        );
    }
}

#[test]
fn statement_mass_probe_reports_uncompilable_programs() {
    let response = probe(
        &json!({"operation":"statement_mass","program":"Algoritmo P\nx <- ;\nFinAlgoritmo\n","profile":"es"}),
    );
    assert_eq!(json_at(&response, "/compiled"), json!(false));
}

#[test]
fn unknown_probe_operation_is_a_failure_value() {
    let response = probe(&json!({"operation":"unknown"}));
    assert!(response.get("failure").is_some());
}
