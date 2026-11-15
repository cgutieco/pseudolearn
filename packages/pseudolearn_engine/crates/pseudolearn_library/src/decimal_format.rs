#![forbid(unsafe_code)]

use crate::precision::Natural;
use pseudolearn_runtime::MemoryError;

pub const MAXIMUM_DECIMAL_PLACES: i64 = 100;
const CHUNK_DIGITS: usize = 19;
const CHUNK_DIVISOR: u64 = 10_000_000_000_000_000_000;
const FRACTION_MASK: u64 = (1 << 52) - 1;
const IMPLICIT_BIT: u64 = 1 << 52;
const SUBNORMAL_EXPONENT: i64 = -1074;
const EXPONENT_BIAS_WITH_FRACTION: i64 = 1075;

pub fn format_fixed_decimals(value: f64, places: i64) -> Result<String, MemoryError> {
    let places = u32::try_from(places)
        .ok()
        .filter(|places| i64::from(*places) <= MAXIMUM_DECIMAL_PLACES)
        .ok_or(MemoryError::DecimalPlacesOutOfRange)?;
    if !value.is_finite() {
        return Ok(value.to_string());
    }
    let (mantissa, exponent) = binary_parts(value);
    let scaled = Natural::from_u64(mantissa).multiply(&Natural::from_u64(10).power(places));
    let rounded = scale_by_binary_exponent(scaled, exponent)?;
    let digits = decimal_digits(rounded)?;
    let places = usize::try_from(places).map_err(|_| MemoryError::Internal)?;
    place_point(value.is_sign_negative(), &digits, places)
}

fn binary_parts(value: f64) -> (u64, i64) {
    let bits = value.to_bits();
    let exponent_bits = i64::from(u16::try_from(bits.wrapping_shr(52) & 0x7ff).unwrap_or(0));
    let fraction = bits & FRACTION_MASK;
    if exponent_bits == 0 {
        (fraction, SUBNORMAL_EXPONENT)
    } else {
        (
            fraction | IMPLICIT_BIT,
            exponent_bits.saturating_sub(EXPONENT_BIAS_WITH_FRACTION),
        )
    }
}

fn scale_by_binary_exponent(scaled: Natural, exponent: i64) -> Result<Natural, MemoryError> {
    if exponent >= 0 {
        let shift = u64::try_from(exponent).map_err(|_| MemoryError::Internal)?;
        return Ok(scaled.shift_left(shift));
    }
    let shift = exponent.unsigned_abs();
    let round_up = scaled.bit(shift.saturating_sub(1));
    let quotient = scaled.shift_right(shift);
    Ok(if round_up {
        quotient.increment()
    } else {
        quotient
    })
}

fn decimal_digits(number: Natural) -> Result<String, MemoryError> {
    let mut chunks = Vec::new();
    let mut rest = number;
    while !rest.is_zero() {
        let (quotient, remainder) = rest
            .divide_small(CHUNK_DIVISOR)
            .ok_or(MemoryError::Internal)?;
        chunks.push(remainder);
        rest = quotient;
    }
    let mut digits = String::new();
    for (position, chunk) in chunks.iter().rev().enumerate() {
        if position == 0 {
            digits.push_str(&chunk.to_string());
        } else {
            digits.push_str(&format!("{chunk:0>width$}", width = CHUNK_DIGITS));
        }
    }
    if digits.is_empty() {
        digits.push('0');
    }
    Ok(digits)
}

fn place_point(negative: bool, digits: &str, places: usize) -> Result<String, MemoryError> {
    let width = places.saturating_add(1);
    let padded = format!("{digits:0>width$}");
    let split = padded.len().saturating_sub(places);
    let (whole, fraction) = padded
        .split_at_checked(split)
        .ok_or(MemoryError::Internal)?;
    let mut text = String::new();
    if negative {
        text.push('-');
    }
    text.push_str(whole);
    if places > 0 {
        text.push('.');
        text.push_str(fraction);
    }
    Ok(text)
}
