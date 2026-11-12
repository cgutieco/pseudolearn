pub(crate) const DATE_TIME_TYPE: &str = r#"def days_from_civil(year, month, day):
    year = year - 1 if month <= 2 else year
    era, year_of_era = divmod(year, 400)
    shifted_month = month - 3 if month > 2 else month + 9
    day_of_year = (153 * shifted_month + 2) // 5 + day - 1
    day_of_era = year_of_era * 365 + year_of_era // 4 - year_of_era // 100 + day_of_year
    return era * 146_097 + day_of_era - 719_468


def civil_from_days(days):
    era, day_of_era = divmod(days + 719_468, 146_097)
    year_of_era = (day_of_era - day_of_era // 1460 + day_of_era // 36_524 - day_of_era // 146_096) // 365
    day_of_year = day_of_era - (365 * year_of_era + year_of_era // 4 - year_of_era // 100)
    shifted_month = (5 * day_of_year + 2) // 153
    day = day_of_year - (153 * shifted_month + 2) // 5 + 1
    month = shifted_month + 3 if shifted_month < 10 else shifted_month - 9
    return year_of_era + era * 400 + (1 if month <= 2 else 0), month, day


class DateTime:
    def __init__(self, instant, offset_seconds):
        self.instant = instant
        self.offset_seconds = offset_seconds

    def parts(self):
        seconds, nanosecond = divmod(self.instant + self.offset_seconds * 1_000_000_000, 1_000_000_000)
        days, of_day = divmod(seconds, 86_400)
        year, month, day = civil_from_days(days)
        return [year, month, day, of_day // 3600, of_day % 3600 // 60, of_day % 60, nanosecond, (days + 3) % 7 + 1]


def date_time_from(year, month, day, hour, minute, second, nanosecond, offset_seconds):
    leap = year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)
    last = {2: 29 if leap else 28, 4: 30, 6: 30, 9: 30, 11: 30}.get(month, 31 if 1 <= month <= 12 else 0)
    valid = (1 <= day <= last and 0 <= hour < 24 and 0 <= minute < 60 and 0 <= second < 60
             and 0 <= nanosecond < 1_000_000_000 and -43_200 <= offset_seconds <= 50_400
             and offset_seconds % 60 == 0)
    if not valid:
        return Nothing()
    seconds = days_from_civil(year, month, day) * 86_400 + hour * 3600 + minute * 60 + second - offset_seconds
    instant = seconds * 1_000_000_000 + nanosecond
    if not -2 ** 63 <= instant < 2 ** 63:
        return Nothing()
    return Some(DateTime(instant, offset_seconds))


def offset_suffix(offset_seconds):
    if offset_seconds == 0:
        return "Z"
    magnitude = abs(offset_seconds)
    return f"{'-' if offset_seconds < 0 else '+'}{magnitude // 3600:02}:{magnitude % 3600 // 60:02}""#;

pub(crate) const CLOCK_LOCAL_NOW: &str = r#"@host_operation
def clock_local_now(clock):
    instant = time.time_ns()
    offset = time.localtime(instant // 1_000_000_000).tm_gmtoff
    return DateTime(instant, int(offset / 60) * 60)"#;

pub(crate) const DATE_TIME_UTC: &str = r#"def date_time_utc(instant):
    return DateTime(instant, 0)"#;

pub(crate) const DATE_TIME_OF: &str = r#"def date_time_of(year, month, day, hour, minute, second, nanosecond, offset_seconds):
    return date_time_from(year, month, day, hour, minute, second, nanosecond, offset_seconds)"#;

pub(crate) const DATE_TIME_PARSE: &str = r#"ISO_DATE_TIME = re.compile(
    r"([0-9]{4})-([0-9]{2})-([0-9]{2})"
    r"(?:T([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\.([0-9]{1,9}))?(Z|[+-][0-9]{2}:[0-9]{2})?)?"
)


def date_time_parse(text):
    found = ISO_DATE_TIME.fullmatch(text)
    if found is None:
        return Nothing()
    year, month, day, hour, minute, second, fraction, zone = found.groups()
    offset = 0
    if zone not in (None, "Z"):
        if int(zone[4:]) >= 60:
            return Nothing()
        offset = (int(zone[1:3]) * 3600 + int(zone[4:]) * 60) * (-1 if zone[0] == "-" else 1)
    nanosecond = int((fraction or "0").ljust(9, "0"))
    return date_time_from(int(year), int(month), int(day), int(hour or 0), int(minute or 0),
                          int(second or 0), nanosecond, offset)"#;

pub(crate) const DATE_TIME_ISO_FORMAT: &str = r#"def date_time_iso_format(value):
    year, month, day, hour, minute, second, nanosecond, weekday = value.parts()
    return f"{year:04}-{month:02}-{day:02}T{hour:02}:{minute:02}:{second:02}" + offset_suffix(value.offset_seconds)"#;

pub(crate) const DATE_TIME_ISO_FORMAT_PRECISE: &str = r#"def date_time_iso_format_precise(value):
    year, month, day, hour, minute, second, nanosecond, weekday = value.parts()
    text = f"{year:04}-{month:02}-{day:02}T{hour:02}:{minute:02}:{second:02}.{nanosecond:09}"
    return text + offset_suffix(value.offset_seconds)"#;

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
    Some(format!("def {name}(value):\n    return {body}"))
}
