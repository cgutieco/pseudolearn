use serde_json::Value;

pub fn generate(value: &Value) -> Result<String, String> {
    let entries = value.as_object().ok_or("Missing structural forms")?;
    let mut generated = String::from(
        "pub fn unsupported_opening(word: &str) -> Option<(pseudolearn_diagnostics::DiagnosticCode, &'static [&'static str], bool)> { match word {\n",
    );
    for entry in entries.values() {
        let code = entry
            .get("code")
            .and_then(Value::as_str)
            .ok_or("Missing structural code")?;
        let mut characters = code.chars();
        let code = characters
            .next()
            .map(|first| format!("{}{}", first.to_uppercase(), characters.as_str()))
            .ok_or("Empty structural code")?;
        let forms = words(entry, "openings")?.join(" | ");
        let closings = words(entry, "closings")?.join(",");
        let alone = entry
            .get("allow_line")
            .and_then(Value::as_bool)
            .ok_or("Missing structural policy")?;
        generated.push_str(&format!("{forms} => Some((pseudolearn_diagnostics::DiagnosticCode::{code}, &[{closings}], {alone})),\n"));
    }
    generated.push_str("_ => None } }\n");
    Ok(generated)
}

fn words(entry: &Value, field: &str) -> Result<Vec<String>, String> {
    entry
        .get(field)
        .and_then(Value::as_array)
        .ok_or("Missing structural forms")?
        .iter()
        .map(|word| {
            word.as_str()
                .map(|word| format!("{:?}", word.to_lowercase()))
                .ok_or("Invalid structural form".to_owned())
        })
        .collect()
}
