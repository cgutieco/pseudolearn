use super::binary64::{decompose, round_scaled};
use crate::LibraryError;
use crate::precision::Integer;

fn rounded(value: i64, scale: i64) -> u64 {
    round_scaled(&Integer::from_i64(value), scale).to_bits()
}

#[test]
fn ties_round_to_even_significands() {
    let base = 1_i64 << 53;
    assert_eq!(
        rounded(base + 1, 0),
        (9_007_199_254_740_992.0_f64).to_bits()
    );
    assert_eq!(
        rounded(base + 3, 0),
        (9_007_199_254_740_996.0_f64).to_bits()
    );
    assert_eq!(rounded(3, -1075), 2);
    assert_eq!(rounded(1, -1075), 0);
}

#[test]
fn subnormal_and_overflow_boundaries() {
    assert_eq!(rounded(1, -1074), 1);
    assert_eq!(rounded(1, -1022), f64::MIN_POSITIVE.to_bits());
    assert_eq!(rounded((1_i64 << 53) - 1, 971), f64::MAX.to_bits());
    assert_eq!(rounded(1, 1024), f64::INFINITY.to_bits());
    assert_eq!(rounded(-1, 1024), f64::NEG_INFINITY.to_bits());
}

#[test]
fn zero_keeps_the_sign_of_tiny_negative_values() {
    assert_eq!(rounded(-1, -1080), (-0.0_f64).to_bits());
    assert_eq!(rounded(0, 5), 0);
}

#[test]
fn decomposition_rejects_non_finite_values() {
    assert_eq!(decompose(f64::NAN), Err(LibraryError::NonFiniteInput));
    assert!(
        decompose(f64::from_bits(1))
            .is_ok_and(|parts| parts.significand == 1 && parts.exponent == -1074)
    );
    assert!(decompose(-2.0).is_ok_and(|parts| parts.negative && parts.significand == 1 << 52));
}
