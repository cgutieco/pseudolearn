#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::Interval;

const GUARD_BITS: u64 = 16;

pub(crate) fn natural_logarithm_of_two(precision: u64) -> Result<Interval, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let series = inverse_power_sum(3, false, working)?;
    Ok(series.shift_left(1).shift_right(GUARD_BITS))
}

pub(crate) fn half_turn(precision: u64) -> Result<Interval, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let fifth = inverse_power_sum(5, true, working)?;
    let large = inverse_power_sum(239, true, working)?;
    let sum = fifth.shift_left(4).subtract(&large.shift_left(2));
    Ok(sum.shift_right(GUARD_BITS))
}

fn inverse_power_sum(
    denominator: u64,
    alternating: bool,
    precision: u64,
) -> Result<Interval, LibraryError> {
    let square = denominator
        .checked_mul(denominator)
        .ok_or(LibraryError::PrecisionExhausted)?;
    let mut power = divided(&Interval::one(precision), denominator)?;
    let mut sum = power.clone();
    let mut odd = 1_u64;
    let mut negative = false;
    while !power.is_within_units(1) {
        power = divided(&power, square)?;
        odd = odd.checked_add(2).ok_or(LibraryError::PrecisionExhausted)?;
        negative = alternating && !negative;
        let term = divided(&power, odd)?;
        sum = if negative {
            sum.subtract(&term)
        } else {
            sum.add(&term)
        };
    }
    Ok(sum.widen(2))
}

fn divided(value: &Interval, divisor: u64) -> Result<Interval, LibraryError> {
    value
        .divide_small(divisor)
        .ok_or(LibraryError::PrecisionExhausted)
}
