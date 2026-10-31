use see_model::{Specification, field};
use serde_json::Value;

pub mod analysis_limits;
mod capability_library;
#[cfg(test)]
mod capability_library_tests;
pub mod grammar;
pub mod help_catalog;
pub mod lexicon;
pub mod library_facets;
pub mod spanish_neutrality;
pub mod structural;
pub mod textmate_grammar;

pub fn check(specification: &Specification) -> Vec<String> {
    let mut errors = Vec::new();
    for definition in &specification.blocks {
        let Some(value) = definition.fields.get("valor") else {
            continue;
        };
        if field(definition, "termino") == crate::messages::CATALOG_TERM {
            errors.extend(crate::messages::check(value));
            continue;
        }
        let result = match field(definition, "termino") {
            "vocabulary" | "contextualVocabulary" | "functions" => lexicon::check(value),
            "capabilityLibrary" => capability_library::check(value),
            "diagnostics" => diagnostics(value),
            "grammar" => grammar::check(value),
            "helpCatalog" => help_catalog::check(value),
            "analysisLimits" => analysis_limits::check(value),
            "textmateIdentifier" | "textmateNumber" | "textmateComment"
            | "textmateTextLiteral" | "textmateAccentFold" => {
                textmate_grammar::check(field(definition, "termino"), value)
            }
            "unsupportedConstructs" => structural::check(value),
            crate::trace::ALPHABET_TERM => crate::trace::catalog(value),
            crate::cli::CONVENTIONS_TERM => crate::cli::conventions(value),
            name => Err(format!("Unknown normative resource {name}")),
        };
        if let Err(error) = result {
            if error.starts_with("SEE-") {
                errors.push(error);
            } else {
                errors.push(format!(
                    "SEE-RESOURCE: {}: {error}",
                    specification.metadata.id
                ));
            }
        }
    }
    errors
}

pub fn check_references(corpus: &see_model::Corpus) -> Vec<String> {
    let mut errors = Vec::new();
    for specification in corpus {
        for definition in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "definicion")
        {
            if field(definition, "termino") != "helpCatalog" {
                continue;
            }
            let Some(value) = definition.fields.get("valor") else {
                continue;
            };
            if help_catalog::check(value).is_ok() {
                errors.extend(help_catalog::references(value, corpus));
            }
        }
    }
    errors
}

fn diagnostics(value: &Value) -> Result<(), String> {
    let entries = value.as_object().ok_or("Invalid diagnostic catalog")?;
    if entries.is_empty() {
        return Err("Empty diagnostic catalog".to_owned());
    }
    for entry in entries.values() {
        diagnostic(entry)?;
    }
    Ok(())
}

fn diagnostic(entry: &Value) -> Result<(), String> {
    let messages = entry.get("mensajes").ok_or("Missing messages")?;
    let mut markers = Vec::new();
    for profile in ["es", "en"] {
        let pattern = messages
            .get(profile)
            .and_then(Value::as_str)
            .ok_or("Missing locale")?;
        if pattern.trim().is_empty() {
            return Err("Empty message".to_owned());
        }
        if profile == "es" {
            spanish_neutrality::check(pattern)?;
        }
        markers.push(placeholders(pattern)?);
    }
    let arguments = see_model::strings(entry.get("argumentos"));
    let required: std::collections::BTreeSet<_> = arguments.into_iter().collect();
    if markers.iter().any(|actual| actual != &required) {
        return Err("Message argument mismatch".to_owned());
    }
    argument_types(entry, &required)?;
    severity(entry)
}

pub(crate) fn argument_types(
    entry: &Value,
    required: &std::collections::BTreeSet<&str>,
) -> Result<(), String> {
    let types = entry
        .get("tipos_argumentos")
        .and_then(Value::as_object)
        .ok_or("Missing argument types")?;
    if types
        .keys()
        .map(String::as_str)
        .collect::<std::collections::BTreeSet<_>>()
        != *required
    {
        return Err("Argument type names mismatch".to_owned());
    }
    let allowed = [
        "numero",
        "entero",
        "token",
        "tipo",
        "lexema",
        "termino",
        "texto",
        "tipo|lexema",
    ];
    if types
        .values()
        .any(|value| value.as_str().is_none_or(|name| !allowed.contains(&name)))
    {
        return Err("Unknown argument type".to_owned());
    }
    Ok(())
}

pub(crate) fn placeholders(pattern: &str) -> Result<std::collections::BTreeSet<&str>, String> {
    let mut names = std::collections::BTreeSet::new();
    let mut remaining = pattern;
    while let Some(open) = remaining.find('{') {
        let suffix = remaining
            .get(open.saturating_add(1)..)
            .ok_or("Invalid marker")?;
        let close = suffix.find('}').ok_or("Unclosed marker")?;
        names.insert(suffix.get(..close).ok_or("Invalid marker")?);
        remaining = suffix
            .get(close.saturating_add(1)..)
            .ok_or("Invalid marker")?;
    }
    Ok(names)
}

fn severity(entry: &Value) -> Result<(), String> {
    let levels = entry.get("severidad").ok_or("Missing severity")?;
    let strict = rank(levels.get("estricto"))?;
    let flexible = rank(levels.get("flexible"))?;
    let policy = entry
        .get("politica")
        .and_then(Value::as_str)
        .ok_or("Missing policy")?;
    let valid = match policy {
        "A" => strict == 2 && flexible == 2,
        "B" => strict == 2 && flexible == 1,
        "C" | "E" => strict == 1 && flexible == 1,
        "D" => strict == 0 && flexible == 0,
        _ => false,
    };
    if !valid {
        return Err("Invalid severity policy".to_owned());
    }
    Ok(())
}

fn rank(level: Option<&Value>) -> Result<u8, String> {
    match level.and_then(Value::as_str) {
        Some("info") => Ok(0),
        Some("warning") => Ok(1),
        Some("error") => Ok(2),
        _ => Err("Unknown severity".to_owned()),
    }
}
