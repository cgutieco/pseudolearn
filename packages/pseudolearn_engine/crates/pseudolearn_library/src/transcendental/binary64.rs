#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::{Integer, Interval, Natural};

const FRACTION_BITS: u64 = 52;
const FRACTION_MASK: u64 = (1_u64 << 52) - 1;
const HIDDEN_BIT: u64 = 1_u64 << 52;
const EXPONENT_BIAS: i64 = 1075;
const MINIMUM_EXPONENT: i64 = -1074;
const MAXIMUM_LEADING_EXPONENT: i64 = 1023;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct Decomposed {
    pub negative: bool,
    pub significand: u64,
    pub exponent: i64,
}

pub(crate) fn decompose(value: f64) -> Result<Decomposed, LibraryError> {
    if !value.is_finite() {
        return Err(LibraryError::NonFiniteInput);
    }
    let bits = value.to_bits();
    let field =
        i64::try_from((bits >> FRACTION_BITS) & 0x7ff).map_err(|_| LibraryError::NonFiniteInput)?;
    let fraction = bits & FRACTION_MASK;
    let (significand, exponent) = if field == 0 {
        (fraction, MINIMUM_EXPONENT)
    } else {
        (fraction | HIDDEN_BIT, field.saturating_sub(EXPONENT_BIAS))
    };
    Ok(Decomposed {
        negative: bits >> 63 == 1,
        significand,
        exponent,
    })
}

pub(crate) fn exact_interval(value: &Decomposed, precision: u64) -> Interval {
    let magnitude = Integer::new(value.negative, Natural::from_u64(value.significand));
    let shift = value
        .exponent
        .saturating_add(i64::try_from(precision).unwrap_or(i64::MAX));
    match u64::try_from(shift) {
        Ok(left) => Interval::point(magnitude.shift_left(left)),
        Err(_) => Interval::point(magnitude).shift_right(shift.unsigned_abs()),
    }
}

pub(crate) fn round_interval(interval: &Interval, scale: i64) -> Option<f64> {
    let lower = round_scaled(&interval.lower, scale);
    let upper = round_scaled(&interval.upper, scale);
    (lower.to_bits() == upper.to_bits()).then_some(lower)
}

pub(crate) fn round_scaled(value: &Integer, scale: i64) -> f64 {
    let sign = if value.is_negative() { -1.0 } else { 1.0 };
    let magnitude = value.magnitude();
    if magnitude.is_zero() {
        return f64::copysign(0.0, sign);
    }
    let length = i64::try_from(magnitude.bit_length()).unwrap_or(i64::MAX);
    let leading = length.saturating_sub(1).saturating_add(scale);
    if leading > MAXIMUM_LEADING_EXPONENT {
        return f64::copysign(f64::INFINITY, sign);
    }
    let unit = leading.saturating_sub(52).max(MINIMUM_EXPONENT);
    let shift = unit.saturating_sub(scale);
    let mantissa = rounded_mantissa(magnitude, shift);
    f64::copysign(compose(mantissa, unit), sign)
}

fn rounded_mantissa(magnitude: &Natural, shift: i64) -> u64 {
    if shift <= 0 {
        return magnitude
            .shift_left(shift.unsigned_abs())
            .to_u64()
            .unwrap_or(u64::MAX);
    }
    let dropped = shift.unsigned_abs();
    let kept = magnitude.shift_right(dropped).to_u64().unwrap_or(u64::MAX);
    let half = dropped
        .checked_sub(1)
        .is_some_and(|index| magnitude.bit(index));
    let sticky = magnitude.has_bits_below(dropped.saturating_sub(1));
    if half && (sticky || kept & 1 == 1) {
        kept.saturating_add(1)
    } else {
        kept
    }
}

fn compose(mantissa: u64, unit: i64) -> f64 {
    let (mantissa, unit) = if mantissa >= HIDDEN_BIT << 1 {
        (mantissa >> 1, unit.saturating_add(1))
    } else {
        (mantissa, unit)
    };
    if mantissa < HIDDEN_BIT {
        return f64::from_bits(mantissa);
    }
    let field = unit.saturating_add(EXPONENT_BIAS);
    match u64::try_from(field) {
        Ok(field) if field < 0x7ff => {
            f64::from_bits((field << FRACTION_BITS) | (mantissa & FRACTION_MASK))
        }
        _ => f64::INFINITY,
    }
}
