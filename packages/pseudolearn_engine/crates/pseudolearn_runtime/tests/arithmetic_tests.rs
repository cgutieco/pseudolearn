use pseudolearn_runtime::{
    ArithmeticError, int_add, int_divide, int_modulo, int_multiply, int_negate, int_power,
    int_subtract, real_add, real_divide, real_multiply, real_subtract,
};

#[test]
fn checked_integer_operations_return_exact_results() {
    assert_eq!(int_add(17, 25), Ok(42));
    assert_eq!(int_subtract(17, 25), Ok(-8));
    assert_eq!(int_multiply(-7, 6), Ok(-42));
    assert_eq!(int_negate(8), Ok(-8));
    assert_eq!(int_divide(-42, 6), Ok(-7));
    assert_eq!(int_modulo(-7, 2), Ok(-1));
    assert_eq!(int_modulo(i64::MIN, -1), Ok(0));
    assert_eq!(int_power(3, 4), Ok(81));
    assert_eq!(int_power(9, 0), Ok(1));
}

#[test]
fn checked_integer_operations_report_overflow_and_invalid_domains() {
    assert_eq!(int_add(i64::MAX, 1), Err(ArithmeticError::IntegerOverflow));
    assert_eq!(
        int_subtract(i64::MIN, 1),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(
        int_multiply(i64::MAX, 2),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(int_negate(i64::MIN), Err(ArithmeticError::IntegerOverflow));
    assert_eq!(
        int_divide(i64::MIN, -1),
        Err(ArithmeticError::IntegerOverflow)
    );
    assert_eq!(int_divide(1, 0), Err(ArithmeticError::DivisionByZero));
    assert_eq!(int_modulo(1, 0), Err(ArithmeticError::DivisionByZero));
    assert_eq!(int_power(2, -1), Err(ArithmeticError::NegativeExponent));
    assert_eq!(int_power(2, 63), Err(ArithmeticError::IntegerOverflow));
}

#[test]
fn checked_real_operations_reject_non_finite_results() {
    assert_eq!(real_add(1.25, 2.75), Ok(4.0));
    assert_eq!(real_subtract(5.5, 0.5), Ok(5.0));
    assert_eq!(real_multiply(-2.0, 4.0), Ok(-8.0));
    assert_eq!(real_divide(9.0, 3.0), Ok(3.0));
    assert_eq!(
        real_add(f64::MAX, f64::MAX),
        Err(ArithmeticError::NonFiniteRealResult)
    );
    assert_eq!(real_divide(1.0, 0.0), Err(ArithmeticError::DivisionByZero));
}

#[test]
fn real_division_distinguishes_zero_divisors_from_overflow() {
    assert_eq!(real_divide(0.0, -0.0), Err(ArithmeticError::DivisionByZero));
    assert_eq!(real_divide(1.0, -0.0), Err(ArithmeticError::DivisionByZero));
    assert_eq!(
        real_divide(f64::MAX, 0.5),
        Err(ArithmeticError::NonFiniteRealResult)
    );
    assert_eq!(real_divide(-9.0, 2.0), Ok(-4.5));
}
