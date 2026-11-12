use super::binary64::decompose;
use super::power_exact::{dyadic, exact_power};
use crate::LibraryError;

fn exact(base: f64, exponent: f64) -> Result<Option<f64>, LibraryError> {
    let base = decompose(base)?;
    let exponent = decompose(exponent)?;
    exact_power(dyadic(&base), dyadic(&exponent))
}

#[test]
fn integral_powers_of_small_odd_bases_are_exact() {
    assert_eq!(exact(3.0, 34.0), Ok(Some(16_677_181_699_666_569.0)));
    assert_eq!(exact(3.0, 35.0), Ok(None));
}

#[test]
fn perfect_roots_are_detected() {
    assert_eq!(exact(9.0, 1.5), Ok(Some(27.0)));
    assert_eq!(exact(2.0, 0.5), Ok(None));
    assert_eq!(exact(4.0, -0.5), Ok(Some(0.5)));
}

#[test]
fn powers_of_two_use_exponent_arithmetic() {
    assert_eq!(exact(2.0, 1.0e300), Err(LibraryError::NonFiniteResult));
    assert_eq!(exact(0.5, 1.0e300), Ok(Some(0.0)));
    assert_eq!(exact(2.0, -1075.0), Ok(Some(0.0)));
}

#[test]
fn negative_exponents_of_odd_bases_use_the_general_path() {
    assert_eq!(exact(3.0, -2.0), Ok(None));
}
