use crate::physical_error::{HostError, committed};
use jiff::{Timestamp, tz::TimeZone};
use serde_json::{Value, json};

const SECONDS_PER_MINUTE: i32 = 60;

pub(crate) fn local_now(nanos: i64) -> Result<Value, HostError> {
    let offset_seconds = offset_seconds_at(&TimeZone::system(), nanos)?;
    Ok(committed(
        "date_time",
        json!({"nanos": nanos, "offset_seconds": offset_seconds}),
    ))
}

pub(crate) fn offset_seconds_at(zone: &TimeZone, nanos: i64) -> Result<i32, HostError> {
    let instant =
        Timestamp::from_nanosecond(i128::from(nanos)).map_err(|_| HostError::INTERRUPTED)?;
    let seconds = zone.to_offset(instant).seconds();
    seconds
        .checked_div(SECONDS_PER_MINUTE)
        .and_then(|minutes| minutes.checked_mul(SECONDS_PER_MINUTE))
        .ok_or(HostError::INTERRUPTED)
}
