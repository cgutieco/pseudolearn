use super::super::CoverageRow;
use super::InventorySources;
use super::catalog_inventory::token_category;
use serde_json::{Map, Value};
use std::collections::BTreeSet;

pub(super) fn check_productions(
    role: &Value,
    productions: &Map<String, Value>,
) -> Result<(), String> {
    let declared = role
        .get("productions")
        .and_then(Value::as_array)
        .ok_or("missing role productions")?;
    if declared.iter().any(|production| {
        production
            .as_str()
            .is_none_or(|name| !productions.contains_key(name))
    }) {
        return Err("role references a missing grammar production".to_owned());
    }
    Ok(())
}

pub(super) fn card_content_covers(
    card: &Value,
    tokens: &BTreeSet<String>,
    sources: &InventorySources<'_>,
) -> Result<bool, String> {
    let required = required_token_parts(tokens, sources)?;
    for locale in ["es", "en"] {
        if !locale_covers_tokens(card, locale, &required)? {
            return Ok(false);
        }
    }
    Ok(true)
}

fn required_token_parts(
    tokens: &BTreeSet<String>,
    sources: &InventorySources<'_>,
) -> Result<BTreeSet<String>, String> {
    let mut required = BTreeSet::new();
    for token in tokens {
        let category = token_category(
            token,
            sources.vocabulary,
            sources.functions,
            &sources.operators,
        )?;
        if category != "token" {
            required.insert(token.clone());
        }
    }
    Ok(required)
}

fn locale_covers_tokens(
    card: &Value,
    locale: &str,
    required: &BTreeSet<String>,
) -> Result<bool, String> {
    let parts = card
        .pointer(&format!("/content/{locale}/parts"))
        .and_then(Value::as_array)
        .ok_or("missing localized card parts")?;
    Ok(required.iter().all(|identity| {
        parts.iter().any(|part| {
            part.get("identity").and_then(Value::as_str) == Some(identity.as_str())
                && part
                    .get("text")
                    .and_then(Value::as_str)
                    .is_some_and(|text| !text.trim().is_empty())
        })
    }))
}

pub(super) fn card_token_set(card: &Value) -> Result<BTreeSet<String>, String> {
    card.get("tokens")
        .and_then(Value::as_array)
        .ok_or("missing card tokens")?
        .iter()
        .map(|token| {
            token
                .get("identity")
                .and_then(Value::as_str)
                .map(str::to_owned)
                .ok_or_else(|| "missing card token identity".to_owned())
        })
        .collect()
}

pub(super) fn complete_scope(value: &Value) -> bool {
    [
        ("editions", "2026"),
        ("profiles", "es"),
        ("profiles", "en"),
        ("strictness", "estricto"),
        ("strictness", "flexible"),
    ]
    .iter()
    .all(|(dimension, expected)| {
        value
            .pointer(&format!("/availability/{dimension}"))
            .and_then(Value::as_array)
            .is_some_and(|values| values.iter().any(|entry| entry.as_str() == Some(expected)))
    })
}

pub(super) fn coverage_destination(record: &Value, category: &str) -> Option<String> {
    record
        .get("id")
        .and_then(Value::as_str)
        .map(|identifier| format!("{category}:{identifier}"))
}

pub(super) fn coverage_row(
    category: &str,
    identity: &str,
    role: &str,
    destination: &Option<String>,
) -> CoverageRow {
    CoverageRow {
        category: category.to_owned(),
        identity: identity.to_owned(),
        role: role.to_owned(),
        destination: destination.clone(),
    }
}

pub(super) fn row_order(left: &CoverageRow, right: &CoverageRow) -> std::cmp::Ordering {
    (&left.category, &left.identity, &left.role).cmp(&(
        &right.category,
        &right.identity,
        &right.role,
    ))
}
