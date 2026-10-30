use serde_json::Value;

pub fn check(term: &str, value: &Value) -> Result<(), String> {
    match term {
        "textmateIdentifier" => pattern_fields(value, &["start", "continue"]),
        "textmateNumber" => pattern_fields(value, &["integer", "real"]),
        "textmateComment" => pattern_fields(value, &["start"]),
        "textmateTextLiteral" => text_literal(value),
        "textmateAccentFold" => accent_fold(value),
        _ => Err("Unknown TextMate definition".to_owned()),
    }
}

fn pattern_fields(value: &Value, fields: &[&str]) -> Result<(), String> {
    let object = value.as_object().ok_or("Invalid TextMate patterns")?;
    for field in fields {
        if object.get(*field).and_then(Value::as_str).is_none_or(str::is_empty) {
            return Err(format!("Missing TextMate pattern {field}"));
        }
    }
    Ok(())
}

fn text_literal(value: &Value) -> Result<(), String> {
    let object = value.as_object().ok_or("Invalid TextMate text literal")?;
    for field in ["delimiters", "escapeCodes"] {
        let items = object
            .get(field)
            .and_then(Value::as_array)
            .ok_or_else(|| format!("Missing TextMate text literal {field}"))?;
        if items.is_empty() || items.iter().any(|item| item.as_str().is_none_or(str::is_empty)) {
            return Err(format!("Invalid TextMate text literal {field}"));
        }
    }
    if object
        .get("lineBreaksAllowed")
        .and_then(Value::as_bool)
        .is_none()
    {
        return Err("Missing TextMate line break policy".to_owned());
    }
    Ok(())
}

fn accent_fold(value: &Value) -> Result<(), String> {
    let entries = value.as_object().ok_or("Invalid TextMate accent fold")?;
    if entries.is_empty() {
        return Err("Empty TextMate accent fold".to_owned());
    }
    for (base, variants) in entries {
        if base.chars().count() != 1 || !base.chars().all(char::is_lowercase) {
            return Err("Invalid TextMate accent fold base".to_owned());
        }
        let variants = variants.as_array().ok_or("Invalid TextMate accent variants")?;
        if variants.is_empty()
            || variants.iter().any(|variant| {
                variant
                    .as_str()
                    .is_none_or(|text| text.chars().count() != 1)
            })
        {
            return Err("Invalid TextMate accent variants".to_owned());
        }
    }
    Ok(())
}
