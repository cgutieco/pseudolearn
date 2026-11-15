#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::{Integer, Interval, Natural};

use super::binary64::{Decomposed, decompose, round_interval};
use super::constants::natural_logarithm_of_two;
use super::series::{OddPowerSeries, odd_power_sum};
use super::ziv::{correctly_rounded, signed_precision};

const GUARD_BITS: u64 = 32;
const EXPONENT_GUARD_BITS: u64 = 12;

pub fn natural_logarithm(value: f64) -> Result<f64, LibraryError> {
    let decomposed = decompose(value)?;
    if decomposed.negative || decomposed.significand == 0 {
        return Err(LibraryError::NonFiniteResult);
    }
    if value == 1.0 {
        return Ok(0.0);
    }
    correctly_rounded(|precision| {
        let working = precision.saturating_add(GUARD_BITS);
        let logarithm = scaled_logarithm(&decomposed, working)?;
        Ok(round_interval(&logarithm, signed_precision(working)))
    })
}

pub(crate) fn scaled_logarithm(
    value: &Decomposed,
    precision: u64,
) -> Result<Interval, LibraryError> {
    let (mantissa, exponent) = normalized_mantissa(value, precision)?;
    let one = Interval::one(precision);
    let ratio = mantissa
        .subtract(&one)
        .divide(&mantissa.add(&one), precision)
        .ok_or(LibraryError::PrecisionExhausted)?;
    let series = OddPowerSeries {
        argument: &ratio,
        alternating: false,
        precision,
    };
    let mantissa_logarithm = odd_power_sum(&series)?.shift_left(1);
    let extended = precision.saturating_add(EXPONENT_GUARD_BITS);
    let binary = natural_logarithm_of_two(extended)?
        .multiply_integer(&Integer::from_i64(exponent))
        .shift_right(EXPONENT_GUARD_BITS);
    Ok(binary.add(&mantissa_logarithm))
}

fn normalized_mantissa(
    value: &Decomposed,
    precision: u64,
) -> Result<(Interval, i64), LibraryError> {
    let significand = Natural::from_u64(value.significand);
    let length = significand.bit_length();
    let top = length.checked_sub(1).ok_or(LibraryError::NonFiniteInput)?;
    let mut exponent = value
        .exponent
        .checked_add(i64::try_from(top).map_err(|_| LibraryError::NonFiniteInput)?)
        .ok_or(LibraryError::NonFiniteInput)?;
    let mut scale = precision
        .checked_sub(top)
        .ok_or(LibraryError::PrecisionExhausted)?;
    let square = significand.multiply(&significand);
    if square > Natural::power_of_two(top.saturating_mul(2).saturating_add(1)) {
        scale = scale
            .checked_sub(1)
            .ok_or(LibraryError::PrecisionExhausted)?;
        exponent = exponent
            .checked_add(1)
            .ok_or(LibraryError::NonFiniteInput)?;
    }
    let mantissa = Integer::new(false, significand.shift_left(scale));
    Ok((Interval::point(mantissa), exponent))
}
