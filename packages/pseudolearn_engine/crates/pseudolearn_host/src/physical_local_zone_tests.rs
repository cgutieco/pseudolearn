use crate::physical_local_zone::{local_now, offset_seconds_at};
use jiff::tz::{Offset, TimeZone};

const JANUARY_2026_NANOS: i64 = 1_767_225_600_000_000_000;
const JULY_2026_NANOS: i64 = 1_782_864_000_000_000_000;

#[test]
fn a_fixed_zone_reports_its_offset_in_seconds() -> Result<(), String> {
    let zone = TimeZone::fixed(Offset::from_seconds(19_800).map_err(|error| error.to_string())?);
    assert_eq!(offset_seconds_at(&zone, 0), Ok(19_800));
    assert_eq!(offset_seconds_at(&TimeZone::UTC, 0), Ok(0));
    Ok(())
}

#[test]
fn a_named_zone_with_daylight_saving_changes_offset_with_the_instant() -> Result<(), String> {
    let zone = TimeZone::get("America/New_York").map_err(|error| error.to_string())?;
    assert_eq!(offset_seconds_at(&zone, JANUARY_2026_NANOS), Ok(-18_000));
    assert_eq!(offset_seconds_at(&zone, JULY_2026_NANOS), Ok(-14_400));
    Ok(())
}

#[test]
fn offsets_with_seconds_truncate_toward_zero_to_whole_minutes() -> Result<(), String> {
    let positive = TimeZone::fixed(Offset::from_seconds(3_661).map_err(|error| error.to_string())?);
    let negative =
        TimeZone::fixed(Offset::from_seconds(-3_661).map_err(|error| error.to_string())?);
    assert_eq!(offset_seconds_at(&positive, 0), Ok(3_660));
    assert_eq!(offset_seconds_at(&negative, 0), Ok(-3_660));
    Ok(())
}

#[test]
fn the_system_reply_is_a_date_time_with_a_whole_minute_offset() -> Result<(), String> {
    let reply = local_now(JANUARY_2026_NANOS).map_err(|error| error.code.to_owned())?;
    let value = reply.pointer("/value/value").ok_or("missing value")?;
    let offset = value
        .get("offset_seconds")
        .and_then(|found| found.as_i64())
        .ok_or("missing offset")?;
    assert_eq!(
        reply
            .pointer("/value/kind")
            .and_then(|found| found.as_str()),
        Some("date_time")
    );
    assert_eq!(offset.rem_euclid(60), 0);
    assert!((-43_200..=50_400).contains(&offset));
    Ok(())
}
