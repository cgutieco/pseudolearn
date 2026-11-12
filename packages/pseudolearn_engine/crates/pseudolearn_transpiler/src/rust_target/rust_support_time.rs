pub(crate) const DATE_TIME_TYPE: &str = r#"#[derive(Clone, Copy, PartialEq)]
struct DateTime {
    instant: i64,
    offset_seconds: i64,
}

const NANOSECONDS_PER_SECOND: i128 = 1_000_000_000;

fn days_from_civil(year: i64, month: i64, day: i64) -> i64 {
    let year = if month <= 2 { year - 1 } else { year };
    let (era, year_of_era) = (year.div_euclid(400), year.rem_euclid(400));
    let shifted_month = if month > 2 { month - 3 } else { month + 9 };
    let day_of_year = (153 * shifted_month + 2) / 5 + day - 1;
    let day_of_era = year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year;
    era * 146_097 + day_of_era - 719_468
}

fn civil_from_days(days: i64) -> (i64, i64, i64) {
    let shifted = days + 719_468;
    let (era, day_of_era) = (shifted.div_euclid(146_097), shifted.rem_euclid(146_097));
    let year_of_era = (day_of_era - day_of_era / 1460 + day_of_era / 36_524 - day_of_era / 146_096) / 365;
    let day_of_year = day_of_era - (365 * year_of_era + year_of_era / 4 - year_of_era / 100);
    let shifted_month = (5 * day_of_year + 2) / 153;
    let day = day_of_year - (153 * shifted_month + 2) / 5 + 1;
    let month = if shifted_month < 10 { shifted_month + 3 } else { shifted_month - 9 };
    (year_of_era + era * 400 + i64::from(month <= 2), month, day)
}

impl DateTime {
    fn parts(&self) -> [i64; 8] {
        let local = i128::from(self.instant) + i128::from(self.offset_seconds) * NANOSECONDS_PER_SECOND;
        let seconds = local.div_euclid(NANOSECONDS_PER_SECOND);
        let nanosecond = local.rem_euclid(NANOSECONDS_PER_SECOND) as i64;
        let days = seconds.div_euclid(86_400) as i64;
        let of_day = seconds.rem_euclid(86_400) as i64;
        let (year, month, day) = civil_from_days(days);
        let weekday = (days + 3).rem_euclid(7) + 1;
        [year, month, day, of_day / 3600, of_day % 3600 / 60, of_day % 60, nanosecond, weekday]
    }

    fn of(date: [i64; 3], time: [i64; 4], offset_seconds: i64) -> Option<DateTime> {
        let [year, month, day] = date;
        let [hour, minute, second, nanosecond] = time;
        if !(-1_000_000..=1_000_000).contains(&year) {
            return None;
        }
        let leap = year.rem_euclid(4) == 0 && (year.rem_euclid(100) != 0 || year.rem_euclid(400) == 0);
        let last = match month {
            1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
            4 | 6 | 9 | 11 => 30,
            2 if leap => 29,
            2 => 28,
            _ => return None,
        };
        let valid = (1..=last).contains(&day)
            && (0..24).contains(&hour)
            && (0..60).contains(&minute)
            && (0..60).contains(&second)
            && (0..1_000_000_000).contains(&nanosecond)
            && (-43_200..=50_400).contains(&offset_seconds)
            && offset_seconds.rem_euclid(60) == 0;
        if !valid {
            return None;
        }
        let seconds = i128::from(days_from_civil(year, month, day)) * 86_400
            + i128::from(hour * 3600 + minute * 60 + second - offset_seconds);
        let instant = i64::try_from(seconds * NANOSECONDS_PER_SECOND + i128::from(nanosecond)).ok()?;
        Some(DateTime { instant, offset_seconds })
    }
}

fn offset_suffix(offset_seconds: i64) -> String {
    if offset_seconds == 0 {
        return "Z".to_string();
    }
    let sign = if offset_seconds < 0 { '-' } else { '+' };
    let magnitude = offset_seconds.abs();
    format!("{sign}{:02}:{:02}", magnitude / 3600, magnitude % 3600 / 60)
}"#;

