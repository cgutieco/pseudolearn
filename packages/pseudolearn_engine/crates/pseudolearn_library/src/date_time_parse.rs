#![forbid(unsafe_code)]

use crate::civil_calendar::CivilDate;
use crate::date_time_construction::{DateTimeParts, construct, offset_is_valid};
use pseudolearn_runtime::DateTimeValue;

const MAXIMUM_FRACTION_DIGITS: usize = 9;

struct Cursor<'text> {
    bytes: &'text [u8],
    index: usize,
}

impl Cursor<'_> {
    fn peek(&self) -> Option<u8> {
        self.bytes.get(self.index).copied()
    }

    fn advance(&mut self) {
        self.index = self.index.saturating_add(1);
    }

    fn expect(&mut self, expected: u8) -> Option<()> {
        (self.peek()? == expected).then(|| self.advance())
    }

    fn digits(&mut self, count: usize) -> Option<i64> {
        let mut value: i64 = 0;
        for _ in 0..count {
            let digit = self.peek().filter(u8::is_ascii_digit)?;
            value = value
                .saturating_mul(10)
                .saturating_add(i64::from(digit.saturating_sub(b'0')));
            self.advance();
        }
        Some(value)
    }

    fn is_finished(&self) -> bool {
        self.index >= self.bytes.len()
    }
}

pub(crate) fn parse_iso(text: &str) -> Option<DateTimeValue> {
    let mut cursor = Cursor {
        bytes: text.as_bytes(),
        index: 0,
    };
    let date = parse_date(&mut cursor)?;
    let mut parts = DateTimeParts {
        date,
        hour: 0,
        minute: 0,
        second: 0,
        nanosecond: 0,
        offset_seconds: 0,
    };
    if !cursor.is_finished() {
        parse_time(&mut cursor, &mut parts)?;
        parts.offset_seconds = parse_zone(&mut cursor)?;
    }
    cursor.is_finished().then_some(())?;
    construct(parts)
}

fn parse_date(cursor: &mut Cursor<'_>) -> Option<CivilDate> {
    let year = cursor.digits(4)?;
    cursor.expect(b'-')?;
    let month = cursor.digits(2)?;
    cursor.expect(b'-')?;
    let day = cursor.digits(2)?;
    Some(CivilDate { year, month, day })
}

fn parse_time(cursor: &mut Cursor<'_>, parts: &mut DateTimeParts) -> Option<()> {
    cursor.expect(b'T')?;
    parts.hour = cursor.digits(2)?;
    cursor.expect(b':')?;
    parts.minute = cursor.digits(2)?;
    cursor.expect(b':')?;
    parts.second = cursor.digits(2)?;
    if cursor.peek() == Some(b'.') {
        cursor.advance();
        parts.nanosecond = parse_fraction(cursor)?;
    }
    Some(())
}

fn parse_fraction(cursor: &mut Cursor<'_>) -> Option<i64> {
    let mut value: i64 = 0;
    let mut count: usize = 0;
    while let Some(digit) = cursor.peek().filter(u8::is_ascii_digit) {
        count = count.saturating_add(1);
        if count > MAXIMUM_FRACTION_DIGITS {
            return None;
        }
        value = value
            .saturating_mul(10)
            .saturating_add(i64::from(digit.saturating_sub(b'0')));
        cursor.advance();
    }
    let missing = MAXIMUM_FRACTION_DIGITS.checked_sub(count)?;
    (count > 0).then_some(())?;
    (0..missing).try_fold(value, |scaled, _| scaled.checked_mul(10))
}

fn parse_zone(cursor: &mut Cursor<'_>) -> Option<i64> {
    let sign = match cursor.peek() {
        None => return Some(0),
        Some(b'Z') => {
            cursor.advance();
            return Some(0);
        }
        Some(b'+') => 1_i64,
        Some(b'-') => -1_i64,
        Some(_) => return None,
    };
    cursor.advance();
    let hours = cursor.digits(2)?;
    cursor.expect(b':')?;
    let minutes = cursor.digits(2)?;
    (minutes < 60).then_some(())?;
    let offset = hours
        .saturating_mul(3600)
        .saturating_add(minutes.saturating_mul(60))
        .saturating_mul(sign);
    offset_is_valid(offset).then_some(offset)
}
