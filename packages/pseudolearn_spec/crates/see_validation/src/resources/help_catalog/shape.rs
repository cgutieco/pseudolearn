use serde_json::Value;
use std::collections::BTreeSet;

const MAXIMUM_NESTING: usize = 10;

pub(super) fn check(value: &Value) -> Result<(), String> {
    if exceeds_nesting(value, 0) {
        return Err(format!(
            "SEE-HELP-CATALOG: resource nesting exceeds {MAXIMUM_NESTING}"
        ));
    }
    let schema: Value = serde_json::from_str(include_str!(
        "../../../../../schemas/help-catalog-1.schema.json"
    ))
    .map_err(|error| format!("SEE-HELP-CATALOG: invalid package schema: {error}"))?;
    crate::schema_engine::check(value, &schema, &schema, 0)
        .map_err(|error| format!("SEE-HELP-CATALOG: {error}"))?;
    unique_roles(value)?;
    unique_cards(value)?;
    unique_exclusions(value)?;
    check_examples(value)?;
    check_exclusion_conflicts(value)?;
    check_exclusion_justifications(value)
}

fn exceeds_nesting(value: &Value, depth: usize) -> bool {
    if depth > MAXIMUM_NESTING {
        return true;
    }
    let next = depth.saturating_add(1);
    match value {
        Value::Object(entries) => entries.values().any(|entry| exceeds_nesting(entry, next)),
        Value::Array(elements) => elements
            .iter()
            .any(|element| exceeds_nesting(element, next)),
        _ => false,
    }
}

fn unique_roles(value: &Value) -> Result<(), String> {
    let roles = value
        .pointer("/inventory/roles")
        .and_then(Value::as_array)
        .ok_or("SEE-HELP-CATALOG: missing role inventory")?;
    let mut identities = BTreeSet::new();
    for role in roles {
        if !identities.insert(identity_key(role)?) {
            return Err("SEE-HELP-CATALOG: duplicate inventory role identity".to_owned());
        }
    }
    Ok(())
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
    let mut references = BTreeSet::new();
    for example in array(content, "examples")? {
        let profile = required_text(example, "profile")?;
        let strictness = required_text(example, "strictness")?;
        if !available(card, "profiles", profile) || !available(card, "strictness", strictness) {
            return Err("SEE-HELP-CATALOG: example exceeds card availability".to_owned());
        }
        if profile != locale {
            return Err("SEE-HELP-CATALOG: example profile differs from its locale".to_owned());
        }
        let key = (
            required_text(example, "specification")?,
            required_text(example, "version")?,
            required_text(example, "case")?,
            strictness,
        );
        if !references.insert(key) {
            return Err("SEE-HELP-CATALOG: duplicate example reference".to_owned());
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

fn check_exclusion_justifications(value: &Value) -> Result<(), String> {
    let roles = value
        .pointer("/inventory/roles")
        .and_then(Value::as_array)
        .ok_or("SEE-HELP-CATALOG: missing role inventory")?;
    for exclusion in array(value, "exclusions")? {
        let reason = required_text(exclusion, "reason")?;
        let identity = identity_key(exclusion)?;
        let active_role = roles
            .iter()
            .any(|role| identity_key(role).is_ok_and(|key| key == identity));
        if active_role && reason != "alias_of" {
            return Err("SEE-HELP-CATALOG: active role exclusion must name an alias".to_owned());
        }
        if reason == "alias_of" {
            check_alias_exclusion(exclusion, &identity, roles, array(value, "cards")?)?;
        } else if exclusion.get("alias_of").is_some() {
            return Err("SEE-HELP-CATALOG: unexpected alias target".to_owned());
        }
    }
    Ok(())
}

fn check_alias_exclusion(
    exclusion: &Value,
    identity: &(String, String, String),
    roles: &[Value],
    cards: &[Value],
) -> Result<(), String> {
    let alias = exclusion
        .get("alias_of")
        .ok_or("SEE-HELP-CATALOG: missing alias target")?;
    let target_identity = identity_fields(alias)?;
    if &target_identity == identity {
        return Err("SEE-HELP-CATALOG: alias target repeats its identity".to_owned());
    }
    let role = roles
        .iter()
        .find(|role| identity_key(role).is_ok_and(|key| &key == identity))
        .ok_or("SEE-HELP-CATALOG: excluded alias has no inventory role")?;
    let card = cards
        .iter()
        .find(|card| identity_key(card).is_ok_and(|key| key == target_identity))
        .ok_or("SEE-HELP-CATALOG: alias target has no card")?;
    if role_tokens(role)? != card_tokens(card)? || !scope_contains(card, exclusion) {
        return Err("SEE-HELP-CATALOG: alias target does not cover the excluded role".to_owned());
    }
    Ok(())
}

fn identity_fields(identity: &Value) -> Result<(String, String, String), String> {
    Ok((
        required_text(identity, "kind")?.to_owned(),
        required_text(identity, "id")?.to_owned(),
        required_text(identity, "role")?.to_owned(),
    ))
}

fn role_tokens(role: &Value) -> Result<BTreeSet<String>, String> {
    array(role, "tokens")?
        .iter()
        .map(|token| {
            token
                .as_str()
                .map(str::to_owned)
                .ok_or_else(|| "SEE-HELP-CATALOG: invalid role token identity".to_owned())
        })
        .collect()
}

fn card_tokens(card: &Value) -> Result<BTreeSet<String>, String> {
    array(card, "tokens")?
        .iter()
        .map(|token| required_text(token, "identity").map(str::to_owned))
        .collect()
}

fn scope_contains(container: &Value, contained: &Value) -> bool {
    ["editions", "profiles", "strictness"]
        .iter()
        .all(|dimension| {
            let available = container
                .pointer(&format!("/availability/{dimension}"))
                .and_then(Value::as_array);
            let requested = contained
                .pointer(&format!("/availability/{dimension}"))
                .and_then(Value::as_array);
            available
                .zip(requested)
                .is_some_and(|(available, requested)| {
                    requested.iter().all(|value| available.contains(value))
                })
        })
}

fn identity_key(value: &Value) -> Result<(String, String, String), String> {
    let identity = value
        .get("identity")
        .ok_or("SEE-HELP-CATALOG: missing identity")?;
    identity_fields(identity)
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
