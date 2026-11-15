use crate::lexicon_loading::text_at;
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SpecificationEntry {
    pub id: String,
    pub title: String,
    pub hash: String,
    pub rules: BTreeMap<String, String>,
}

pub fn anchor_parts(anchor: &str) -> (&str, Option<&str>) {
    match anchor.split_once('#') {
        Some((specification, rule)) => (specification, Some(rule)),
        None => (anchor, None),
    }
}

pub fn digest(text: &str) -> String {
    let hash = Sha256::digest(text.as_bytes());
    hash.iter().map(|byte| format!("{byte:02x}")).collect()
}

pub fn load(root: &Value) -> BTreeMap<String, SpecificationEntry> {
    root.get("specifications")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .map(specification)
        .map(|entry| (entry.id.clone(), entry))
        .collect()
}

fn specification(definition: &Value) -> SpecificationEntry {
    let rules = definition
        .get("blocks")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|block| block.get("kind").and_then(Value::as_str) == Some("regla"))
        .filter_map(|block| block.get("fields"))
        .map(|fields| (text_at(fields, "/id"), digest(&fields.to_string())))
        .collect();
    SpecificationEntry {
        id: text_at(definition, "/metadata/id"),
        title: text_at(definition, "/metadata/titulo"),
        hash: text_at(definition, "/hash"),
        rules,
    }
}
