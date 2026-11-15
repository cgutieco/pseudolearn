use crate::civil_calendar::{
    CivilDate, civil_from_days, days_from_civil, days_in_month, is_leap_year, is_valid_date,
    iso_weekday,
};

fn date(year: i64, month: i64, day: i64) -> CivilDate {
    CivilDate { year, month, day }
}

#[test]
fn leap_years_follow_the_gregorian_rule() {
    assert!(is_leap_year(2000));
    assert!(is_leap_year(2024));
    assert!(!is_leap_year(1900));
    assert!(!is_leap_year(2100));
    assert!(!is_leap_year(2023));
    assert!(is_leap_year(-4));
    assert!(!is_leap_year(-100));
}

#[test]
fn month_lengths_cover_every_month_and_reject_others() {
    let lengths: Vec<_> = (1..=12)
        .filter_map(|month| days_in_month(2023, month))
        .collect();
    assert_eq!(lengths, [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]);
    assert_eq!(days_in_month(2024, 2), Some(29));
    assert_eq!(days_in_month(2024, 0), None);
    assert_eq!(days_in_month(2024, 13), None);
}

#[test]
fn dates_outside_their_month_are_invalid() {
    assert!(is_valid_date(date(2024, 2, 29)));
    assert!(!is_valid_date(date(2023, 2, 29)));
    assert!(!is_valid_date(date(2026, 4, 31)));
    assert!(!is_valid_date(date(2026, 1, 0)));
    assert!(!is_valid_date(date(2026, 13, 1)));
}

#[test]
fn epoch_and_known_days_match_the_definition_of_the_calendar() {
    assert_eq!(days_from_civil(date(1970, 1, 1)), 0);
    assert_eq!(days_from_civil(date(1970, 1, 2)), 1);
    assert_eq!(days_from_civil(date(1969, 12, 31)), -1);
    assert_eq!(days_from_civil(date(2000, 1, 1)), 10_957);
    assert_eq!(days_from_civil(date(2000, 3, 1)), 11_017);
    assert_eq!(civil_from_days(0), date(1970, 1, 1));
    assert_eq!(civil_from_days(-1), date(1969, 12, 31));
}

#[test]
fn every_day_of_four_centuries_round_trips() {
    let start = days_from_civil(date(1700, 1, 1));
    let end = days_from_civil(date(2300, 1, 1));
    for days in start..end {
        let civil = civil_from_days(days);
        assert!(is_valid_date(civil), "{civil:?}");
        assert_eq!(days_from_civil(civil), days);
    }
}

#[test]
fn consecutive_days_advance_the_calendar_by_one_day() {
    assert_eq!(
        civil_from_days(days_from_civil(date(2024, 2, 28)) + 1),
        date(2024, 2, 29)
    );
    assert_eq!(
        civil_from_days(days_from_civil(date(2024, 2, 29)) + 1),
        date(2024, 3, 1)
    );
    assert_eq!(
        civil_from_days(days_from_civil(date(2025, 12, 31)) + 1),
        date(2026, 1, 1)
    );
    assert_eq!(
        civil_from_days(days_from_civil(date(1900, 2, 28)) + 1),
        date(1900, 3, 1)
    );
}

#[test]
fn weekdays_use_the_iso_numbering() {
    assert_eq!(iso_weekday(0), 4);
    assert_eq!(iso_weekday(-1), 3);
    assert_eq!(iso_weekday(days_from_civil(date(2000, 1, 1))), 6);
    assert_eq!(iso_weekday(days_from_civil(date(2026, 11, 2))), 1);
    assert_eq!(iso_weekday(days_from_civil(date(2026, 11, 8))), 7);
}
