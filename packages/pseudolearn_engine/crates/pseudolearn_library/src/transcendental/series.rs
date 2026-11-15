#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::Interval;

const MAXIMUM_TERMS: u64 = 1 << 16;

pub(crate) struct OddPowerSeries<'argument> {
    pub argument: &'argument Interval,
    pub alternating: bool,
    pub precision: u64,
}

pub(crate) fn odd_power_sum(series: &OddPowerSeries<'_>) -> Result<Interval, LibraryError> {
    let square = series.argument.multiply(series.argument, series.precision);
    let mut power = series.argument.clone();
    let mut sum = series.argument.clone();
    let mut denominator = 1_u64;
    let mut negative = false;
    for _ in 0..MAXIMUM_TERMS {
        power = power.multiply(&square, series.precision);
        denominator = denominator
            .checked_add(2)
            .ok_or(LibraryError::PrecisionExhausted)?;
        negative = series.alternating && !negative;
        let term = power
            .divide_small(denominator)
            .ok_or(LibraryError::PrecisionExhausted)?;
        sum = if negative {
            sum.subtract(&term)
        } else {
            sum.add(&term)
        };
        if power.is_within_units(1) {
            return Ok(sum.widen(2));
        }
    }
    Err(LibraryError::PrecisionExhausted)
}

pub(crate) struct FactorialSeries<'argument> {
    pub argument: &'argument Interval,
    pub alternating: bool,
    pub precision: u64,
}

pub(crate) fn factorial_sum(
    series: &FactorialSeries<'_>,
    first: Interval,
    divisor_at: impl Fn(u64) -> Option<u64>,
) -> Result<Interval, LibraryError> {
    let (argument, precision) = (series.argument, series.precision);
    let mut term = first.clone();
    let mut sum = first;
    for index in 1..MAXIMUM_TERMS {
        let divisor = divisor_at(index).ok_or(LibraryError::PrecisionExhausted)?;
        let negative = series.alternating && index & 1 == 1;
        term = term
            .multiply(argument, precision)
            .divide_small(divisor)
            .ok_or(LibraryError::PrecisionExhausted)?;
        sum = if negative {
            sum.subtract(&term)
        } else {
            sum.add(&term)
        };
        if term.is_within_units(1) {
            return Ok(sum.widen(2));
        }
    }
    Err(LibraryError::PrecisionExhausted)
}
