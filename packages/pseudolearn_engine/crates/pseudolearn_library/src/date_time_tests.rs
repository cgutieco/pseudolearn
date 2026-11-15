use crate::civil_calendar::CivilDate;
use crate::date_time_construction::{DateTimeParts, components, construct, from_instant};
use crate::date_time_format::iso_format;
use crate::date_time_parse::parse_iso;
use pseudolearn_runtime::DateTimeValue;

fn parts(year: i64, month: i64, day: i64) -> DateTimeParts {
    DateTimeParts {
        date: CivilDate { year, month, day },
        hour: 0,
        minute: 0,
        second: 0,
        nanosecond: 0,
        offset_seconds: 0,
    }
}

fn precise(value: Option<DateTimeValue>) -> String {
    value.map_or_else(|| "none".to_owned(), |found| iso_format(&found, true))
}

#[test]
fn epoch_and_neighbouring_instants_format_as_the_definition_says() {
    assert_eq!(iso_format(&from_instant(0), false), "1970-01-01T00:00:00Z");
    assert_eq!(
        iso_format(&from_instant(1), true),
        "1970-01-01T00:00:00.000000001Z"
    );
    assert_eq!(
        iso_format(&from_instant(-1), true),
        "1969-12-31T23:59:59.999999999Z"
    );
}

#[test]
fn the_extreme_instants_are_the_documented_range() {
    assert_eq!(
        iso_format(&from_instant(i64::MAX), true),
        "2262-04-11T23:47:16.854775807Z"
    );
    assert_eq!(
        iso_format(&from_instant(i64::MIN), true),
        "1677-09-21T00:12:43.145224192Z"
    );
}

#[test]
fn construction_rejects_each_invalid_component() {
    let valid = parts(2024, 2, 29);
    assert!(construct(valid).is_some());
    for broken in [
        DateTimeParts {
            date: CivilDate {
                year: 2023,
                month: 2,
                day: 29,
            },
            ..valid
        },
        DateTimeParts { hour: 24, ..valid },
        DateTimeParts {
            minute: 60,
            ..valid
        },
        DateTimeParts {
            second: 60,
            ..valid
        },
        DateTimeParts {
            nanosecond: 1_000_000_000,
            ..valid
        },
        DateTimeParts {
            nanosecond: -1,
            ..valid
        },
        DateTimeParts {
            offset_seconds: 50_460,
            ..valid
        },
        DateTimeParts {
            offset_seconds: -43_260,
            ..valid
        },
        DateTimeParts {
            offset_seconds: 30,
            ..valid
        },
        DateTimeParts {
            date: CivilDate {
                year: 1600,
                month: 1,
                day: 1,
            },
            ..valid
        },
        DateTimeParts {
            date: CivilDate {
                year: 2300,
                month: 1,
                day: 1,
            },
            ..valid
        },
    ] {
        assert_eq!(construct(broken), None, "{broken:?}");
    }
}

#[test]
fn construction_applies_the_offset_to_reach_the_instant() {
    let zoned = DateTimeParts {
        hour: 5,
        minute: 30,
        offset_seconds: 19_800,
        ..parts(1970, 1, 1)
    };
    assert_eq!(
        construct(zoned),
        Some(DateTimeValue {
            nanos: 0,
            offset_seconds: 19_800
        })
    );
}

#[test]
fn components_use_the_local_time_of_the_offset() {
    let value = DateTimeValue {
        nanos: 0,
        offset_seconds: -43_200,
    };
    let local = components(&value);
    assert_eq!(
        (
            local.date.year,
            local.date.month,
            local.date.day,
            local.hour
        ),
        (1969, 12, 31, 12)
    );
}

#[test]
fn parse_accepts_the_documented_forms() {
    assert_eq!(
        precise(parse_iso("2026-06-15")),
        "2026-06-15T00:00:00.000000000Z"
    );
    assert_eq!(
        precise(parse_iso("2026-06-15T12:30:45.5+05:30")),
        "2026-06-15T12:30:45.500000000+05:30"
    );
    assert_eq!(
        precise(parse_iso("2026-06-15T12:30:45-12:00")),
        "2026-06-15T12:30:45.000000000-12:00"
    );
    assert_eq!(
        precise(parse_iso("2026-06-15T12:30:45.123456789+14:00")),
        "2026-06-15T12:30:45.123456789+14:00"
    );
}

#[test]
fn parse_rejects_every_malformed_or_out_of_range_form() {
    for text in [
        "",
        " 2026-01-01",
        "2026-01-01 ",
        "2026-13-01",
        "2026-02-30",
        "2026-01-01T25:00:00",
        "2026-01-01t00:00:00",
        "2026-01-01T00:00:00z",
        "2026-01-01T00:00:60Z",
        "2026-01-01T00:00:00+14:30",
        "2026-01-01T00:00:00-12:30",
        "2026-01-01T00:00:00.Z",
        "2026-01-01T00:00:00.1234567890Z",
        "1600-01-01",
        "2300-01-01",
        "2026-01-01T00:00Z",
        "2026-1-1",
        "20260101",
        "2026-01-01T00:00:00+05:60",
        "2026-01-01T00:00:00+0530",
        "２０２６-01-01",
        "2026-01-01T00:00:00Zx",
        "2026-01-01T",
    ] {
        assert_eq!(parse_iso(text), None, "{text:?}");
    }
}

#[test]
fn format_then_parse_returns_the_same_value() {
    for nanos in [i64::MIN, -1, 0, 1, 1_234_567_890_123_456_789, i64::MAX] {
        let value = from_instant(nanos);
        assert_eq!(parse_iso(&iso_format(&value, true)), Some(value));
    }
    let zoned = DateTimeValue {
        nanos: 1_700_000_000_000_000_000,
        offset_seconds: -34_200,
    };
    assert_eq!(parse_iso(&iso_format(&zoned, true)), Some(zoned));
}
