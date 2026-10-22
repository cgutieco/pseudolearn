use serde_json::Value;
use std::collections::BTreeSet;

pub(super) fn check(value: &Value) -> Result<(), String> {
    let schema: Value = serde_json::from_str(include_str!(
        "../../../../../schemas/help-catalog-1.schema.json"
    ))
    .map_err(|error| format!("SEE-HELP-CATALOG: invalid package schema: {error}"))?;
    crate::schema_engine::check(value, &schema, &schema, 0)
        .map_err(|error| format!("SEE-HELP-CATALOG: {error}"))?;
    unique_cards(value)?;
    unique_exclusions(value)?;
    check_examples(value)?;
    check_exclusion_conflicts(value)
}

fn unique_cards(value: &Value) -> Result<(), String> {
    let cards = array(value, "cards")?;
    let mut identifiers = BTreeSet::new();
    let mut identities = BTreeSet::new();
    for card in cards {
        let identifier = required_text(card, "id")?;
        if !valid_identifier(identifier) || !identifiers.insert(identifier) {
            return Err("SEE-HELP-CATALOG: invalid or duplicate card identity".to_owned());
        }
        if !identities.insert(identity_key(card)?) {
            return Err("SEE-HELP-CATALOG: duplicate source identity and role".to_owned());
        }
        unique_tokens(card)?;
    }
    Ok(())
}

fn unique_exclusions(value: &Value) -> Result<(), String> {
    let exclusions = array(value, "exclusions")?;
    let mut identifiers = BTreeSet::new();
    for exclusion in exclusions {
        let identifier = required_text(exclusion, "id")?;
        if !valid_identifier(identifier) || !identifiers.insert(identifier) {
            return Err("SEE-HELP-CATALOG: invalid or duplicate exclusion identity".to_owned());
        }
    }
    Ok(())
}

fn unique_tokens(card: &Value) -> Result<(), String> {
    let tokens = array(card, "tokens")?;
    let mut identities = BTreeSet::new();
    for token in tokens {
        if !identities.insert(required_text(token, "identity")?) {
            return Err("SEE-HELP-CATALOG: duplicate token identity".to_owned());
        }
    }
    Ok(())
}

fn check_examples(value: &Value) -> Result<(), String> {
    for card in array(value, "cards")? {
        check_locale_examples(card, "es")?;
        check_locale_examples(card, "en")?;
    }
    Ok(())
}

fn check_locale_examples(card: &Value, locale: &str) -> Result<(), String> {
    let content = card
        .pointer(&format!("/content/{locale}"))
        .ok_or("SEE-HELP-CATALOG: missing localized content")?;
    for example in array(content, "examples")? {
        if !available(card, "profiles", required_text(example, "profile")?)
            || !available(card, "strictness", required_text(example, "strictness")?)
        {
            return Err("SEE-HELP-CATALOG: example exceeds card availability".to_owned());
        }
    }
    Ok(())
}

fn check_exclusion_conflicts(value: &Value) -> Result<(), String> {
    for card in array(value, "cards")? {
        for exclusion in array(value, "exclusions")? {
            if identity_key(card)? == identity_key(exclusion)? && scopes_overlap(card, exclusion) {
                return Err("SEE-HELP-CATALOG: exclusion overlaps an available card".to_owned());
            }
        }
    }
    Ok(())
}

fn identity_key(value: &Value) -> Result<(String, String, String), String> {
    let identity = value
        .get("identity")
        .ok_or("SEE-HELP-CATALOG: missing identity")?;
    Ok((
        required_text(identity, "kind")?.to_owned(),
        required_text(identity, "id")?.to_owned(),
        required_text(identity, "role")?.to_owned(),
    ))
}

fn required_text<'value>(value: &'value Value, name: &str) -> Result<&'value str, String> {
    value
        .get(name)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("SEE-HELP-CATALOG: missing {name}"))
}

fn array<'value>(value: &'value Value, name: &str) -> Result<&'value Vec<Value>, String> {
    value
        .get(name)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("SEE-HELP-CATALOG: {name} must be an array"))
}

fn valid_identifier(identifier: &str) -> bool {
    let mut characters = identifier.chars();
    characters
        .next()
        .is_some_and(|character| character.is_ascii_lowercase())
        && characters.all(|character| {
            character.is_ascii_lowercase()
                || character.is_ascii_digit()
                || ['.', '_', '-'].contains(&character)
        })
}

fn available(card: &Value, dimension: &str, value: &str) -> bool {
    card.pointer(&format!("/availability/{dimension}"))
        .and_then(Value::as_array)
        .is_some_and(|values| values.iter().any(|entry| entry.as_str() == Some(value)))
}

fn scopes_overlap(left: &Value, right: &Value) -> bool {
    ["editions", "profiles", "strictness"]
        .iter()
        .all(|dimension| intersects(left, right, dimension))
}

fn intersects(left: &Value, right: &Value, dimension: &str) -> bool {
    let left = left
        .pointer(&format!("/availability/{dimension}"))
        .and_then(Value::as_array);
    let right = right
        .pointer(&format!("/availability/{dimension}"))
        .and_then(Value::as_array);
    left.zip(right)
        .is_some_and(|(left, right)| left.iter().any(|value| right.contains(value)))
}
