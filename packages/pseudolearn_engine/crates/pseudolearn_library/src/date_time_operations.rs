#![forbid(unsafe_code)]

use crate::civil_calendar::CivilDate;
use crate::date_time_construction::{DateTimeParts, components, construct, from_instant};
use crate::{date_time_format, date_time_parse};
use pseudolearn_runtime::{DateTimeValue, HostValue, MemoryError};

pub(crate) fn time_operation(
    receiver: Option<&HostValue>,
    identity: &str,
    arguments: &[HostValue],
) -> Result<Option<HostValue>, MemoryError> {
    let value = match identity {
        "date_time_utc" => utc(arguments)?,
        "date_time_of" => of_parts(arguments)?,
        "date_time_parse" => parse(arguments)?,
        "date_time_iso_format" => iso(receiver, false)?,
        "date_time_iso_format_precise" => iso(receiver, true)?,
        other => match accessor(receiver, other)? {
            Some(value) => value,
            None => return Ok(None),
        },
    };
    Ok(Some(value))
}

fn utc(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::Integer(nanos)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::DateTime(from_instant(*nanos)))
}

fn of_parts(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let mut numbers = [0_i64; 8];
    if arguments.len() != numbers.len() {
        return Err(MemoryError::Internal);
    }
    for (slot, argument) in numbers.iter_mut().zip(arguments) {
        let HostValue::Integer(number) = argument else {
            return Err(MemoryError::Internal);
        };
        *slot = *number;
    }
    let [
        year,
        month,
        day,
        hour,
        minute,
        second,
        nanosecond,
        offset_seconds,
    ] = numbers;
    Ok(HostValue::OptionalDateTime(construct(DateTimeParts {
        date: CivilDate { year, month, day },
        hour,
        minute,
        second,
        nanosecond,
        offset_seconds,
    })))
}

fn parse(arguments: &[HostValue]) -> Result<HostValue, MemoryError> {
    let [HostValue::Text(text)] = arguments else {
        return Err(MemoryError::Internal);
    };
    Ok(HostValue::OptionalDateTime(date_time_parse::parse_iso(
        text,
    )))
}

fn iso(receiver: Option<&HostValue>, precise: bool) -> Result<HostValue, MemoryError> {
    let value = date_time(receiver)?;
    Ok(HostValue::Text(date_time_format::iso_format(
        value, precise,
    )))
}

fn accessor(
    receiver: Option<&HostValue>,
    identity: &str,
) -> Result<Option<HostValue>, MemoryError> {
    let Some(name) = identity.strip_prefix("date_time_") else {
        return Ok(None);
    };
    let value = date_time(receiver)?;
    let parts = components(value);
    let number = match name {
        "year" => parts.date.year,
        "month" => parts.date.month,
        "day" => parts.date.day,
        "hour" => parts.hour,
        "minute" => parts.minute,
        "second" => parts.second,
        "nanosecond" => parts.nanosecond,
        "weekday" => parts.weekday,
        "utc_offset" => i64::from(value.offset_seconds),
        "instant" => value.nanos,
        _ => return Ok(None),
    };
    Ok(Some(HostValue::Integer(number)))
}

fn date_time(receiver: Option<&HostValue>) -> Result<&DateTimeValue, MemoryError> {
    match receiver {
        Some(HostValue::DateTime(value)) => Ok(value),
        _ => Err(MemoryError::Internal),
    }
}
