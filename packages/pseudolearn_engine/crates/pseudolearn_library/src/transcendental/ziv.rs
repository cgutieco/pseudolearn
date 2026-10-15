#![forbid(unsafe_code)]

use crate::LibraryError;

const FIRST_PRECISION: u64 = 128;
const LAST_PRECISION: u64 = 1 << 14;

pub(crate) fn correctly_rounded(
    mut attempt: impl FnMut(u64) -> Result<Option<f64>, LibraryError>,
) -> Result<f64, LibraryError> {
    let mut precision = FIRST_PRECISION;
    while precision <= LAST_PRECISION {
        if let Some(value) = attempt(precision)? {
            return finite(value);
        }
        precision = precision.saturating_mul(2);
    }
    Err(LibraryError::PrecisionExhausted)
}

pub(crate) fn finite(value: f64) -> Result<f64, LibraryError> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LibraryError::NonFiniteResult)
    }
}

pub(crate) fn signed_precision(precision: u64) -> i64 {
    i64::try_from(precision).map_or(i64::MIN, |value| value.saturating_neg())
}
