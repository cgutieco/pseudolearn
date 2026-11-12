#![forbid(unsafe_code)]

use crate::{decimal_format, text_padding};
use pseudolearn_runtime::{HostValue, MemoryError};

pub(crate) fn text_format_operation(
    identity: &str,
    arguments: &[HostValue],
    maximum_points: u64,
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "text_decimals" => Some(decimals(arguments)?),
        "text_pad_left" => Some(pad_left(arguments, maximum_points)?),
        "text_pad_right" => Some(pad_right(arguments, maximum_points)?),
        _ => None,
    };
    Ok(value)
}

fn decimals(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::Real(bits), HostValue::Integer(places)] = arguments else {
        return Err(MemoryError::Internal);
    };
    decimal_format::format_fixed_decimals(f64::from_bits(*bits), *places).map(HostValue::Text)
}

fn pad_left(arguments: &[HostValue], maximum_points: u64) -> Result<HostValue, MemoryError> {
    let [
        HostValue::Text(text),
        HostValue::Integer(width),
        HostValue::Text(fill),
    ] = arguments
    else {
        return Err(MemoryError::Internal);
    };
    text_padding::pad_left(text, *width, fill, maximum_points).map(HostValue::Text)
}

fn pad_right(arguments: &[HostValue], maximum_points: u64) -> Result<HostValue, MemoryError> {
    let [
        HostValue::Text(text),
        HostValue::Integer(width),
        HostValue::Text(fill),
    ] = arguments
    else {
        return Err(MemoryError::Internal);
    };
    text_padding::pad_right(text, *width, fill, maximum_points).map(HostValue::Text)
}
