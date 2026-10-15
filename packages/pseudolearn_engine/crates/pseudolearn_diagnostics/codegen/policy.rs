use serde_json::{Map, Value};
use std::collections::BTreeMap;

pub fn generate(diagnostics: &Map<String, Value>) -> Result<String, String> {
    let mut classes = BTreeMap::<&str, Vec<String>>::new();
    let mut severities = BTreeMap::<(&str, &str), Vec<String>>::new();
    for (name, entry) in diagnostics {
        let variant = format!("Self::{}", super::to_pascal_case(name));
        let class = class(
            entry
                .get("clase")
                .and_then(Value::as_str)
                .ok_or("Missing class")?,
        )?;
        classes.entry(class).or_default().push(variant.clone());
        let strict = severity(entry.pointer("/severidad/estricto").and_then(Value::as_str))?;
        let flexible = severity(entry.pointer("/severidad/flexible").and_then(Value::as_str))?;
        severities
            .entry((strict, flexible))
            .or_default()
            .push(variant);
    }
    let mut generated = String::from(
        "impl DiagnosticCode { pub fn default_class(&self) -> DiagnosticClass { match self {\n",
    );
    for (class, variants) in classes {
        generated.push_str(&format!(
            "{} => DiagnosticClass::{class},\n",
            variants.join(" | ")
        ));
    }
    generated.push_str(
        "} }\npub fn severity(&self, rigor: &str) -> DiagnosticSeverity { match self {\n",
    );
    for ((strict, flexible), variants) in severities {
        let result = if strict == flexible {
            format!("DiagnosticSeverity::{strict}")
        } else {
            format!(
                "if rigor == \"flexible\" {{ DiagnosticSeverity::{flexible} }} else {{ DiagnosticSeverity::{strict} }}"
            )
        };
        generated.push_str(&format!("{} => {result},\n", variants.join(" | ")));
    }
    generated.push_str("} } }\n");
    Ok(generated)
}

fn class(name: &str) -> Result<&'static str, String> {
    match name {
        "lexical" => Ok("Lexical"),
        "syntax" => Ok("Syntactic"),
        "semantic" => Ok("Semantic"),
        "runtime" => Ok("Runtime"),
        "internal" => Ok("Internal"),
        "resource" => Ok("Resource"),
        _ => Err(format!("Unknown diagnostic class {name}")),
    }
}

fn severity(name: Option<&str>) -> Result<&'static str, String> {
    match name {
        Some("error") => Ok("Error"),
        Some("warning") => Ok("Warning"),
        Some("info") => Ok("Information"),
        _ => Err("Unknown diagnostic severity".to_owned()),
    }
}
