#![forbid(unsafe_code)]

use crate::conversion::{integer_magnitude, parts, signed_magnitude};
use pseudolearn_runtime::ArithmeticError;

pub fn truncate_real(value: f64) -> Result<i64, ArithmeticError> {
    let (negative, exponent, mantissa) = parts(value)?;
    if exponent > 63 {
        return Err(ArithmeticError::IntegerOverflow);
    }
    let magnitude = integer_magnitude(mantissa, exponent)?;
    signed_magnitude(magnitude, negative)
}

pub fn round_real(value: f64) -> Result<i64, ArithmeticError> {
    let (negative, exponent, mantissa) = parts(value)?;
    if exponent < -1 {
        return Ok(0);
    }
    if exponent > 63 {
        return Err(ArithmeticError::IntegerOverflow);
    }
    if exponent == -1 {
        return signed_magnitude(1, negative);
    }
    let magnitude = integer_magnitude(mantissa, exponent)?;
    let rounded = round_fraction(mantissa, exponent, magnitude);
    signed_magnitude(rounded, negative)
}

fn round_fraction(mantissa: u64, exponent: i32, magnitude: u64) -> u64 {
    if exponent >= 52 {
        return magnitude;
    }
    let distance = 52_i32.saturating_sub(exponent);
    let shift = u32::try_from(distance).unwrap_or(0);
    let fraction_mask = 1_u64.checked_shl(shift).unwrap_or(0).saturating_sub(1);
    let fraction = mantissa & fraction_mask;
    let halfway_shift = shift.saturating_sub(1);
    let halfway = 1_u64.checked_shl(halfway_shift).unwrap_or(0);
    if fraction >= halfway {
        magnitude.saturating_add(1)
    } else {
        magnitude
    }
}
