use crate::lexicon_loading::{text_at, texts_at};
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct DiagnosticEntry {
    pub code: String,
    pub class: String,
    pub severity: String,
    pub spanish: String,
    pub english: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CardEntry {
    pub id: String,
    pub category: String,
    pub spanish_title: String,
    pub english_title: String,
    pub spanish_summary: String,
    pub english_summary: String,
    pub anchors: Vec<String>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FunctionEntry {
    pub identity: String,
    pub family: String,
    pub spanish: String,
    pub english: String,
    pub parameters: Vec<String>,
    pub result: String,
    pub effect: bool,
}

pub fn diagnostics(resources: &Value) -> BTreeMap<String, DiagnosticEntry> {
    entries(resources, "diagnostics")
        .map(|(code, definition)| {
            let entry = DiagnosticEntry {
                code: code.clone(),
                class: text_at(definition, "/clase"),
                severity: text_at(definition, "/severidad"),
                spanish: text_at(definition, "/mensajes/es"),
                english: text_at(definition, "/mensajes/en"),
            };
            (code.clone(), entry)
        })
        .collect()
}

pub fn cards(resources: &Value) -> BTreeMap<String, CardEntry> {
    resources
        .pointer("/helpCatalog/cards")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .map(card)
        .map(|entry| (entry.id.clone(), entry))
        .collect()
}

fn card(definition: &Value) -> CardEntry {
    let anchors = definition
        .get("anchors")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .map(|anchor| text_at(anchor, "/specification"))
        .collect();
    CardEntry {
        id: text_at(definition, "/id"),
        category: text_at(definition, "/category"),
        spanish_title: text_at(definition, "/content/es/title"),
        english_title: text_at(definition, "/content/en/title"),
        spanish_summary: text_at(definition, "/content/es/summary"),
        english_summary: text_at(definition, "/content/en/summary"),
        anchors,
    }
}

pub fn functions(resources: &Value) -> Vec<FunctionEntry> {
    let mut functions: Vec<FunctionEntry> = entries(resources, "functions")
        .map(|(identity, definition)| FunctionEntry {
            identity: identity.clone(),
            family: text_at(definition, "/family"),
            spanish: text_at(definition, "/lexemas/es"),
            english: text_at(definition, "/lexemas/en"),
            parameters: texts_at(definition, "/parametros"),
            result: text_at(definition, "/retorno"),
            effect: false,
        })
        .collect();
    functions.extend(operations(resources));
    functions
}

fn operations(resources: &Value) -> impl Iterator<Item = FunctionEntry> {
    resources
        .pointer("/capabilityLibrary/operations")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .map(|operation| FunctionEntry {
            identity: text_at(operation, "/identity"),
            family: text_at(operation, "/family"),
            spanish: text_at(operation, "/es"),
            english: text_at(operation, "/en"),
            parameters: texts_at(operation, "/parameters"),
            result: text_at(operation, "/result"),
            effect: operation
                .get("effect")
                .and_then(Value::as_bool)
                .unwrap_or(false),
        })
}

pub fn productions(resources: &Value) -> BTreeMap<String, String> {
    entries(resources, "grammar")
        .find(|(key, _)| key.as_str() == "producciones")
        .and_then(|(_, table)| table.as_object())
        .into_iter()
        .flatten()
        .filter_map(|(name, rule)| Some((name.clone(), rule.as_str()?.to_owned())))
        .collect()
}

fn entries<'value>(
    resources: &'value Value,
    key: &str,
) -> impl Iterator<Item = (&'value String, &'value Value)> {
    resources
        .get(key)
        .and_then(Value::as_object)
        .into_iter()
        .flatten()
}
