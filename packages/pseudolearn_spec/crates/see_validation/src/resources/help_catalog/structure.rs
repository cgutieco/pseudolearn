use serde_json::Value;
use std::collections::BTreeSet;

const LOCALES: [&str; 2] = ["es", "en"];

pub(super) fn check(value: &Value) -> Result<(), String> {
    for card in entries(value, "cards") {
        let identifier = card.get("id").and_then(Value::as_str).unwrap_or_default();
        let form_slots = form_slots(identifier, card)?;
        for locale in LOCALES {
            let content = card
                .pointer(&format!("/content/{locale}"))
                .ok_or("SEE-HELP-CATALOG: missing localized content")?;
            check_slots(identifier, content, &form_slots)?;
            check_parts(identifier, card, content)?;
            check_examples(identifier, content)?;
        }
        check_parity(identifier, card)?;
    }
    Ok(())
}

fn form_slots(identifier: &str, card: &Value) -> Result<BTreeSet<String>, String> {
    let slots: Vec<&str> = entries(card, "form")
        .flat_map(|line| entries(line, "segments"))
        .filter_map(|segment| segment.get("slot").and_then(Value::as_str))
        .collect();
    if slots.iter().any(|slot| !valid_slot(slot)) {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} has an invalid slot identity"
        ));
    }
    Ok(slots.into_iter().map(str::to_owned).collect())
}

fn check_slots(identifier: &str, content: &Value, form: &BTreeSet<String>) -> Result<(), String> {
    let declared: Vec<String> = entries(content, "slots")
        .filter_map(|slot| slot.get("id").and_then(Value::as_str))
        .map(str::to_owned)
        .collect();
    let unique: BTreeSet<String> = declared.iter().cloned().collect();
    if unique.len() != declared.len() || &unique != form {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} slots differ from its form"
        ));
    }
    Ok(())
}

fn check_parts(identifier: &str, card: &Value, content: &Value) -> Result<(), String> {
    let tokens: BTreeSet<&str> = entries(card, "tokens")
        .filter_map(|token| token.get("identity").and_then(Value::as_str))
        .collect();
    let mut seen = BTreeSet::new();
    for part in entries(content, "parts") {
        let identity = part
            .get("identity")
            .and_then(Value::as_str)
            .unwrap_or_default();
        if !tokens.contains(identity) || !seen.insert(identity) {
            return Err(format!(
                "SEE-HELP-CATALOG: {identifier} has a part outside its tokens"
            ));
        }
    }
    Ok(())
}

fn check_examples(identifier: &str, content: &Value) -> Result<(), String> {
    let mut references = BTreeSet::new();
    for example in entries(content, "examples") {
        if !references.insert(case_key(example)) {
            return Err(format!(
                "SEE-HELP-CATALOG: {identifier} has a duplicate example reference"
            ));
        }
    }
    Ok(())
}

fn check_parity(identifier: &str, card: &Value) -> Result<(), String> {
    let projections: Vec<Projection> = LOCALES
        .iter()
        .filter_map(|locale| card.pointer(&format!("/content/{locale}")))
        .map(projection)
        .collect();
    if projections
        .windows(2)
        .any(|pair| pair.first() != pair.get(1))
    {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} differs in structure between languages"
        ));
    }
    Ok(())
}

type Projection = (Vec<(String, String)>, Vec<String>, Vec<String>, Vec<String>);

fn projection(content: &Value) -> Projection {
    let examples = entries(content, "examples")
        .map(|example| (case_key(example), text(example, "kind")))
        .collect();
    let errors = entries(content, "common_errors")
        .map(|error| error.get("case").map(case_key).unwrap_or_default())
        .collect();
    let slots = entries(content, "slots")
        .map(|slot| text(slot, "id"))
        .collect();
    let parts = entries(content, "parts")
        .map(|part| text(part, "identity"))
        .collect();
    (examples, errors, slots, parts)
}

fn case_key(reference: &Value) -> String {
    format!(
        "{}@{}#{}",
        text(reference, "specification"),
        text(reference, "version"),
        text(reference, "case")
    )
}

fn text(value: &Value, key: &str) -> String {
    value
        .get(key)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn entries<'value>(value: &'value Value, key: &str) -> impl Iterator<Item = &'value Value> {
    value
        .get(key)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
}

fn valid_slot(slot: &str) -> bool {
    let mut characters = slot.chars();
    characters
        .next()
        .is_some_and(|character| character.is_ascii_lowercase())
        && characters.all(|character| {
            character.is_ascii_lowercase() || character.is_ascii_digit() || character == '_'
        })
}
