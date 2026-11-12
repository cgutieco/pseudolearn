use see_model::{Block, Specification, field};
use serde_json::Value;

pub fn case_expectations(case: &Block) -> Vec<&Value> {
    let mut expectations: Vec<&Value> = case.fields.get("espera").into_iter().collect();
    if let Some(profiles) = case.fields.get("esperas").and_then(Value::as_object) {
        expectations.extend(profiles.values());
    }
    expectations
}

pub fn check(specification: &Specification) -> Vec<String> {
    let mut errors = Vec::new();
    for case in specification
        .blocks
        .iter()
        .filter(|block| block.kind == "caso")
    {
        for expected in case_expectations(case) {
            errors.extend(limit_kind(expected));
            if field(case, "operacion") == "ir" {
                errors.extend(ir_expectation(expected));
            }
        }
    }
    errors
}

fn limit_kind(expected: &Value) -> Option<String> {
    let reached = expected.get("terminacion").and_then(Value::as_str) == Some("limit_reached");
    let kind = expected.get("limite").and_then(Value::as_str);
    match (reached, kind) {
        (true, Some("sentencias" | "tiempo")) | (false, None) => None,
        (true, _) => Some("SEE-LIMIT-KIND: limit_reached requires sentencias or tiempo".to_owned()),
        (false, Some(_)) => Some("SEE-LIMIT-KIND: limit kind requires limit_reached".to_owned()),
    }
}

fn ir_expectation(expected: &Value) -> Option<String> {
    let Some(outcome) = expected.get("ri").and_then(Value::as_object) else {
        return Some("SEE-IR-EXPECTATION: ir case requires ri expectation".to_owned());
    };
    let accepted = outcome.get("aceptada").and_then(Value::as_bool);
    let rule = outcome.get("regla").and_then(Value::as_str);
    let reprint = outcome.get("reimpresion").and_then(Value::as_str);
    let valid = match (accepted, rule, reprint) {
        (Some(true), None, None) | (None, None, Some(_)) => outcome.len() == 1,
        (Some(false), Some(rule), None) => {
            outcome.len() == 2 && rule.starts_with("IR.WELL-FORMEDNESS#R")
        }
        _ => false,
    };
    (!valid).then(|| "SEE-IR-EXPECTATION: invalid ri expectation".to_owned())
}
