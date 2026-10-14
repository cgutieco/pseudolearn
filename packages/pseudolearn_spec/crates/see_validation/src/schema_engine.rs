use serde_json::Value;

pub fn check(value: &Value, schema: &Value, root: &Value, depth: usize) -> Result<(), String> {
    if depth > 64 {
        return Err("SEE-SCHEMA: nesting exceeds 64".to_owned());
    }
    let next = depth.checked_add(1).ok_or("SEE-SCHEMA: depth overflow")?;
    if let Some(reference) = schema.get("$ref").and_then(Value::as_str) {
        let target = root
            .pointer(
                reference
                    .strip_prefix('#')
                    .ok_or("SEE-SCHEMA: external reference")?,
            )
            .ok_or("SEE-SCHEMA: unresolved schema reference")?;
        return check(value, target, root, next);
    }
    for kind in ["anyOf", "oneOf"] {
        if let Some(alternatives) = schema.get(kind).and_then(Value::as_array) {
            let matches = alternatives
                .iter()
                .filter(|candidate| check(value, candidate, root, next).is_ok())
                .count();
            if matches == 0 || (kind == "oneOf" && matches != 1) {
                return Err("SEE-SCHEMA: no matching schema alternative".to_owned());
            }
        }
    }
    scalar(value, schema)?;
    if let Some(properties) = value.as_object() {
        object(properties, schema, root, next)?;
    }
    if let Some(elements) = value.as_array() {
        array(elements, schema, root, next)?;
    }
    Ok(())
}

fn scalar(value: &Value, schema: &Value) -> Result<(), String> {
    if let Some(expected) = schema.get("const")
        && value != expected
    {
        return Err("SEE-SCHEMA: constant mismatch".to_owned());
    }
    if let Some(choices) = schema.get("enum").and_then(Value::as_array)
        && !choices.contains(value)
    {
        return Err("SEE-SCHEMA: enum mismatch".to_owned());
    }
    let valid = match schema.get("type").and_then(Value::as_str) {
        Some("string") => value.is_string(),
        Some("object") => value.is_object(),
        Some("array") => value.is_array(),
        Some("integer") => value.is_i64() || value.is_u64(),
        Some("null") => value.is_null(),
        Some("boolean") => value.is_boolean(),
        None => true,
        _ => false,
    };
    if !valid {
        return Err("SEE-SCHEMA: type mismatch".to_owned());
    }
    if let Some(minimum) = schema.get("minLength").and_then(Value::as_u64)
        && value
            .as_str()
            .is_some_and(|text| u64::try_from(text.chars().count()).unwrap_or(0) < minimum)
    {
        return Err("SEE-SCHEMA: short string".to_owned());
    }
    if let Some(minimum) = schema.get("minimum").and_then(Value::as_i64)
        && value.as_i64().is_some_and(|number| number < minimum)
    {
        return Err("SEE-SCHEMA: number below minimum".to_owned());
    }
    Ok(())
}

fn object(
    properties: &serde_json::Map<String, Value>,
    schema: &Value,
    root: &Value,
    depth: usize,
) -> Result<(), String> {
    for name in schema
        .get("required")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
    {
        if !properties.contains_key(name) {
            return Err(format!("SEE-SCHEMA: missing field {name}"));
        }
    }
    for (name, value) in properties {
        if let Some(property) = schema
            .get("properties")
            .and_then(|properties| properties.get(name))
        {
            check(value, property, root, depth)?;
        } else if schema.get("additionalProperties") == Some(&Value::Bool(false)) {
            return Err(format!("SEE-SCHEMA: unknown field {name}"));
        } else {
            additional(value, schema, root, depth)?;
        }
    }
    Ok(())
}

fn array(elements: &[Value], schema: &Value, root: &Value, depth: usize) -> Result<(), String> {
    if let Some(minimum) = schema.get("minItems").and_then(Value::as_u64)
        && u64::try_from(elements.len()).unwrap_or(0) < minimum
    {
        return Err("SEE-SCHEMA: insufficient elements".to_owned());
    }
    if schema.get("uniqueItems") == Some(&Value::Bool(true)) {
        let mut seen = Vec::new();
        for element in elements {
            if seen.contains(&element) {
                return Err("SEE-SCHEMA: duplicate array element".to_owned());
            }
            seen.push(element);
        }
    }
    if let Some(element_schema) = schema.get("items") {
        for element in elements {
            check(element, element_schema, root, depth)?;
        }
    }
    Ok(())
}

fn additional(value: &Value, schema: &Value, root: &Value, depth: usize) -> Result<(), String> {
    if let Some(additional) = schema
        .get("additionalProperties")
        .filter(|additional| additional.is_object())
    {
        check(value, additional, root, depth)?;
    }
    Ok(())
}
