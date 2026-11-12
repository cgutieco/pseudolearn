use see_model::{Specification, field};
use serde_json::Value;

pub mod analysis_limits;
mod capability_library;
#[cfg(test)]
mod capability_library_tests;
pub mod diagnostic_terms;
pub mod grammar;
pub mod help_catalog;
pub mod lexicon;
pub mod library_facets;
pub mod library_reserved;
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
        let result = resource(specification, field(definition, "termino"), value);
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

fn resource(specification: &Specification, term: &str, value: &Value) -> Result<(), String> {
    match term {
        "vocabulary" | "contextualVocabulary" | "functions" => lexicon::check(value),
        "capabilityLibrary" => capability_library::check(value),
        "diagnostics" => diagnostics(value),
        "diagnosticTerms" => diagnostic_terms::check(value, catalog(specification)),
        "grammar" => grammar::check(value),
        "helpCatalog" => help_catalog::check(value),
        "analysisLimits" => analysis_limits::check(value),
        "textmateIdentifier"
        | "textmateNumber"
        | "textmateComment"
        | "textmateTextLiteral"
        | "textmateAccentFold" => textmate_grammar::check(term, value),
        "unsupportedConstructs" => structural::check(value),
        crate::trace::ALPHABET_TERM => crate::trace::catalog(value),
        crate::cli::CONVENTIONS_TERM => crate::cli::conventions(value),
        name => Err(format!("Unknown normative resource {name}")),
    }
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

fn catalog(specification: &Specification) -> Option<&Value> {
    specification
        .blocks
        .iter()
        .find(|block| field(block, "termino") == "diagnostics")
        .and_then(|block| block.fields.get("valor"))
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
    let actual = entry
        .get("severidad")
        .and_then(Value::as_str)
        .ok_or("Missing severity")?;
    let policy = entry
        .get("politica")
        .and_then(Value::as_str)
        .ok_or("Missing policy")?;
    let expected = match policy {
        "A" => "error",
        "C" | "E" => "warning",
        "D" => "info",
        _ => return Err("Invalid severity policy".to_owned()),
    };
    if actual != expected {
        return Err("Invalid severity policy".to_owned());
    }
    Ok(())
}
