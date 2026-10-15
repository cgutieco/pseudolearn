use serde_json::{Map, Value};
use std::collections::BTreeMap;

pub fn generate(diagnostics: &Map<String, Value>) -> Result<String, String> {
    let mut groups = BTreeMap::<String, Vec<String>>::new();
    for (name, diagnostic) in diagnostics {
        let fields = diagnostic
            .get("tipos_argumentos")
            .and_then(Value::as_object)
            .ok_or("Missing diagnostic argument types")?;
        if fields.is_empty() {
            continue;
        }
        let signature = fields
            .iter()
            .map(|(name, value)| {
                let kind = kind(value.as_str().ok_or("Invalid argument type")?)?;
                Ok(format!(
                    "({name:?}, crate::arguments::ArgumentKind::{kind})"
                ))
            })
            .collect::<Result<Vec<_>, String>>()?
            .join(",");
        groups
            .entry(signature)
            .or_default()
            .push(format!("Self::{}", super::to_pascal_case(name)));
    }
    let mut generated = String::from(
        "impl DiagnosticCode { pub fn argument_specs(self) -> &'static [(&'static str, crate::arguments::ArgumentKind)] { match self {\n",
    );
    for (signature, variants) in groups {
        generated.push_str(&format!("{} => &[{signature}],\n", variants.join(" | ")));
    }
    generated.push_str("_ => &[], } } }\n");
    Ok(generated)
}

fn kind(name: &str) -> Result<&'static str, String> {
    match name {
        "lexema" => Ok("Lexeme"),
        "token" => Ok("Token"),
        "tipo" => Ok("Type"),
        "termino" => Ok("Term"),
        "numero" | "entero" => Ok("Number"),
        "tipo|lexema" => Ok("TypeOrLexeme"),
        _ => Err(format!("Unknown diagnostic argument type {name}")),
    }
}
