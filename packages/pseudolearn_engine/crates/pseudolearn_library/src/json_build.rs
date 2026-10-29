#![forbid(unsafe_code)]

use crate::json_text::{compact_text, parse_document};
use pseudolearn_runtime::{HostValue, MemoryError};
use serde_json::{Map, Number, Value};

pub fn construct(identity: &str, arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let value = match identity {
        "json_null" => Value::Null,
        "json_boolean" => Value::Bool(boolean(arguments)?),
        "json_integer" => Value::Number(Number::from(integer(arguments)?)),
        "json_real" => real(arguments)?,
        "json_string" => Value::String(text(arguments)?.to_owned()),
        "json_array" => Value::Array(Vec::new()),
        "json_object" => Value::Object(Map::new()),
        _ => return Err(MemoryError::Internal),
    };
    Ok(HostValue::JsonValue(compact_text(&value)?))
}

pub fn with_element(source: &str, element: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(source)?;
    if !value.is_array() {
        return Err(MemoryError::JsonKindMismatch);
    }
    let source = crate::json_text::normalize_text(source)?;
    let element = crate::json_text::normalize_text(element)?;
    crate::json_source::append_array(&source, &element).map(HostValue::JsonValue)
}

pub fn with_field(source: &str, name: &str, field: &str) -> Result<HostValue, MemoryError> {
    let value = parse_document(source)?;
    if !value.is_object() {
        return Err(MemoryError::JsonKindMismatch);
    }
    let source = crate::json_text::normalize_text(source)?;
    let field = crate::json_text::normalize_text(field)?;
    crate::json_source::replace_object_field(&source, name, &field).map(HostValue::JsonValue)
}

fn boolean(arguments: &[HostValue]) -> Result<bool, MemoryError> {
    match arguments {
        [HostValue::Boolean(value)] => Ok(*value),
        _ => Err(MemoryError::Internal),
    }
}

fn integer(arguments: &[HostValue]) -> Result<i64, MemoryError> {
    match arguments {
        [HostValue::Integer(value)] => Ok(*value),
        _ => Err(MemoryError::Internal),
    }
}

fn real(arguments: &[HostValue]) -> Result<Value, MemoryError> {
    let [HostValue::Real(bits)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Number::from_f64(f64::from_bits(*bits))
        .map(Value::Number)
        .ok_or(MemoryError::Internal)
}

fn text(arguments: &[HostValue]) -> Result<&str, MemoryError> {
    match arguments {
        [HostValue::Text(value)] => Ok(value),
        _ => Err(MemoryError::Internal),
    }
}
