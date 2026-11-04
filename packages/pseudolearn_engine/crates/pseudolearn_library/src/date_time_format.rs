#![forbid(unsafe_code)]

use crate::date_time_construction::components;
use pseudolearn_runtime::DateTimeValue;

pub(crate) fn iso_format(value: &DateTimeValue, precise: bool) -> String {
    let parts = components(value);
    let mut text = format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}",
        parts.date.year, parts.date.month, parts.date.day, parts.hour, parts.minute, parts.second
    );
    if precise {
        text.push_str(&format!(".{:09}", parts.nanosecond));
    }
    text.push_str(&offset_suffix(value.offset_seconds));
    text
}

fn offset_suffix(offset_seconds: i32) -> String {
    if offset_seconds == 0 {
        return "Z".to_owned();
    }
    let sign = if offset_seconds < 0 { '-' } else { '+' };
    let magnitude = offset_seconds.unsigned_abs();
    format!(
        "{sign}{:02}:{:02}",
        magnitude.div_euclid(3600),
        magnitude.rem_euclid(3600).div_euclid(60)
    )
}
