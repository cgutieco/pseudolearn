use serde_json::Value;

pub fn check(value: &Value) -> Result<(), String> {
    let entries = value
        .as_object()
        .ok_or("SEE-STRUCTURAL: expected catalog")?;
    for entry in entries.values() {
        if entry
            .get("code")
            .and_then(Value::as_str)
            .is_none_or(str::is_empty)
            || entry.get("allow_line").and_then(Value::as_bool).is_none()
        {
            return Err("SEE-STRUCTURAL: missing code or opening policy".to_owned());
        }
        for field in ["openings", "closings"] {
            let words = entry
                .get(field)
                .and_then(Value::as_array)
                .ok_or("SEE-STRUCTURAL: missing forms")?;
            if field == "openings" && words.is_empty()
                || words
                    .iter()
                    .any(|word| word.as_str().is_none_or(str::is_empty))
            {
                return Err("SEE-STRUCTURAL: invalid forms".to_owned());
            }
        }
    }
    Ok(())
}
