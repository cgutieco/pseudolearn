#![forbid(unsafe_code)]

use crate::{bytes_operations, json_build, json_parse, json_query, json_text};
use crate::{text_replace, text_search, text_split};
use pseudolearn_runtime::{HostValue, MemoryError};

#[path = "local_operation_dispatch.rs"]
mod local_operation_dispatch;
pub use local_operation_dispatch::{LocalOperationRequest, local_operation};

fn text_operation(
    identity: &str,
    arguments: &[HostValue],
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "substring" => Some(substring(arguments)?),
        "contains" => Some(contains(arguments)?),
        "positionOf" => Some(position(arguments)?),
        "startsWith" => Some(prefix(arguments)?),
        "endsWith" => Some(suffix(arguments)?),
        "replaceAll" => Some(replace(arguments)?),
        "split" => Some(split(arguments)?),
        "join" => Some(join(arguments)?),
        "trim" => Some(trim(arguments)?),
        _ => None,
    };
    Ok(value)
}

fn bytes_operation(
    receiver: Option<&HostValue>,
    identity: &str,
    arguments: &[HostValue],
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "bytes_from_text" => Some(bytes_from_text(arguments)?),
        "bytes_segment" => Some(bytes_segment(receiver, arguments)?),
        "bytes_join" => Some(bytes_join(receiver, arguments)?),
        _ => None,
    };
    Ok(value)
}

fn json_operation(
    receiver: Option<&HostValue>,
    identity: &str,
    arguments: &[HostValue],
    maximum_json_depth: usize,
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "json_parse" => Some(parse_json(arguments, maximum_json_depth)?),
        "json_text" => Some(serialize_json(arguments)?),
        "json_null" | "json_boolean" | "json_integer" | "json_real" | "json_string"
        | "json_array" | "json_object" => Some(json_build::construct(identity, arguments)?),
        "json_kind" => Some(json_kind(receiver)?),
        "json_as_boolean" => Some(json_optional_boolean(receiver)?),
        "json_as_integer" => Some(json_optional_integer(receiver)?),
        "json_as_real" => Some(json_optional_real(receiver)?),
        "json_as_text" => Some(json_optional_text(receiver)?),
        "json_length" => Some(json_length(receiver)?),
        "json_element" => Some(json_element(receiver, arguments)?),
        "json_field" => Some(json_field(receiver, arguments)?),
        "json_keys" => Some(json_keys(receiver)?),
        "json_with_element" => Some(json_with_element(receiver, arguments)?),
        "json_with_field" => Some(json_with_field(receiver, arguments)?),
        _ => None,
    };
    Ok(value)
}

fn parse_json(
    arguments: &[HostValue],
    maximum_json_depth: usize,
) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_parse::parse_json(text, maximum_json_depth).map(HostValue::JsonResult)
}

fn serialize_json(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::JsonValue(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_text::normalize_text(text).map(HostValue::Text)
}

fn json_kind(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::kind(json_value(receiver)?)
}

fn json_optional_boolean(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::as_boolean(json_value(receiver)?)
}

fn json_optional_integer(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::as_integer(json_value(receiver)?)
}

fn json_optional_real(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::as_real(json_value(receiver)?)
}

fn json_optional_text(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::as_text(json_value(receiver)?)
}

fn json_length(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::length(json_value(receiver)?)
}

fn json_element(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let [HostValue::Integer(index)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_query::element(json_value(receiver)?, *index)
}

fn json_field(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(name)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_query::field(json_value(receiver)?, name)
}

fn json_keys(receiver: Option<&HostValue>) -> Result<HostValue, MemoryError> {
    json_query::keys(json_value(receiver)?)
}

fn json_with_element(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let [HostValue::JsonValue(element)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_build::with_element(json_value(receiver)?, element)
}

fn json_with_field(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(name), HostValue::JsonValue(value)] = arguments else {
        return Err(MemoryError::Internal);
    };
    json_build::with_field(json_value(receiver)?, name, value)
}

fn json_value(receiver: Option<&HostValue>) -> Result<&str, MemoryError> {
    match receiver {
        Some(HostValue::JsonValue(text)) => Ok(text),
        _ => Err(MemoryError::Internal),
    }
}

fn substring(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, start, count) = text_integer_pair(arguments)?;
    text_search::text_substring(text, start, count).map(HostValue::Text)
}

fn contains(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, part) = text_pair(arguments)?;
    Ok(HostValue::Boolean(text_search::text_contains(text, part)))
}

fn position(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, part) = text_pair(arguments)?;
    Ok(HostValue::OptionalInteger(text_search::text_position(
        text, part,
    )))
}

fn prefix(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, part) = text_pair(arguments)?;
    Ok(HostValue::Boolean(text_search::text_starts_with(
        text, part,
    )))
}

fn suffix(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, part) = text_pair(arguments)?;
    Ok(HostValue::Boolean(text_search::text_ends_with(text, part)))
}

fn replace(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [
        HostValue::Text(text),
        HostValue::Text(searched),
        HostValue::Text(replacement),
    ] = arguments
    else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::Text(text_replace::replace_all(
        text,
        searched,
        replacement,
    )))
}

fn split(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let (text, separator) = text_pair(arguments)?;
    text_split::split_text(text, separator).map(HostValue::TextList)
}

fn join(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::TextList(parts), HostValue::Text(separator)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::Text(text_split::join_text(parts, separator)))
}

fn trim(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::Text(text_replace::trim_text(text)))
}

fn bytes_from_text(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::Bytes(bytes_operations::bytes_from_text(text)))
}

fn bytes_segment(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let Some(HostValue::Bytes(bytes)) = receiver else {
        return Err(MemoryError::Internal);
    };
    let [HostValue::Integer(start), HostValue::Integer(count)] = arguments else {
        return Err(MemoryError::Internal);
    };
    bytes_operations::bytes_segment(bytes, *start, *count).map(HostValue::Bytes)
}

fn bytes_join(
    receiver: Option<&HostValue>,
    arguments: &[HostValue],
) -> Result<HostValue, MemoryError> {
    let (Some(HostValue::Bytes(left)), [HostValue::Bytes(right)]) = (receiver, arguments) else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::Bytes(bytes_operations::bytes_join(left, right)))
}

fn text_pair(arguments: &[HostValue]) -> Result<(&str, &str), MemoryError> {
    match arguments {
        [HostValue::Text(text), HostValue::Text(part)] => Ok((text, part)),
        _ => Err(MemoryError::Internal),
    }
}

fn text_integer_pair(arguments: &[HostValue]) -> Result<(&str, i64, i64), MemoryError> {
    match arguments {
        [
            HostValue::Text(text),
            HostValue::Integer(start),
            HostValue::Integer(count),
        ] => Ok((text, *start, *count)),
        _ => Err(MemoryError::Internal),
    }
}
