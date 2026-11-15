use crate::{MAXIMUM_DECIMAL_PLACES, format_fixed_decimals};
use pseudolearn_runtime::MemoryError;

fn fixed(value: f64, places: i64) -> String {
    format_fixed_decimals(value, places).unwrap_or_default()
}

#[test]
fn rounds_ties_away_from_zero() {
    assert_eq!(fixed(2.5, 0), "3");
    assert_eq!(fixed(-2.5, 0), "-3");
    assert_eq!(fixed(0.125, 2), "0.13");
    assert_eq!(fixed(-0.125, 2), "-0.13");
    assert_eq!(fixed(0.5, 0), "1");
}

#[test]
fn rounds_below_the_tie_down() {
    assert_eq!(fixed(2.4999, 0), "2");
    assert_eq!(fixed(1.005, 2), "1.00");
    assert_eq!(fixed(0.3, 1), "0.3");
}

#[test]
fn shows_the_exact_binary_expansion() {
    assert_eq!(fixed(0.1, 20), "0.10000000000000000555");
    assert_eq!(fixed(1e22, 2), "10000000000000000000000.00");
}

#[test]
fn pads_with_zero_decimals_and_integers() {
    assert_eq!(fixed(7.0, 2), "7.00");
    assert_eq!(fixed(7.0, 0), "7");
    assert_eq!(fixed(0.0, 3), "0.000");
}

#[test]
fn keeps_the_sign_of_zero_and_of_small_negatives() {
    assert_eq!(fixed(-0.0, 2), "-0.00");
    assert_eq!(fixed(-0.001, 2), "-0.00");
}

#[test]
fn handles_subnormal_and_extreme_values() {
    assert_eq!(fixed(5e-324, 3), "0.000");
    assert_eq!(fixed(f64::MAX, 0).len(), 309);
    assert!(fixed(f64::MIN_POSITIVE, 100).starts_with("0.000"));
}

#[test]
fn accepts_the_maximum_and_rejects_beyond_it() {
    assert_eq!(fixed(1.0, MAXIMUM_DECIMAL_PLACES).len(), 102);
    assert_eq!(
        format_fixed_decimals(1.0, MAXIMUM_DECIMAL_PLACES + 1),
        Err(MemoryError::DecimalPlacesOutOfRange)
    );
    assert_eq!(
        format_fixed_decimals(1.0, -1),
        Err(MemoryError::DecimalPlacesOutOfRange)
    );
}

#[test]
fn shows_non_finite_values_in_output_form() {
    assert_eq!(fixed(f64::NAN, 2), "NaN");
    assert_eq!(fixed(f64::INFINITY, 2), "inf");
}

#[test]
fn rounds_up_across_a_digit_chunk_boundary() {
    assert_eq!(fixed(9_007_199_254_740_991.0, 0), "9007199254740991");
    assert_eq!(fixed(1e19, 0), "10000000000000000000");
    assert_eq!(fixed(0.99999, 4), "1.0000");
}
