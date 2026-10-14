use see_model::{Block, Corpus, field};
use serde_json::Value;

pub const CONVENTIONS_TERM: &str = "cliConventions";

pub fn conventions(value: &Value) -> Result<(), String> {
    let codes = value
        .get("codigos_salida")
        .and_then(Value::as_object)
        .ok_or("Missing exit codes")?;
    if codes.is_empty() || codes.keys().any(|code| code.parse::<u8>().is_err()) {
        return Err("Invalid exit codes".to_owned());
    }
    if see_model::strings(value.get("aperturas")).is_empty() {
        return Err("Missing top-level openers".to_owned());
    }
    Ok(())
}

pub fn check(corpus: &Corpus) -> Vec<String> {
    let conventions = resource(corpus, CONVENTIONS_TERM);
    let mut errors = Vec::new();
    for case in corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == "caso" && field(block, "operacion") == "cli")
    {
        errors.extend(exit_codes(case, conventions));
    }
    if let Some(conventions) = conventions {
        errors.extend(crate::openers::check(corpus, conventions));
    }
    errors
}

pub fn resource<'corpus>(corpus: &'corpus Corpus, term: &str) -> Option<&'corpus Value> {
    corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .find(|block| block.kind == "definicion" && field(block, "termino") == term)
        .and_then(|block| block.fields.get("valor"))
}

fn exit_codes(case: &Block, conventions: Option<&Value>) -> Vec<String> {
    let known = conventions
        .and_then(|conventions| conventions.get("codigos_salida"))
        .and_then(Value::as_object);
    let mut errors = Vec::new();
    for expected in crate::expectations::case_expectations(case) {
        let code = expected
            .get("codigo_salida")
            .and_then(Value::as_u64)
            .map(|code| code.to_string());
        let declared = code
            .as_ref()
            .is_some_and(|code| known.is_some_and(|known| known.contains_key(code)));
        if !declared {
            errors.push(format!(
                "SEE-CLI-EXIT: case {} exit code {} is not declared",
                field(case, "id"),
                code.unwrap_or_default()
            ));
        }
    }
    errors
}
