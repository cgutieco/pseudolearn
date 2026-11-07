use serde_json::Value;

const FORBIDDEN_MARKUP: [char; 8] = ['<', '>', '`', '&', '\\', '[', ']', '|'];
const ACTIVE_SCHEMES: [&str; 9] = [
    "javascript:",
    "vbscript:",
    "data:",
    "file:",
    "command:",
    "http:",
    "https:",
    "mailto:",
    "://",
];
const MAXIMUM_TITLE: usize = 80;
const MAXIMUM_SENTENCE: usize = 280;
const MAXIMUM_SLOT_LABEL: usize = 40;
const MAXIMUM_PARTS: usize = 16;
const MAXIMUM_SLOTS: usize = 12;
const MAXIMUM_RULES: usize = 8;
const MAXIMUM_COMMON_ERRORS: usize = 6;
const MAXIMUM_EXAMPLES: usize = 4;
const MAXIMUM_FORM_LINES: usize = 12;
const MAXIMUM_FORM_SEGMENTS: usize = 20;
const MAXIMUM_LOCALIZED_BYTES: usize = 4096;

pub(super) fn check(value: &Value) -> Result<(), String> {
    let cards = value
        .get("cards")
        .and_then(Value::as_array)
        .ok_or("SEE-HELP-CATALOG: missing cards")?;
    for card in cards {
        let identifier = card.get("id").and_then(Value::as_str).unwrap_or_default();
        check_form(identifier, card)?;
        let content = card.get("content").and_then(Value::as_object);
        for (locale, localized) in content.into_iter().flat_map(|entries| entries.iter()) {
            check_localized(identifier, locale, localized)?;
        }
    }
    Ok(())
}

fn check_localized(identifier: &str, locale: &str, localized: &Value) -> Result<(), String> {
    check_counts(identifier, localized)?;
    let mut total_bytes = 0usize;
    for (limit, text) in texts(localized) {
        check_text(identifier, limit, text)?;
        if locale == "es" {
            super::super::spanish_neutrality::check(text)?;
        }
        total_bytes = total_bytes.saturating_add(text.len());
    }
    if total_bytes > MAXIMUM_LOCALIZED_BYTES {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} editorial text exceeds its byte budget"
        ));
    }
    Ok(())
}

fn texts(localized: &Value) -> Vec<(usize, &str)> {
    let mut found = Vec::new();
    for (key, limit) in [
        ("title", MAXIMUM_TITLE),
        ("summary", MAXIMUM_SENTENCE),
        ("result", MAXIMUM_SENTENCE),
    ] {
        if let Some(text) = localized.get(key).and_then(Value::as_str) {
            found.push((limit, text));
        }
    }
    found.extend(strings(localized, "rules").map(|text| (MAXIMUM_SENTENCE, text)));
    for (key, field, limit) in [
        ("parts", "text", MAXIMUM_SENTENCE),
        ("slots", "label", MAXIMUM_SLOT_LABEL),
        ("slots", "text", MAXIMUM_SENTENCE),
        ("common_errors", "text", MAXIMUM_SENTENCE),
        ("examples", "note", MAXIMUM_SENTENCE),
    ] {
        found.extend(
            array(localized, key)
                .filter_map(|entry| entry.get(field).and_then(Value::as_str))
                .map(|text| (limit, text)),
        );
    }
    found
}

fn array<'value>(value: &'value Value, key: &str) -> impl Iterator<Item = &'value Value> {
    value
        .get(key)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
}

fn strings<'value>(value: &'value Value, key: &str) -> impl Iterator<Item = &'value str> {
    array(value, key).filter_map(Value::as_str)
}

fn check_counts(identifier: &str, localized: &Value) -> Result<(), String> {
    for (key, maximum) in [
        ("parts", MAXIMUM_PARTS),
        ("slots", MAXIMUM_SLOTS),
        ("rules", MAXIMUM_RULES),
        ("common_errors", MAXIMUM_COMMON_ERRORS),
        ("examples", MAXIMUM_EXAMPLES),
    ] {
        if array(localized, key).count() > maximum {
            return Err(format!("SEE-HELP-CATALOG: {identifier} has too many {key}"));
        }
    }
    let invalid_label = array(localized, "slots")
        .filter_map(|slot| slot.get("label").and_then(Value::as_str))
        .any(|label| {
            !label
                .chars()
                .all(|glyph| glyph.is_alphanumeric() || glyph == ' ')
        });
    if invalid_label {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} has a slot label with symbols"
        ));
    }
    Ok(())
}

fn check_form(identifier: &str, card: &Value) -> Result<(), String> {
    let lines: Vec<&Value> = array(card, "form").collect();
    let crowded = lines
        .iter()
        .any(|line| array(line, "segments").count() > MAXIMUM_FORM_SEGMENTS);
    if lines.len() > MAXIMUM_FORM_LINES || crowded {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} has an oversized form"
        ));
    }
    Ok(())
}

fn check_text(identifier: &str, limit: usize, text: &str) -> Result<(), String> {
    if text.chars().count() > limit {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} text exceeds {limit} characters"
        ));
    }
    if text.chars().any(is_unsafe_control) {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} text contains control characters"
        ));
    }
    if text.chars().any(|glyph| FORBIDDEN_MARKUP.contains(&glyph)) {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} text contains markup"
        ));
    }
    let lowered = text.to_lowercase();
    if ACTIVE_SCHEMES.iter().any(|scheme| lowered.contains(scheme)) {
        return Err(format!(
            "SEE-HELP-CATALOG: {identifier} text contains an active URI"
        ));
    }
    Ok(())
}

fn is_unsafe_control(glyph: char) -> bool {
    glyph.is_control()
        || matches!(glyph, '\u{200E}' | '\u{200F}' | '\u{202A}'..='\u{202E}' | '\u{2066}'..='\u{2069}')
}
