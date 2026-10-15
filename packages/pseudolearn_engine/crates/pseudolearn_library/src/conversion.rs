#![forbid(unsafe_code)]

use pseudolearn_runtime::ArithmeticError;

const FRACTION_MASK: u64 = (1_u64 << 52) - 1;
const SIGN_MASK: u64 = 1_u64 << 63;
const EXPONENT_MASK: u64 = 0x7ff;

#[inline]
pub fn integer_to_real(value: i64) -> f64 {
    let magnitude = value.unsigned_abs();
    if magnitude == 0 {
        return 0.0;
    }
    let highest_bit = 63_u32.saturating_sub(magnitude.leading_zeros());
    let exponent = 1023_u64 + u64::from(highest_bit);
    let significand = rounded_significand(magnitude, highest_bit);
    let (adjusted_exponent, fraction) = if significand == (1_u64 << 53) {
        (exponent.saturating_add(1), 0)
    } else {
        (exponent, significand & FRACTION_MASK)
    };
    let sign = if value.is_negative() { SIGN_MASK } else { 0 };
    let bits = sign | (adjusted_exponent << 52) | fraction;
    f64::from_bits(bits)
}

#[inline]
pub fn real_to_integer(value: f64) -> Result<i64, ArithmeticError> {
    let bits = value.to_bits();
    let exponent_field = (bits >> 52) & EXPONENT_MASK;
    if exponent_field == EXPONENT_MASK {
        return Err(ArithmeticError::IntegerOverflow);
    }
    let exponent = i32::try_from(exponent_field)
        .map_err(|_| ArithmeticError::IntegerOverflow)?
        .checked_sub(1023)
        .ok_or(ArithmeticError::IntegerOverflow)?;
    if exponent < 0 {
        return Ok(0);
    }
    if exponent > 63 {
        return Err(ArithmeticError::IntegerOverflow);
    }
    let mantissa = (1_u64 << 52) | (bits & FRACTION_MASK);
    let magnitude = integer_magnitude(mantissa, exponent)?;
    signed_magnitude(magnitude, bits & SIGN_MASK != 0)
}

pub(crate) fn parts(value: f64) -> Result<(bool, i32, u64), ArithmeticError> {
    let bits = value.to_bits();
    let exponent_field = (bits >> 52) & EXPONENT_MASK;
    if exponent_field == EXPONENT_MASK {
        return Err(ArithmeticError::IntegerOverflow);
    }
    let sign = bits & SIGN_MASK != 0;
    let exponent = i32::try_from(exponent_field)
        .map_err(|_| ArithmeticError::IntegerOverflow)?
        .checked_sub(1023)
        .ok_or(ArithmeticError::IntegerOverflow)?;
    let mantissa = if exponent_field == 0 {
        bits & FRACTION_MASK
    } else {
        (1_u64 << 52) | (bits & FRACTION_MASK)
    };
    Ok((sign, exponent, mantissa))
}

pub(crate) fn integer_magnitude(mantissa: u64, exponent: i32) -> Result<u64, ArithmeticError> {
    if exponent < 0 {
        return Ok(0);
    }
    if exponent <= 52 {
        let distance = 52_i32
            .checked_sub(exponent)
            .ok_or(ArithmeticError::IntegerOverflow)?;
        let shift = u32::try_from(distance).map_err(|_| ArithmeticError::IntegerOverflow)?;
        return Ok(mantissa >> shift);
    }
    let distance = exponent
        .checked_sub(52)
        .ok_or(ArithmeticError::IntegerOverflow)?;
    let shift = u32::try_from(distance).map_err(|_| ArithmeticError::IntegerOverflow)?;
    mantissa
        .checked_shl(shift)
        .ok_or(ArithmeticError::IntegerOverflow)
}

pub(crate) fn signed_magnitude(magnitude: u64, negative: bool) -> Result<i64, ArithmeticError> {
    if negative && magnitude == (1_u64 << 63) {
        return Ok(i64::MIN);
    }
    let converted = i64::try_from(magnitude).map_err(|_| ArithmeticError::IntegerOverflow)?;
    if negative {
        converted
            .checked_neg()
            .ok_or(ArithmeticError::IntegerOverflow)
    } else {
        Ok(converted)
    }
}

fn rounded_significand(magnitude: u64, highest_bit: u32) -> u64 {
    if highest_bit <= 52 {
        let shift = 52_u32.saturating_sub(highest_bit);
        return magnitude.checked_shl(shift).unwrap_or(0);
    }
    let shift = highest_bit.saturating_sub(52);
    let truncated = magnitude >> shift;
    let discarded_mask = 1_u64.checked_shl(shift).unwrap_or(0).saturating_sub(1);
    let discarded = magnitude & discarded_mask;
    let halfway_shift = shift.saturating_sub(1);
    let halfway = 1_u64.checked_shl(halfway_shift).unwrap_or(0);
    if discarded > halfway || (discarded == halfway && truncated & 1 == 1) {
        truncated.saturating_add(1)
    } else {
        truncated
    }
}
