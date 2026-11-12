use crate::lexicon::{LexemeFamily, Lexicon, LexiconEntry};
use serde_json::Value;

pub fn load(resources: &Value) -> Lexicon {
    let mut lexicon = Lexicon::default();
    for (key, family) in [
        ("vocabulary", LexemeFamily::Reserved),
        ("contextualVocabulary", LexemeFamily::Contextual),
        ("functions", LexemeFamily::Function),
    ] {
        let Some(table) = resources.get(key).and_then(Value::as_object) else {
            continue;
        };
        for (identity, definition) in table {
            lexicon.insert(vocabulary_entry(identity, definition, family));
        }
    }
    for operation in operations(resources) {
        lexicon.insert(operation_entry(operation));
    }
    lexicon
}

fn operations(resources: &Value) -> impl Iterator<Item = &Value> {
    resources
        .pointer("/capabilityLibrary/operations")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
}

fn vocabulary_entry(identity: &str, definition: &Value, family: LexemeFamily) -> LexiconEntry {
    LexiconEntry {
        identity: identity.to_owned(),
        family,
        spanish: text_at(definition, "/lexemas/es"),
        english: text_at(definition, "/lexemas/en"),
        spanish_aliases: texts_at(definition, "/alias/es"),
        english_aliases: texts_at(definition, "/alias/en"),
    }
}

fn operation_entry(operation: &Value) -> LexiconEntry {
    LexiconEntry {
        identity: text_at(operation, "/identity"),
        family: LexemeFamily::Operation,
        spanish: text_at(operation, "/es"),
        english: text_at(operation, "/en"),
        spanish_aliases: Vec::new(),
        english_aliases: Vec::new(),
    }
}

pub fn text_at(value: &Value, pointer: &str) -> String {
    value
        .pointer(pointer)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

pub fn texts_at(value: &Value, pointer: &str) -> Vec<String> {
    value
        .pointer(pointer)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
        .map(str::to_owned)
        .collect()
}
