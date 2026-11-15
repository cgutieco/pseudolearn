use pseudolearn_library::{round_real, truncate_real};
use pseudolearn_runtime::ArithmeticError;

#[test]
fn truncation_and_rounding_follow_library_contract() {
    assert_eq!(truncate_real(-2.9), Ok(-2));
    assert_eq!(round_real(2.5), Ok(3));
    assert_eq!(round_real(-2.5), Ok(-3));
    assert_eq!(round_real(2.49), Ok(2));
    assert_eq!(round_real(-2.49), Ok(-2));
    assert_eq!(round_real(-0.5), Ok(-1));
    assert_eq!(round_real(0.5), Ok(1));
}

#[test]
fn truncation_and_rounding_reject_unrepresentable_values() {
    assert_eq!(
        truncate_real(f64::INFINITY),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(round_real(f64::NAN), Err(ArithmeticError::IntegerOverflow));
    assert_eq!(
        truncate_real(9_223_372_036_854_775_808.0),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(round_real(-9_223_372_036_854_775_808.0), Ok(i64::MIN));
}
