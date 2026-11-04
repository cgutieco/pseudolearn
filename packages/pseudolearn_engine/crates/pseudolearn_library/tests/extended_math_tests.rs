use pseudolearn_library::{
    LibraryError, arc_cosine, arc_sine, arc_tangent2, ceiling_real, floor_real, logarithm2,
    logarithm10, tangent,
};
use pseudolearn_runtime::ArithmeticError;

#[test]
fn exact_values_and_signed_zeros_are_preserved() -> Result<(), LibraryError> {
    for value in [0.0_f64, -0.0, f64::from_bits(1), -f64::from_bits(1)] {
        assert_eq!(tangent(value)?.to_bits(), value.to_bits());
        assert_eq!(arc_sine(value)?.to_bits(), value.to_bits());
    }
    assert_eq!(arc_cosine(1.0)?.to_bits(), 0);
    assert_eq!(arc_sine(1.0)?, std::f64::consts::FRAC_PI_2);
    assert_eq!(arc_cosine(-1.0)?, std::f64::consts::PI);
    assert_eq!(logarithm2(f64::from_bits(1))?, -1074.0);
    assert_eq!(logarithm10(1000.0)?, 3.0);
    Ok(())
}

#[test]
fn quadrants_include_signed_zero_pairs() -> Result<(), LibraryError> {
    for vertical in [0.0_f64, -0.0] {
        assert_eq!(arc_tangent2(vertical, 0.0)?.to_bits(), vertical.to_bits());
        assert_eq!(
            arc_tangent2(vertical, -0.0)?.to_bits(),
            std::f64::consts::PI.copysign(vertical).to_bits()
        );
    }
    assert_eq!(arc_tangent2(1.0, 1.0)?, std::f64::consts::FRAC_PI_4);
    assert_eq!(
        arc_tangent2(-1.0, -1.0)?,
        -3.0 * std::f64::consts::FRAC_PI_4
    );
    assert!(arc_tangent2(f64::MAX, f64::from_bits(1))?.is_finite());
    Ok(())
}

#[test]
fn invalid_domains_and_rounding_limits_are_rejected() {
    for function in [logarithm2, logarithm10] {
        assert_eq!(function(0.0), Err(LibraryError::NonFiniteResult));
        assert_eq!(function(-1.0), Err(LibraryError::NonFiniteResult));
    }
    assert_eq!(arc_sine(2.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(arc_cosine(-2.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(tangent(f64::NAN), Err(LibraryError::NonFiniteInput));
    assert_eq!(floor_real(-0.5), Ok(-1));
    assert_eq!(ceiling_real(-0.5), Ok(0));
    assert_eq!(floor_real(9.3e18), Err(ArithmeticError::IntegerOverflow));
}
