#![forbid(unsafe_code)]

use crate::precision::{Integer, Interval};
use crate::{LibraryError, round_real};

use super::binary64::{Decomposed, decompose, exact_interval, round_interval};
use super::constants::natural_logarithm_of_two;
use super::series::{FactorialSeries, factorial_sum};
use super::ziv::correctly_rounded;

const OVERFLOW_ARGUMENT: f64 = 710.0;
const UNDERFLOW_ARGUMENT: f64 = -746.0;
const UNIT_ARGUMENT: f64 = 1.0 / 1_152_921_504_606_846_976.0;
const LOG2_E: f64 = std::f64::consts::LOG2_E;
const GUARD_BITS: u64 = 32;

pub fn exponential(value: f64) -> Result<f64, LibraryError> {
    let decomposed = decompose(value)?;
    if value > OVERFLOW_ARGUMENT {
        return Err(LibraryError::NonFiniteResult);
    }
    if value < UNDERFLOW_ARGUMENT {
        return Ok(0.0);
    }
    if value.abs() < UNIT_ARGUMENT {
        return Ok(1.0);
    }
    correctly_rounded(|precision| attempt(&decomposed, value, precision))
}

fn attempt(argument: &Decomposed, value: f64, precision: u64) -> Result<Option<f64>, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let exponent = round_real(value * LOG2_E).map_err(LibraryError::from)?;
    let interval = exact_interval(argument, working);
    let (mantissa, scale) = scaled_exponential(&interval, exponent, working)?;
    Ok(round_interval(&mantissa, scale))
}

pub(crate) fn scaled_exponential(
    argument: &Interval,
    exponent: i64,
    precision: u64,
) -> Result<(Interval, i64), LibraryError> {
    let logarithm = natural_logarithm_of_two(precision)?;
    let reduced = argument.subtract(&logarithm.multiply_integer(&Integer::from_i64(exponent)));
    if !reduced.is_within_units_of_power(precision) {
        return Err(LibraryError::PrecisionExhausted);
    }
    let series = FactorialSeries {
        argument: &reduced,
        alternating: false,
        precision,
    };
    let mantissa = factorial_sum(&series, Interval::one(precision), Some)?;
    let scale = exponent.saturating_sub(i64::try_from(precision).unwrap_or(i64::MAX));
    Ok((mantissa, scale))
}
