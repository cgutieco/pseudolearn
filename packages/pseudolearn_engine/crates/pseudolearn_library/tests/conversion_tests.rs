use pseudolearn_library::{integer_to_real, real_to_integer};
use pseudolearn_runtime::ArithmeticError;

#[test]
fn integer_real_conversion_rounds_to_binary64() {
    assert_eq!(integer_to_real(0), 0.0);
    assert_eq!(integer_to_real(42), 42.0);
    assert_eq!(integer_to_real(-42), -42.0);
    assert_eq!(
        integer_to_real(9_007_199_254_740_993),
        9_007_199_254_740_992.0
    );
    assert_eq!(integer_to_real(i64::MIN), -9_223_372_036_854_775_808.0);
}

#[test]
fn real_integer_conversion_truncates_toward_zero() {
    assert_eq!(real_to_integer(2.9), Ok(2));
    assert_eq!(real_to_integer(-2.9), Ok(-2));
    assert_eq!(real_to_integer(-0.5), Ok(0));
    assert_eq!(real_to_integer(-9_223_372_036_854_775_808.0), Ok(i64::MIN));
    assert_eq!(
        real_to_integer(f64::INFINITY),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(
        real_to_integer(9_223_372_036_854_775_808.0),
        Err(ArithmeticError::IntegerOverflow)
    );
}
