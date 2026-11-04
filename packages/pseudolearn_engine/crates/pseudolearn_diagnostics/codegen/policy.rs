use serde_json::{Map, Value};
use std::collections::BTreeMap;

pub fn generate(diagnostics: &Map<String, Value>) -> Result<String, String> {
    let mut classes = BTreeMap::<&str, Vec<String>>::new();
    let mut severities = BTreeMap::<&str, Vec<String>>::new();
    for (name, entry) in diagnostics {
        let variant = format!("Self::{}", super::to_pascal_case(name));
        let class = class(
            entry
                .get("clase")
                .and_then(Value::as_str)
                .ok_or("Missing class")?,
        )?;
        classes.entry(class).or_default().push(variant.clone());
        let diagnostic_severity = severity(entry.get("severidad").and_then(Value::as_str))?;
        severities
            .entry(diagnostic_severity)
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
    generated.push_str("} }\npub fn severity(&self) -> DiagnosticSeverity { match self {\n");
    for (diagnostic_severity, variants) in severities {
        generated.push_str(&format!(
            "{} => DiagnosticSeverity::{diagnostic_severity},\n",
            variants.join(" | ")
        ));
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
