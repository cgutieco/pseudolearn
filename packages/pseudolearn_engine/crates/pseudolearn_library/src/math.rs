#![forbid(unsafe_code)]

use crate::LibraryError;

const FRACTION_MASK: u64 = (1_u64 << 52) - 1;
const EXPONENT_MASK: u64 = 0x7ff;
const HIDDEN_BIT: u64 = 1_u64 << 52;
const CARRY_BIT: u64 = 1_u64 << 53;

pub fn absolute(value: f64) -> f64 {
    f64::from_bits(value.to_bits() & !(1_u64 << 63))
}

pub fn square_root(value: f64) -> Result<f64, LibraryError> {
    let Some((significand, exponent)) = input_components(value)? else {
        return Ok(value);
    };
    let (rounded_significand, result_exponent) = rounded_components(significand, exponent)?;
    encode_result(rounded_significand, result_exponent)
}

fn input_components(value: f64) -> Result<Option<(u64, i32)>, LibraryError> {
    let bits = value.to_bits();
    let exponent_field = (bits >> 52) & EXPONENT_MASK;
    let fraction = bits & FRACTION_MASK;
    if exponent_field == EXPONENT_MASK {
        return Err(LibraryError::NonFiniteInput);
    }
    if bits >> 63 == 1 && (exponent_field != 0 || fraction != 0) {
        return Err(LibraryError::NegativeSquareRoot);
    }
    if exponent_field == 0 && fraction == 0 {
        return Ok(None);
    }
    normalized_components(exponent_field, fraction).map(Some)
}

fn rounded_components(
    mut significand: u64,
    mut exponent: i32,
) -> Result<(u128, i32), LibraryError> {
    if exponent % 2 != 0 {
        significand = significand
            .checked_mul(2)
            .ok_or(LibraryError::NonFiniteInput)?;
        exponent = exponent
            .checked_sub(1)
            .ok_or(LibraryError::NonFiniteInput)?;
    }
    let radicand = u128::from(significand)
        .checked_shl(52)
        .ok_or(LibraryError::NonFiniteInput)?;
    let mut rounded_significand = integer_square_root(radicand);
    if round_up(radicand, rounded_significand) {
        rounded_significand = rounded_significand
            .checked_add(1)
            .ok_or(LibraryError::NonFiniteInput)?;
    }
    let mut result_exponent = exponent
        .checked_div(2)
        .ok_or(LibraryError::NonFiniteInput)?;
    if rounded_significand == u128::from(CARRY_BIT) {
        rounded_significand = u128::from(HIDDEN_BIT);
        result_exponent = result_exponent
            .checked_add(1)
            .ok_or(LibraryError::NonFiniteInput)?;
    }
    Ok((rounded_significand, result_exponent))
}

fn encode_result(rounded_significand: u128, result_exponent: i32) -> Result<f64, LibraryError> {
    let exponent_bits = result_exponent
        .checked_add(1023)
        .and_then(|field| u64::try_from(field).ok())
        .ok_or(LibraryError::NonFiniteInput)?;
    let fraction_bits = u64::try_from(rounded_significand)
        .map_err(|_| LibraryError::NonFiniteInput)?
        .checked_sub(HIDDEN_BIT)
        .ok_or(LibraryError::NonFiniteInput)?;
    let result_bits = exponent_bits
        .checked_shl(52)
        .and_then(|high| high.checked_add(fraction_bits))
        .ok_or(LibraryError::NonFiniteInput)?;
    Ok(f64::from_bits(result_bits))
}

fn normalized_components(exponent_field: u64, fraction: u64) -> Result<(u64, i32), LibraryError> {
    if exponent_field != 0 {
        let unbiased = i32::try_from(exponent_field)
            .map_err(|_| LibraryError::NonFiniteInput)?
            .checked_sub(1023)
            .ok_or(LibraryError::NonFiniteInput)?;
        return Ok((HIDDEN_BIT | fraction, unbiased));
    }
    let highest_bit = 63_u32
        .checked_sub(fraction.leading_zeros())
        .ok_or(LibraryError::NonFiniteInput)?;
    let shift = 52_u32
        .checked_sub(highest_bit)
        .ok_or(LibraryError::NonFiniteInput)?;
    let significand = fraction
        .checked_shl(shift)
        .ok_or(LibraryError::NonFiniteInput)?;
    let exponent_shift = i32::try_from(shift).map_err(|_| LibraryError::NonFiniteInput)?;
    let exponent = (-1022_i32)
        .checked_sub(exponent_shift)
        .ok_or(LibraryError::NonFiniteInput)?;
    Ok((significand, exponent))
}

fn integer_square_root(value: u128) -> u128 {
    let mut lower = 0_u128;
    let mut upper = u128::from(CARRY_BIT);
    while lower.saturating_add(1) < upper {
        let distance = upper.saturating_sub(lower);
        let midpoint = lower.saturating_add(distance / 2);
        let square = midpoint.saturating_mul(midpoint);
        if square <= value {
            lower = midpoint;
        } else {
            upper = midpoint;
        }
    }
    lower
}

fn round_up(radicand: u128, lower_root: u128) -> bool {
    let doubled_root = lower_root.saturating_mul(2);
    let midpoint = doubled_root.saturating_add(1);
    let midpoint_square = midpoint.saturating_mul(midpoint);
    let scaled_radicand = radicand.saturating_mul(4);
    scaled_radicand > midpoint_square || (scaled_radicand == midpoint_square && lower_root & 1 == 1)
}
