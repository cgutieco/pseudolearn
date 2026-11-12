use super::super::catalog_references::specification;
use see_model::{Corpus, field};
use serde_json::{Map, Value};
use std::collections::BTreeSet;

const OPERATOR_PRODUCTIONS: [&str; 9] = [
    "assignmentStatement",
    "disjunction",
    "conjunction",
    "equality",
    "ordering",
    "addition",
    "multiplication",
    "powerExpression",
    "unary",
];

pub(super) struct TokenSources<'source> {
    pub(super) vocabulary: &'source Map<String, Value>,
    pub(super) functions: &'source Map<String, Value>,
    pub(super) capability_library: &'source Map<String, Value>,
    pub(super) productions: &'source Map<String, Value>,
    pub(super) operators: BTreeSet<String>,
}

pub(super) fn token_category(
    identity: &str,
    sources: &TokenSources<'_>,
) -> Result<&'static str, String> {
    if sources.operators.contains(identity) {
        return Ok("operator");
    }
    if sources.functions.contains_key(identity) {
        return Ok("builtin");
    }
    if sources
        .capability_library
        .get("operations")
        .and_then(Value::as_array)
        .is_some_and(|operations| {
            operations.iter().any(|operation| {
                operation.get("identity").and_then(Value::as_str) == Some(identity)
            })
        })
    {
        return Ok("builtin");
    }
    if let Some(entry) = sources.vocabulary.get(identity) {
        return if alphabetic_lexeme(entry) {
            Ok("keyword")
        } else {
            Ok("token")
        };
    }
    Err(format!("role references stale token identity {identity}"))
}

pub(super) fn alphabetic_lexeme(value: &Value) -> bool {
    value
        .get("lexemas")
        .and_then(Value::as_object)
        .is_some_and(|lexemes| {
            lexemes
                .values()
                .filter_map(Value::as_str)
                .any(|lexeme| lexeme.chars().any(char::is_alphabetic))
        })
}

pub(super) fn grammar_operators(
    productions: &Map<String, Value>,
    vocabulary: &Map<String, Value>,
) -> BTreeSet<String> {
    let mut operators = BTreeSet::new();
    for name in OPERATOR_PRODUCTIONS {
        if let Some(production) = productions.get(name).and_then(Value::as_str) {
            insert_operator_markers(production, vocabulary, &mut operators);
        }
    }
    operators
}

fn insert_operator_markers(
    production: &str,
    vocabulary: &Map<String, Value>,
    operators: &mut BTreeSet<String>,
) {
    for marker in production.split('@').skip(1) {
        let identity: String = marker
            .chars()
            .take_while(|character| character.is_ascii_alphanumeric() || *character == '_')
            .collect();
        if vocabulary.contains_key(&identity) {
            operators.insert(identity);
        }
    }
}

pub(super) fn operator_inventory(value: &Value) -> Result<BTreeSet<String>, String> {
    string_set(
        value.get("inventory").ok_or("missing inventory")?,
        "operators",
    )
}

pub(super) fn role_inventory(value: &Value) -> Result<&Vec<Value>, String> {
    array(value, "/inventory/roles")
}

pub(super) fn string_set(value: &Value, name: &str) -> Result<BTreeSet<String>, String> {
    value
        .get(name)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("missing {name}"))?
        .iter()
        .map(|entry| {
            entry
                .as_str()
                .map(str::to_owned)
                .ok_or_else(|| format!("invalid {name} entry"))
        })
        .collect()
}

pub(super) fn array<'value>(
    value: &'value Value,
    pointer: &str,
) -> Result<&'value Vec<Value>, String> {
    value
        .pointer(pointer)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("missing array at {pointer}"))
}

pub(super) fn identity_key(identity: &Value) -> Result<(String, String, String), String> {
    Ok((
        identity
            .get("kind")
            .and_then(Value::as_str)
            .ok_or("missing identity kind")?
            .to_owned(),
        identity
            .get("id")
            .and_then(Value::as_str)
            .ok_or("missing identity id")?
            .to_owned(),
        identity
            .get("role")
            .and_then(Value::as_str)
            .ok_or("missing identity role")?
            .to_owned(),
    ))
}

pub(super) fn source_resource<'corpus>(
    corpus: &'corpus Corpus,
    identifier: &str,
    term: &str,
) -> Result<&'corpus Map<String, Value>, String> {
    let source = specification(corpus, identifier, "1.0.0")
        .ok_or_else(|| format!("missing source specification {identifier}"))?
        .blocks
        .iter()
        .find(|block| block.kind == "definicion" && field(block, "termino") == term)
        .and_then(|block| block.fields.get("valor"))
        .and_then(Value::as_object)
        .ok_or_else(|| format!("missing source resource {identifier}/{term}"))?;
    Ok(source)
}
