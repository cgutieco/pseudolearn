use super::binary64::{decompose, round_interval};
use super::logarithm::scaled_logarithm;
use super::ziv::{correctly_rounded, signed_precision};
use crate::LibraryError;

pub fn logarithm2(value: f64) -> Result<f64, LibraryError> {
    logarithm(value, 2.0)
}
pub fn logarithm10(value: f64) -> Result<f64, LibraryError> {
    logarithm(value, 10.0)
}

fn logarithm(value: f64, base: f64) -> Result<f64, LibraryError> {
    let argument = decompose(value)?;
    if value <= 0.0 {
        return Err(LibraryError::NonFiniteResult);
    }
    if value == 1.0 {
        return Ok(0.0);
    }
    if base == 2.0 && argument.significand.is_power_of_two() {
        let exponent = argument
            .exponent
            .saturating_add(i64::from(argument.significand.trailing_zeros()));
        return Ok(f64::from(
            i32::try_from(exponent).map_err(|_| LibraryError::NonFiniteResult)?,
        ));
    }
    if base == 10.0 {
        let mut power = 1.0_f64;
        for exponent in 1..=22 {
            power *= 10.0;
            if value == power {
                return Ok(f64::from(exponent));
            }
        }
    }
    let denominator = decompose(base)?;
    correctly_rounded(|precision| {
        let working = precision.saturating_add(64);
        let numerator = scaled_logarithm(&argument, working)?;
        let denominator = scaled_logarithm(&denominator, working)?;
        Ok(numerator
            .divide(&denominator, working)
            .and_then(|result| round_interval(&result, signed_precision(working))))
    })
}
