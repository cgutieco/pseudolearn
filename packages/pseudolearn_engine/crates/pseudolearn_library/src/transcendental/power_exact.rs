#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::{Integer, Natural};

use super::binary64::{Decomposed, round_scaled};

const EXACT_EXPONENT_LIMIT: i64 = 34;
const MAXIMUM_ROOT_DEPTH: u32 = 5;
const OVERFLOW_EXPONENT: i128 = 1024;
const UNDERFLOW_EXPONENT: i128 = -1076;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct Dyadic {
    pub negative: bool,
    pub odd: u64,
    pub exponent: i64,
}

pub(crate) fn dyadic(value: &Decomposed) -> Dyadic {
    let zeros = value.significand.trailing_zeros();
    Dyadic {
        negative: value.negative,
        odd: value.significand.checked_shr(zeros).unwrap_or(0),
        exponent: value.exponent.saturating_add(i64::from(zeros)),
    }
}

pub(crate) fn exact_power(base: Dyadic, exponent: Dyadic) -> Result<Option<f64>, LibraryError> {
    let Some((root, numerator)) = exact_root(base, exponent) else {
        return Ok(None);
    };
    if root.odd == 1 {
        return power_of_two(i128::from(root.exponent).saturating_mul(numerator)).map(Some);
    }
    if numerator <= 0 || numerator > i128::from(EXACT_EXPONENT_LIMIT) {
        return Ok(None);
    }
    let count = u32::try_from(numerator).map_err(|_| LibraryError::PrecisionExhausted)?;
    let scale = i64::try_from(i128::from(root.exponent).saturating_mul(numerator))
        .map_err(|_| LibraryError::PrecisionExhausted)?;
    let magnitude = Natural::from_u64(root.odd).power(count);
    Ok(Some(round_scaled(&Integer::new(false, magnitude), scale)))
}

fn exact_root(base: Dyadic, exponent: Dyadic) -> Option<(Dyadic, i128)> {
    let magnitude = i128::from(exponent.odd);
    let numerator = if exponent.negative {
        magnitude.saturating_neg()
    } else {
        magnitude
    };
    if exponent.exponent >= 0 {
        let shift = u32::try_from(exponent.exponent).ok()?;
        let scaled = 1_i128
            .checked_shl(shift)
            .filter(|factor| *factor > 0)
            .map_or(numerator.saturating_mul(i128::MAX), |factor| {
                numerator.saturating_mul(factor)
            });
        return Some((base, scaled));
    }
    let depth = u32::try_from(exponent.exponent.unsigned_abs()).ok()?;
    if base.odd != 1 && depth > MAXIMUM_ROOT_DEPTH {
        return None;
    }
    let divisor = 1_i64.checked_shl(depth).filter(|value| *value > 0)?;
    if base.exponent.checked_rem(divisor)? != 0 {
        return None;
    }
    let root = Dyadic {
        negative: false,
        odd: perfect_root(base.odd, depth)?,
        exponent: base.exponent.checked_div(divisor)?,
    };
    Some((root, numerator))
}

fn perfect_root(value: u64, depth: u32) -> Option<u64> {
    let mut current = Natural::from_u64(value);
    for _ in 0..depth {
        let root = current.square_root();
        if root.multiply(&root) != current {
            return None;
        }
        current = root;
    }
    current.to_u64()
}

fn power_of_two(exponent: i128) -> Result<f64, LibraryError> {
    if exponent >= OVERFLOW_EXPONENT {
        return Err(LibraryError::NonFiniteResult);
    }
    if exponent <= UNDERFLOW_EXPONENT {
        return Ok(0.0);
    }
    let scale = i64::try_from(exponent).map_err(|_| LibraryError::PrecisionExhausted)?;
    Ok(round_scaled(&Integer::from_i64(1), scale))
}
