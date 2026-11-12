use serde_json::Value;

pub fn check(value: &Value) -> Result<(), String> {
    let fields = value
        .as_object()
        .ok_or("SEE-ANALYSIS-LIMITS: expected object")?;
    if fields.len() != 1 || !fields.contains_key("nesting") {
        return Err("SEE-ANALYSIS-LIMITS: expected nesting field only".to_owned());
    }
    let nesting = fields
        .get("nesting")
        .and_then(Value::as_u64)
        .and_then(|limit| u32::try_from(limit).ok());
    if nesting.is_none_or(|limit| limit == 0) {
        return Err("SEE-ANALYSIS-LIMITS: expected positive u32 nesting limit".to_owned());
    }
    Ok(())
}
