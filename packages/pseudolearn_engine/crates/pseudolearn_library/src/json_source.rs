#![forbid(unsafe_code)]

use crate::json_source_scan::{ObjectFieldSpan, scan_object_fields};
use pseudolearn_runtime::MemoryError;

pub fn append_array(source: &str, value: &str) -> Result<String, MemoryError> {
    let bytes = source.as_bytes();
    if bytes.first() != Some(&b'[') || bytes.last() != Some(&b']') {
        return Err(MemoryError::Internal);
    }
    let prefix_end = source.len().checked_sub(1).ok_or(MemoryError::Internal)?;
    let prefix = source.get(..prefix_end).ok_or(MemoryError::Internal)?;
    let empty = prefix_end == 1;
    let separator = if empty { "" } else { "," };
    let mut output = String::new();
    output
        .try_reserve(
            prefix
                .len()
                .saturating_add(separator.len())
                .saturating_add(value.len())
                .saturating_add(1),
        )
        .map_err(|_| MemoryError::Resource)?;
    output.push_str(prefix);
    output.push_str(separator);
    output.push_str(value);
    output.push(']');
    Ok(output)
}

pub fn replace_object_field(source: &str, name: &str, value: &str) -> Result<String, MemoryError> {
    let fields = scan_object_fields(source)?;
    let encoded_name = serde_json::to_string(name).map_err(|_| MemoryError::Internal)?;
    match fields.iter().find(|field| field.name == name) {
        Some(field) => replace_value(source, value, field),
        None => append_field(source, value, &encoded_name, fields.is_empty()),
    }
}

fn replace_value(
    source: &str,
    value: &str,
    field: &ObjectFieldSpan,
) -> Result<String, MemoryError> {
    let prefix = source
        .get(..field.value_start)
        .ok_or(MemoryError::Internal)?;
    let suffix = source.get(field.value_end..).ok_or(MemoryError::Internal)?;
    let mut output = String::new();
    output
        .try_reserve(
            prefix
                .len()
                .saturating_add(value.len())
                .saturating_add(suffix.len()),
        )
        .map_err(|_| MemoryError::Resource)?;
    output.push_str(prefix);
    output.push_str(value);
    output.push_str(suffix);
    Ok(output)
}

fn append_field(
    source: &str,
    value: &str,
    encoded_name: &str,
    empty: bool,
) -> Result<String, MemoryError> {
    let prefix_end = source.len().checked_sub(1).ok_or(MemoryError::Internal)?;
    let prefix = source.get(..prefix_end).ok_or(MemoryError::Internal)?;
    if source.as_bytes().last() != Some(&b'}') {
        return Err(MemoryError::Internal);
    }
    let separator = if empty { "" } else { "," };
    let mut output = String::new();
    output
        .try_reserve(
            prefix
                .len()
                .saturating_add(separator.len())
                .saturating_add(encoded_name.len())
                .saturating_add(value.len())
                .saturating_add(2),
        )
        .map_err(|_| MemoryError::Resource)?;
    output.push_str(prefix);
    output.push_str(separator);
    output.push_str(encoded_name);
    output.push(':');
    output.push_str(value);
    output.push('}');
    Ok(output)
}
