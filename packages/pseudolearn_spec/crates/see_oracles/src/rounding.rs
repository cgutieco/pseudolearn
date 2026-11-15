use crate::rational::{Rational, arithmetic_error, power_two};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{Signed, ToPrimitive, Zero};

pub fn round_binary64(value: &Rational) -> Result<f64, String> {
    if value.is_zero() {
        return Ok(0.0);
    }
    let magnitude = value.abs();
    let exponent = binary_exponent(&magnitude)?;
    let quantum = exponent
        .max(-1022)
        .checked_sub(52)
        .ok_or_else(arithmetic_error)?;
    let scaled = crate::rational::divide(&magnitude, &power_two(quantum)?)?;
    let significand = rounded_integer(&scaled)?;
    let bits = encode(significand, exponent)?;
    let sign = if value.is_negative() { 1_u64 << 63 } else { 0 };
    Ok(f64::from_bits(bits | sign))
}

fn binary_exponent(value: &Rational) -> Result<i64, String> {
    let numerator = i64::try_from(value.numer().bits()).map_err(|_| arithmetic_error())?;
    let denominator = i64::try_from(value.denom().bits()).map_err(|_| arithmetic_error())?;
    let candidate = numerator
        .checked_sub(denominator)
        .ok_or_else(arithmetic_error)?;
    if value < &power_two(candidate)? {
        candidate.checked_sub(1).ok_or_else(arithmetic_error)
    } else {
        Ok(candidate)
    }
}

fn rounded_integer(value: &Rational) -> Result<u64, String> {
    let (quotient, remainder) = value.numer().div_rem(value.denom());
    let doubled = remainder
        .checked_mul(&BigInt::from(2))
        .ok_or_else(arithmetic_error)?;
    let rounded = quotient.to_u64().ok_or_else(arithmetic_error)?;
    if doubled > *value.denom() || (doubled == *value.denom() && rounded & 1 != 0) {
        rounded.checked_add(1).ok_or_else(arithmetic_error)
    } else {
        Ok(rounded)
    }
}

fn encode(significand: u64, exponent: i64) -> Result<u64, String> {
    if exponent < -1022 {
        return Ok(significand);
    }
    let carry = significand >= (1_u64 << 53);
    let exponent = exponent
        .checked_add(i64::from(carry))
        .ok_or_else(arithmetic_error)?;
    if exponent > 1023 {
        return Ok(0x7ff0_0000_0000_0000);
    }
    let mantissa = if carry { significand >> 1 } else { significand };
    let fraction = mantissa
        .checked_sub(1_u64 << 52)
        .ok_or_else(arithmetic_error)?;
    let biased = exponent.checked_add(1023).ok_or_else(arithmetic_error)?;
    let biased = u64::try_from(biased).map_err(|_| arithmetic_error())?;
    Ok((biased << 52) | fraction)
}

pub fn midpoint(left: f64, right: f64) -> Result<Rational, String> {
    let sum = crate::rational::add(
        &crate::rational::exact(left)?,
        &crate::rational::exact(right)?,
    )?;
    crate::rational::divide(&sum, &crate::rational::integer(2))
}
