use serde_json::Value;

pub(crate) fn conform(arguments: &Value, properties: &Value, required: &Value) -> bool {
    let Some(object) = arguments.as_object() else {
        return false;
    };
    let required_present = required.as_array().is_some_and(|names| {
        names
            .iter()
            .filter_map(Value::as_str)
            .all(|name| object.contains_key(name))
    });
    required_present
        && object.iter().all(|(name, value)| {
            properties
                .get(name)
                .is_none_or(|schema| matches_schema(value, schema))
        })
}

fn matches_schema(value: &Value, schema: &Value) -> bool {
    match schema.get("type").and_then(Value::as_str) {
        Some("string") => value.as_str().is_some_and(|text| is_allowed(text, schema)),
        Some("integer") => value.is_i64() || value.is_u64(),
        Some("array") => value
            .as_array()
            .is_some_and(|items| items.iter().all(Value::is_string)),
        _ => true,
    }
}

fn is_allowed(text: &str, schema: &Value) -> bool {
    schema
        .get("enum")
        .and_then(Value::as_array)
        .is_none_or(|choices| choices.iter().any(|choice| choice.as_str() == Some(text)))
}
