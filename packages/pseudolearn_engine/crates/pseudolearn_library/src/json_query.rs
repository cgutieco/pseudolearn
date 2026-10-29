#![forbid(unsafe_code)]

use crate::json_text::{compact_text, parse_document};
use pseudolearn_runtime::{HostValue, JsonNodeKind, MemoryError};

pub fn kind(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let ordinal = match value {
        serde_json::Value::Null => JsonNodeKind::Null,
        serde_json::Value::Bool(_) => JsonNodeKind::Boolean,
        serde_json::Value::Number(_) => JsonNodeKind::Number,
        serde_json::Value::String(_) => JsonNodeKind::String,
        serde_json::Value::Array(_) => JsonNodeKind::Array,
        serde_json::Value::Object(_) => JsonNodeKind::Object,
    };
    Ok(HostValue::JsonKind(ordinal.tag()))
}

pub fn as_boolean(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    Ok(HostValue::OptionalBoolean(value.as_bool()))
}

pub fn as_integer(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    Ok(HostValue::OptionalInteger(
        value.as_number().and_then(serde_json::Number::as_i64),
    ))
}

pub fn as_real(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let number = value
        .as_number()
        .and_then(serde_json::Number::as_f64)
        .filter(|number| number.is_finite())
        .map(f64::to_bits);
    Ok(HostValue::OptionalReal(number))
}

pub fn as_text(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    Ok(HostValue::OptionalText(value.as_str().map(str::to_owned)))
}

pub fn length(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let count = match &value {
        serde_json::Value::Array(values) => values.len(),
        serde_json::Value::Object(values) => values.len(),
        _ => 0,
    };
    i64::try_from(count)
        .map(HostValue::Integer)
        .map_err(|_| MemoryError::Resource)
}

pub fn element(text: &str, index: i64) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let index = usize::try_from(index).ok();
    let found = value
        .as_array()
        .and_then(|values| index.and_then(|index| values.get(index)))
        .map(compact_text)
        .transpose()?;
    Ok(HostValue::OptionalJsonValue(found))
}

pub fn field(text: &str, name: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let found = value
        .as_object()
        .and_then(|values| values.get(name))
        .map(compact_text)
        .transpose()?;
    Ok(HostValue::OptionalJsonValue(found))
}

pub fn keys(text: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(text)?;
    let names = value
        .as_object()
        .map(|values| values.keys().cloned().collect())
        .unwrap_or_default();
    Ok(HostValue::TextList(names))
}
