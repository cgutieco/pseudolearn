#![forbid(unsafe_code)]

const DAYS_PER_ERA: i64 = 146_097;
const DAYS_FROM_ZERO_TO_EPOCH: i64 = 719_468;
const MONDAY_BASED_EPOCH_SHIFT: i64 = 3;
const DAYS_PER_WEEK: i64 = 7;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct CivilDate {
    pub(crate) year: i64,
    pub(crate) month: i64,
    pub(crate) day: i64,
}

pub(crate) fn is_leap_year(year: i64) -> bool {
    year.rem_euclid(4) == 0 && (year.rem_euclid(100) != 0 || year.rem_euclid(400) == 0)
}

pub(crate) fn days_in_month(year: i64, month: i64) -> Option<i64> {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => Some(31),
        4 | 6 | 9 | 11 => Some(30),
        2 => Some(if is_leap_year(year) { 29 } else { 28 }),
        _ => None,
    }
}

pub(crate) fn is_valid_date(date: CivilDate) -> bool {
    days_in_month(date.year, date.month).is_some_and(|last| date.day >= 1 && date.day <= last)
}

pub(crate) fn days_from_civil(date: CivilDate) -> i64 {
    let adjusted_year = date.year.saturating_sub(i64::from(date.month <= 2));
    let era = adjusted_year.div_euclid(400);
    let year_of_era = adjusted_year.rem_euclid(400);
    let shifted_month = if date.month > 2 {
        date.month.saturating_sub(3)
    } else {
        date.month.saturating_add(9)
    };
    let day_of_year = shifted_month
        .saturating_mul(153)
        .saturating_add(2)
        .div_euclid(5)
        .saturating_add(date.day)
        .saturating_sub(1);
    let day_of_era = year_of_era
        .saturating_mul(365)
        .saturating_add(year_of_era.div_euclid(4))
        .saturating_sub(year_of_era.div_euclid(100))
        .saturating_add(day_of_year);
    era.saturating_mul(DAYS_PER_ERA)
        .saturating_add(day_of_era)
        .saturating_sub(DAYS_FROM_ZERO_TO_EPOCH)
}

pub(crate) fn civil_from_days(days: i64) -> CivilDate {
    let shifted = days.saturating_add(DAYS_FROM_ZERO_TO_EPOCH);
    let era = shifted.div_euclid(DAYS_PER_ERA);
    let day_of_era = shifted.rem_euclid(DAYS_PER_ERA);
    let year_of_era = day_of_era
        .saturating_sub(day_of_era.div_euclid(1460))
        .saturating_add(day_of_era.div_euclid(36_524))
        .saturating_sub(day_of_era.div_euclid(146_096))
        .div_euclid(365);
    let day_of_year = day_of_era.saturating_sub(
        year_of_era
            .saturating_mul(365)
            .saturating_add(year_of_era.div_euclid(4))
            .saturating_sub(year_of_era.div_euclid(100)),
    );
    let shifted_month = day_of_year
        .saturating_mul(5)
        .saturating_add(2)
        .div_euclid(153);
    let day = day_of_year
        .saturating_sub(
            shifted_month
                .saturating_mul(153)
                .saturating_add(2)
                .div_euclid(5),
        )
        .saturating_add(1);
    let month = if shifted_month < 10 {
        shifted_month.saturating_add(3)
    } else {
        shifted_month.saturating_sub(9)
    };
    let year = year_of_era
        .saturating_add(era.saturating_mul(400))
        .saturating_add(i64::from(month <= 2));
    CivilDate { year, month, day }
}

pub(crate) fn iso_weekday(days: i64) -> i64 {
    days.saturating_add(MONDAY_BASED_EPOCH_SHIFT)
        .rem_euclid(DAYS_PER_WEEK)
        .saturating_add(1)
}
