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
const MAXIMUM_PURPOSE: usize = 560;
const MAXIMUM_PARTS: usize = 16;
const MAXIMUM_CONSTRAINTS: usize = 8;
const MAXIMUM_COMMON_ERRORS: usize = 8;
const MAXIMUM_EXAMPLES: usize = 6;
const MAXIMUM_LOCALIZED_BYTES: usize = 4096;

pub(super) fn check(value: &Value) -> Result<(), String> {
    let cards = value
        .get("cards")
        .and_then(Value::as_array)
        .ok_or("SEE-HELP-CATALOG: missing cards")?;
    for card in cards {
        let identifier = card.get("id").and_then(Value::as_str).unwrap_or_default();
        let content = card.get("content").and_then(Value::as_object);
        for localized in content.into_iter().flat_map(|entries| entries.values()) {
            check_counts(identifier, localized)?;
            let mut total_bytes = 0usize;
            for (limit, text) in texts(localized) {
                check_text(identifier, limit, text)?;
                total_bytes = total_bytes.saturating_add(text.len());
            }
            if total_bytes > MAXIMUM_LOCALIZED_BYTES {
                return Err(format!(
                    "SEE-HELP-CATALOG: {identifier} editorial text exceeds its byte budget"
                ));
            }
        }
    }
    Ok(())
}

fn texts(localized: &Value) -> Vec<(usize, &str)> {
    let mut found = Vec::new();
    let mut single = |key: &str, limit: usize| {
        if let Some(text) = localized.get(key).and_then(Value::as_str) {
            found.push((limit, text));
        }
    };
    single("title", MAXIMUM_TITLE);
    single("summary", MAXIMUM_SENTENCE);
    single("purpose", MAXIMUM_PURPOSE);
    for key in ["constraints", "common_errors"] {
        found.extend(strings(localized, key).map(|text| (MAXIMUM_SENTENCE, text)));
    }
    for part in array(localized, "parts") {
        if let Some(text) = part.get("text").and_then(Value::as_str) {
            found.push((MAXIMUM_SENTENCE, text));
        }
    }
    for example in array(localized, "examples") {
        if let Some(text) = example.get("label").and_then(Value::as_str) {
            found.push((MAXIMUM_SENTENCE, text));
        }
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
        ("constraints", MAXIMUM_CONSTRAINTS),
        ("common_errors", MAXIMUM_COMMON_ERRORS),
        ("examples", MAXIMUM_EXAMPLES),
    ] {
        if array(localized, key).count() > maximum {
            return Err(format!("SEE-HELP-CATALOG: {identifier} has too many {key}"));
        }
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
