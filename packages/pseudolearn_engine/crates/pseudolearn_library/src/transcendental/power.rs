#![forbid(unsafe_code)]

use crate::precision::{Integer, Interval, Natural};
use crate::{LibraryError, round_real};

use super::binary64::{Decomposed, decompose, exact_interval, round_interval, round_scaled};
use super::exponential::scaled_exponential;
use super::logarithm::scaled_logarithm;
use super::power_exact::{Dyadic, dyadic, exact_power};
use super::ziv::{correctly_rounded, finite, signed_precision};

const GUARD_BITS: u64 = 32;
const MAGNITUDE_GUARD_BITS: u64 = 16;
const OVERFLOW_LOGARITHM: u64 = 710;
const UNDERFLOW_LOGARITHM: u64 = 746;
const LOG2_E: f64 = std::f64::consts::LOG2_E;

pub fn real_power(base: f64, exponent: f64) -> Result<f64, LibraryError> {
    let base_parts = decompose(base)?;
    let exponent_parts = decompose(exponent)?;
    if exponent_parts.significand == 0 {
        return Ok(1.0);
    }
    let exponent_dyadic = dyadic(&exponent_parts);
    let parity = integer_parity(exponent_dyadic);
    if base_parts.significand == 0 {
        return zero_base(&base_parts, &exponent_parts, parity);
    }
    if base_parts.negative && parity.is_none() {
        return Err(LibraryError::NonFiniteResult);
    }
    let positive_base = Decomposed {
        negative: false,
        ..base_parts
    };
    let magnitude = positive_power(&positive_base, &exponent_parts, exponent_dyadic)?;
    let negative = base_parts.negative && parity == Some(true);
    finite(if negative { -magnitude } else { magnitude })
}

fn zero_base(
    base: &Decomposed,
    exponent: &Decomposed,
    parity: Option<bool>,
) -> Result<f64, LibraryError> {
    if exponent.negative {
        return Err(LibraryError::NonFiniteResult);
    }
    let negative = base.negative && parity == Some(true);
    Ok(if negative { -0.0 } else { 0.0 })
}

fn integer_parity(exponent: Dyadic) -> Option<bool> {
    match exponent.exponent {
        0 => Some(exponent.odd & 1 == 1),
        value if value > 0 => Some(false),
        _ => None,
    }
}

fn positive_power(
    base: &Decomposed,
    exponent: &Decomposed,
    exponent_dyadic: Dyadic,
) -> Result<f64, LibraryError> {
    if let Some(exact) = exact_power(dyadic(base), exponent_dyadic)? {
        return Ok(exact);
    }
    correctly_rounded(|precision| attempt(base, exponent, precision))
}

fn attempt(
    base: &Decomposed,
    exponent: &Decomposed,
    precision: u64,
) -> Result<Option<f64>, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let magnitude_bits = u64::try_from(exponent.exponent.saturating_add(53).max(0)).unwrap_or(0);
    let extended = working
        .saturating_add(magnitude_bits)
        .saturating_add(MAGNITUDE_GUARD_BITS);
    let logarithm = scaled_logarithm(base, extended)?;
    let product = logarithm.multiply(&exact_interval(exponent, extended), extended);
    if let Some(decided) = out_of_range(&product, extended)? {
        return Ok(Some(decided));
    }
    let reduced = product.shift_right(extended.saturating_sub(working));
    let estimate = round_scaled(&reduced.lower, signed_precision(working));
    let binary_exponent = round_real(estimate * LOG2_E).map_err(LibraryError::from)?;
    let (mantissa, scale) = scaled_exponential(&reduced, binary_exponent, working)?;
    Ok(round_interval(&mantissa, scale))
}

fn out_of_range(product: &Interval, precision: u64) -> Result<Option<f64>, LibraryError> {
    let unit = Natural::power_of_two(precision);
    let overflow = Integer::new(false, unit.multiply_small(OVERFLOW_LOGARITHM));
    let underflow = Integer::new(true, unit.multiply_small(UNDERFLOW_LOGARITHM));
    if product.lower > overflow {
        return Err(LibraryError::NonFiniteResult);
    }
    if product.upper < underflow {
        return Ok(Some(0.0));
    }
    Ok(None)
}
