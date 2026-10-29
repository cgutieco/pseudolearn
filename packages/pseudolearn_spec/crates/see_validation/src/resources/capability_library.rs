use serde_json::Value;
use std::collections::BTreeSet;

const FAMILIES: &[&str] = &[
    "text",
    "bytes",
    "numbers",
    "collections",
    "io",
    "time",
    "json",
    "network",
    "tasks",
];
const KINDS: &[&str] = &[
    "integer",
    "real",
    "boolean",
    "text",
    "bytes",
    "text_list",
    "console",
    "arguments",
    "directory",
    "file",
    "clock",
    "timer",
    "json_value",
    "json_result",
    "json_kind",
    "optional_boolean",
    "optional_integer",
    "optional_real",
    "optional_text",
    "optional_json_value",
];

pub(super) fn check(value: &Value) -> Result<(), String> {
    if value.as_object().is_none_or(|fields| fields.len() != 1) {
        return Err("Invalid capability library".to_owned());
    }
    let operations = value
        .get("operations")
        .and_then(Value::as_array)
        .filter(|operations| !operations.is_empty())
        .ok_or("Missing capability operations")?;
    let mut identities = BTreeSet::new();
    let mut names = BTreeSet::new();
    for operation in operations {
        check_operation(operation)?;
        let identity = text(operation, "identity")?;
        if !identities.insert(identity) {
            return Err("Duplicate capability operation".to_owned());
        }
        for profile in ["es", "en"] {
            if !names.insert((
                profile,
                operation.get("receiver").and_then(Value::as_str),
                text(operation, profile)?.to_lowercase(),
            )) {
                return Err("Duplicate capability method".to_owned());
            }
        }
    }
    Ok(())
}

fn check_operation(operation: &Value) -> Result<(), String> {
    check_operation_fields(operation)?;
    check_operation_signature(operation)
}

fn check_operation_fields(operation: &Value) -> Result<(), String> {
    let fields = operation
        .as_object()
        .ok_or("Invalid capability operation")?;
    if fields.len() != 9
        || fields.keys().any(|key| {
            ![
                "identity",
                "family",
                "receiver",
                "es",
                "en",
                "parameters",
                "result",
                "effect",
                "fallible",
            ]
            .contains(&key.as_str())
        })
    {
        return Err("Invalid capability operation fields".to_owned());
    }
    Ok(())
}

fn check_operation_signature(operation: &Value) -> Result<(), String> {
    for name in ["identity", "es", "en", "result"] {
        text(operation, name)?;
    }
    if !FAMILIES.contains(&text(operation, "family")?) {
        return Err("Unknown capability family".to_owned());
    }
    let receiver = operation.get("receiver").ok_or("Missing receiver")?;
    let parameters = operation
        .get("parameters")
        .and_then(Value::as_array)
        .ok_or("Missing parameter types")?;
    if !KINDS.contains(&text(operation, "result")?)
        || parameters
            .iter()
            .any(|kind| kind.as_str().is_none_or(|kind| !KINDS.contains(&kind)))
        || !receiver.is_null() && receiver.as_str().is_none_or(|kind| !KINDS.contains(&kind))
        || operation.get("effect").and_then(Value::as_bool).is_none()
        || operation.get("fallible").and_then(Value::as_bool).is_none()
    {
        return Err("Invalid capability operation signature".to_owned());
    }
    Ok(())
}

fn text<'value>(value: &'value Value, field: &str) -> Result<&'value str, String> {
    value
        .get(field)
        .and_then(Value::as_str)
        .filter(|text| !text.is_empty())
        .ok_or_else(|| format!("Missing capability {field}"))
}
