use crate::properties::PropertySubject;
use serde_json::{Value, json};

pub(crate) fn call(
    subject: &mut impl PropertySubject,
    operation: &str,
    arguments: Value,
) -> Result<Value, String> {
    let response =
        subject.exchange(&json!({"kind":"api", "operation":operation, "arguments":arguments}))?;
    response
        .get("result")
        .cloned()
        .ok_or("SEE-PROPERTY: missing API result".to_owned())
}

pub(crate) fn value(result: Value) -> Result<Value, String> {
    result
        .get("value")
        .cloned()
        .ok_or_else(|| format!("SEE-PROPERTY: unexpected API failure: {result}"))
}

pub(crate) fn create(subject: &mut impl PropertySubject, request: &Value) -> Result<Value, String> {
    let response = value(call(subject, "create_analysis", request.clone())?)?;
    response
        .get("resource")
        .cloned()
        .ok_or("SEE-PROPERTY: missing resource".to_owned())
}

pub(crate) fn release(subject: &mut impl PropertySubject, resource: &Value) -> Result<(), String> {
    value(call(subject, "release", json!({"resource":resource}))?)?;
    Ok(())
}

pub(crate) fn different(expected: Value, actual: Value) -> Option<(Value, Value)> {
    (expected != actual).then_some((expected, actual))
}

pub(crate) fn array<'response>(
    response: &'response Value,
    name: &str,
) -> Result<&'response Vec<Value>, String> {
    response
        .get(name)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("SEE-PROPERTY: missing {name}"))
}

pub(crate) fn failure(result: &Value, family: &str) -> bool {
    result.pointer("/failure/family").and_then(Value::as_str) == Some(family)
}
