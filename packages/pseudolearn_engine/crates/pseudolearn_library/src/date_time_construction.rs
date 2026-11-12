#![forbid(unsafe_code)]

use crate::civil_calendar::{
    CivilDate, civil_from_days, days_from_civil, is_valid_date, iso_weekday,
};
use pseudolearn_runtime::DateTimeValue;

const NANOS_PER_SECOND: i128 = 1_000_000_000;
const SECONDS_PER_DAY: i128 = 86_400;
pub(crate) const MINIMUM_OFFSET_SECONDS: i64 = -43_200;
pub(crate) const MAXIMUM_OFFSET_SECONDS: i64 = 50_400;
const SECONDS_PER_MINUTE: i64 = 60;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct DateTimeParts {
    pub(crate) date: CivilDate,
    pub(crate) hour: i64,
    pub(crate) minute: i64,
    pub(crate) second: i64,
    pub(crate) nanosecond: i64,
    pub(crate) offset_seconds: i64,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct Components {
    pub(crate) date: CivilDate,
    pub(crate) hour: i64,
    pub(crate) minute: i64,
    pub(crate) second: i64,
    pub(crate) nanosecond: i64,
    pub(crate) weekday: i64,
}

pub(crate) fn from_instant(nanos: i64) -> DateTimeValue {
    DateTimeValue {
        nanos,
        offset_seconds: 0,
    }
}

pub(crate) fn construct(parts: DateTimeParts) -> Option<DateTimeValue> {
    if !fields_are_valid(&parts) {
        return None;
    }
    let days = i128::from(days_from_civil(parts.date));
    let seconds = days
        .saturating_mul(SECONDS_PER_DAY)
        .saturating_add(i128::from(parts.hour).saturating_mul(3600))
        .saturating_add(i128::from(parts.minute).saturating_mul(60))
        .saturating_add(i128::from(parts.second))
        .saturating_sub(i128::from(parts.offset_seconds));
    let nanos = seconds
        .saturating_mul(NANOS_PER_SECOND)
        .saturating_add(i128::from(parts.nanosecond));
    Some(DateTimeValue {
        nanos: i64::try_from(nanos).ok()?,
        offset_seconds: i32::try_from(parts.offset_seconds).ok()?,
    })
}

fn fields_are_valid(parts: &DateTimeParts) -> bool {
    is_valid_date(parts.date)
        && (0..24).contains(&parts.hour)
        && (0..60).contains(&parts.minute)
        && (0..60).contains(&parts.second)
        && (0..1_000_000_000).contains(&parts.nanosecond)
        && offset_is_valid(parts.offset_seconds)
}

pub(crate) fn offset_is_valid(offset_seconds: i64) -> bool {
    (MINIMUM_OFFSET_SECONDS..=MAXIMUM_OFFSET_SECONDS).contains(&offset_seconds)
        && offset_seconds.rem_euclid(SECONDS_PER_MINUTE) == 0
}

pub(crate) fn components(value: &DateTimeValue) -> Components {
    let local = i128::from(value.nanos)
        .saturating_add(i128::from(value.offset_seconds).saturating_mul(NANOS_PER_SECOND));
    let total_seconds = local.div_euclid(NANOS_PER_SECOND);
    let nanosecond = local.rem_euclid(NANOS_PER_SECOND);
    let days = i64::try_from(total_seconds.div_euclid(SECONDS_PER_DAY)).unwrap_or(0);
    let seconds_of_day = total_seconds.rem_euclid(SECONDS_PER_DAY);
    Components {
        date: civil_from_days(days),
        hour: i64::try_from(seconds_of_day.div_euclid(3600)).unwrap_or(0),
        minute: i64::try_from(seconds_of_day.rem_euclid(3600).div_euclid(60)).unwrap_or(0),
        second: i64::try_from(seconds_of_day.rem_euclid(60)).unwrap_or(0),
        nanosecond: i64::try_from(nanosecond).unwrap_or(0),
        weekday: iso_weekday(days),
    }
}
