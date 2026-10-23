use see_model::{Block, Corpus, field};
use serde_json::Value;

const EXECUTABLE: &str = "executable";
const ACCEPTED: &str = "accepted";
const DIAGNOSTIC: &str = "diagnostic";

pub(super) fn case_kind(case: &Block) -> &'static str {
    let expected = case.fields.get("espera");
    let has_failure = expected.is_some_and(|value| value.get("fallo").is_some());
    let has_diagnostics = expected
        .and_then(|value| value.get("diagnosticos"))
        .and_then(Value::as_array)
        .is_some_and(|diagnostics| !diagnostics.is_empty());
    match field(case, "operacion") {
        "execute" if !has_failure && !has_diagnostics => EXECUTABLE,
        "analyze" if !has_diagnostics => ACCEPTED,
        _ => DIAGNOSTIC,
    }
}

pub(super) fn kind_errors(identifier: &str, content: &Value, corpus: &Corpus) -> Vec<String> {
    examples(content)
        .filter(|example| declared_kind_differs(corpus, example))
        .map(|_| format!("SEE-HELP-CATALOG: {identifier} has an example with a mismatched kind"))
        .collect()
}

pub(super) fn missing_example_errors(card: &Value) -> Vec<String> {
    let identifier = card.get("id").and_then(Value::as_str).unwrap_or_default();
    ["es", "en"]
        .into_iter()
        .filter(|locale| {
            card.pointer(&format!("/content/{locale}/examples"))
                .and_then(Value::as_array)
                .is_none_or(Vec::is_empty)
        })
        .map(|locale| format!("SEE-HELP-CATALOG: {identifier} has no {locale} example"))
        .collect()
}

fn examples(content: &Value) -> impl Iterator<Item = &Value> {
    content
        .get("examples")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
}

fn declared_kind_differs(corpus: &Corpus, example: &Value) -> bool {
    let Some(case) = super::catalog_references::example_case(corpus, example) else {
        return false;
    };
    example.get("kind").and_then(Value::as_str) != Some(case_kind(case))
}