pub(crate) const DATE_TIME_UTC: &str = r#"fn date_time_utc(instant: i64) -> DateTime {
    DateTime { instant, offset_seconds: 0 }
}"#;

pub(crate) const DATE_TIME_OF: &str = r#"fn date_time_of(year: i64, month: i64, day: i64, hour: i64, minute: i64, second: i64, nanosecond: i64, offset_seconds: i64) -> Option<DateTime> {
    DateTime::of([year, month, day], [hour, minute, second, nanosecond], offset_seconds)
}"#;

pub(crate) const DATE_TIME_PARSE: &str = r#"fn date_time_parse(text: &str) -> Option<DateTime> {
    let bytes = text.as_bytes();
    let number = |start: usize, width: usize| -> Option<i64> {
        let digits = bytes.get(start..start + width)?;
        digits.iter().all(u8::is_ascii_digit).then(|| digits.iter().fold(0, |value, digit| value * 10 + i64::from(digit - b'0')))
    };
    let mark = |index: usize, expected: u8| bytes.get(index) == Some(&expected);
    let date = [number(0, 4)?, number(5, 2)?, number(8, 2)?];
    if !mark(4, b'-') || !mark(7, b'-') {
        return None;
    }
    if bytes.len() == 10 {
        return DateTime::of(date, [0; 4], 0);
    }
    if !mark(10, b'T') || !mark(13, b':') || !mark(16, b':') {
        return None;
    }
    let (mut index, mut nanosecond) = (19, 0);
    if mark(index, b'.') {
        let digits = bytes[20..].iter().take_while(|byte| byte.is_ascii_digit()).count();
        if digits == 0 || digits > 9 {
            return None;
        }
        nanosecond = number(20, digits)? * 10_i64.pow(9 - digits as u32);
        index = 20 + digits;
    }
    let offset_seconds = match bytes.get(index) {
        None => 0,
        Some(b'Z') if bytes.len() == index + 1 => 0,
        Some(sign @ (b'+' | b'-')) if bytes.len() == index + 6 && mark(index + 3, b':') => {
            let (hours, minutes) = (number(index + 1, 2)?, number(index + 4, 2)?);
            if minutes >= 60 {
                return None;
            }
            (hours * 3600 + minutes * 60) * if *sign == b'-' { -1 } else { 1 }
        }
        _ => return None,
    };
    DateTime::of(date, [number(11, 2)?, number(14, 2)?, number(17, 2)?, nanosecond], offset_seconds)
}"#;

pub(crate) const DATE_TIME_ISO_FORMAT: &str = r#"fn date_time_iso_format(value: &DateTime) -> String {
    let [year, month, day, hour, minute, second, ..] = value.parts();
    let suffix = offset_suffix(value.offset_seconds);
    format!("{year:04}-{month:02}-{day:02}T{hour:02}:{minute:02}:{second:02}{suffix}")
}"#;

pub(crate) const DATE_TIME_ISO_FORMAT_PRECISE: &str = r#"fn date_time_iso_format_precise(value: &DateTime) -> String {
    let [year, month, day, hour, minute, second, nanosecond, _] = value.parts();
    let suffix = offset_suffix(value.offset_seconds);
    format!("{year:04}-{month:02}-{day:02}T{hour:02}:{minute:02}:{second:02}.{nanosecond:09}{suffix}")
}"#;

pub(crate) fn date_time_field(name: &str) -> Option<String> {
    let body = match name {
        "date_time_utc_offset" => "value.offset_seconds".to_owned(),
        "date_time_instant" => "value.instant".to_owned(),
        other => {
            let fields = [
                "year",
                "month",
                "day",
                "hour",
                "minute",
                "second",
                "nanosecond",
                "weekday",
            ];
            let field = other.strip_prefix("date_time_")?;
            let index = fields.iter().position(|candidate| *candidate == field)?;
            format!("value.parts()[{index}]")
        }
    };
    Some(format!(
        "fn {name}(value: &DateTime) -> i64 {{\n    {body}\n}}"
    ))
}
