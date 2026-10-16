#![forbid(unsafe_code)]

use crate::ArithmeticError;

#[inline]
pub fn int_add(left: i64, right: i64) -> Result<i64, ArithmeticError> {
    left.checked_add(right)
        .ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_subtract(left: i64, right: i64) -> Result<i64, ArithmeticError> {
    left.checked_sub(right)
        .ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_multiply(left: i64, right: i64) -> Result<i64, ArithmeticError> {
    left.checked_mul(right)
        .ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_negate(value: i64) -> Result<i64, ArithmeticError> {
    value.checked_neg().ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_divide(left: i64, right: i64) -> Result<i64, ArithmeticError> {
    if right == 0 {
        return Err(ArithmeticError::DivisionByZero);
    }
    left.checked_div(right)
        .ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_modulo(left: i64, right: i64) -> Result<i64, ArithmeticError> {
    if right == 0 {
        return Err(ArithmeticError::DivisionByZero);
    }
    if left == i64::MIN && right == -1 {
        return Ok(0);
    }
    left.checked_rem(right)
        .ok_or(ArithmeticError::IntegerOverflow)
}

#[inline]
pub fn int_power(base: i64, exponent: i64) -> Result<i64, ArithmeticError> {
    if exponent < 0 {
        return Err(ArithmeticError::NegativeExponent);
    }
    let mut remaining = u64::try_from(exponent).map_err(|_| ArithmeticError::IntegerOverflow)?;
    let mut factor = base;
    let mut product = 1_i64;
    while remaining > 0 {
        if remaining & 1 == 1 {
            product = int_multiply(product, factor)?;
        }
        remaining >>= 1;
        if remaining > 0 {
            factor = int_multiply(factor, factor)?;
        }
    }
    Ok(product)
}

#[inline]
pub fn real_add(left: f64, right: f64) -> Result<f64, ArithmeticError> {
    finite(left + right)
}

#[inline]
pub fn real_subtract(left: f64, right: f64) -> Result<f64, ArithmeticError> {
    finite(left - right)
}

#[inline]
pub fn real_multiply(left: f64, right: f64) -> Result<f64, ArithmeticError> {
    finite(left * right)
}

#[inline]
pub fn real_divide(left: f64, right: f64) -> Result<f64, ArithmeticError> {
    if right == 0.0 {
        return Err(ArithmeticError::DivisionByZero);
    }
    finite(left / right)
}

#[inline]
fn finite(value: f64) -> Result<f64, ArithmeticError> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(ArithmeticError::NonFiniteRealResult)
    }
}
