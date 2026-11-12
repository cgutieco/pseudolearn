use std::f64::consts::{E, FRAC_PI_2, FRAC_PI_4, LN_2, SQRT_2};

use pseudolearn_library::{
    LibraryError, arctangent, cosine, exponential, natural_logarithm, real_power, sine,
};

fn bits(result: Result<f64, LibraryError>) -> Result<u64, LibraryError> {
    result.map(f64::to_bits)
}

#[test]
fn exponential_matches_correctly_rounded_constants() {
    assert_eq!(bits(exponential(1.0)), Ok(E.to_bits()));
    assert_eq!(bits(exponential(0.0)), Ok(1.0_f64.to_bits()));
    assert_eq!(bits(exponential(-0.0)), Ok(1.0_f64.to_bits()));
    assert_eq!(bits(exponential(LN_2)), Ok(2.0_f64.to_bits()));
}

#[test]
fn exponential_handles_range_boundaries() {
    assert_eq!(exponential(710.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(exponential(709.8), Err(LibraryError::NonFiniteResult));
    assert!(exponential(709.7).is_ok_and(f64::is_finite));
    assert_eq!(bits(exponential(-746.0)), Ok(0));
    assert_eq!(bits(exponential(-745.1)), Ok(1));
    assert_eq!(exponential(f64::NAN), Err(LibraryError::NonFiniteInput));
}

#[test]
fn logarithm_matches_correctly_rounded_constants() {
    assert_eq!(bits(natural_logarithm(2.0)), Ok(LN_2.to_bits()));
    assert_eq!(bits(natural_logarithm(E)), Ok(1.0_f64.to_bits()));
    assert_eq!(bits(natural_logarithm(1.0)), Ok(0));
    assert_eq!(
        natural_logarithm(f64::from_bits(1)),
        Ok(-744.440_071_921_381_2)
    );
}

#[test]
fn logarithm_rejects_its_invalid_domain() {
    assert_eq!(natural_logarithm(0.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(natural_logarithm(-0.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(natural_logarithm(-1.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(
        natural_logarithm(f64::INFINITY),
        Err(LibraryError::NonFiniteInput)
    );
}

#[test]
fn trigonometric_functions_keep_signed_zero_and_small_identities() {
    assert_eq!(bits(sine(-0.0)), Ok((-0.0_f64).to_bits()));
    assert_eq!(bits(sine(1.0e-20)), Ok(1.0e-20_f64.to_bits()));
    assert_eq!(bits(cosine(-0.0)), Ok(1.0_f64.to_bits()));
    assert_eq!(bits(sine(f64::from_bits(1))), Ok(1));
}

#[test]
fn trigonometric_reduction_is_exact_for_huge_arguments() {
    assert_eq!(sine(1.0e22), Ok(-0.852_200_849_767_188_8));
    assert_eq!(cosine(1.0e22), Ok(0.523_214_785_395_139));
    assert!(sine(f64::MAX).is_ok_and(|value| value.abs() <= 1.0));
    assert_eq!(sine(f64::INFINITY), Err(LibraryError::NonFiniteInput));
}

#[test]
fn arctangent_matches_quarter_and_half_turns() {
    assert_eq!(bits(arctangent(1.0)), Ok(FRAC_PI_4.to_bits()));
    assert_eq!(bits(arctangent(1.0e300)), Ok(FRAC_PI_2.to_bits()));
    assert_eq!(bits(arctangent(-1.0e300)), Ok((-FRAC_PI_2).to_bits()));
    assert_eq!(bits(arctangent(-0.0)), Ok((-0.0_f64).to_bits()));
}

#[test]
fn power_handles_exact_results() {
    assert_eq!(real_power(2.0, 10.0), Ok(1024.0));
    assert_eq!(real_power(4.0, 0.5), Ok(2.0));
    assert_eq!(bits(real_power(2.0, 0.5)), Ok(SQRT_2.to_bits()));
    assert_eq!(real_power(-2.0, 3.0), Ok(-8.0));
    assert_eq!(real_power(9.0, 1.5), Ok(27.0));
    assert_eq!(
        real_power(208_065.0 * 208_065.0, 1.5),
        Ok(9_007_351_116_674_625.0)
    );
    assert_eq!(bits(real_power(4.0, -537.5)), Ok(0));
    assert_eq!(bits(real_power(2.0, -1074.0)), Ok(1));
    assert_eq!(bits(real_power(2.0, -1075.0)), Ok(0));
    assert_eq!(real_power(0.0, 0.0), Ok(1.0));
    assert_eq!(real_power(5.0, -0.0), Ok(1.0));
}

#[test]
fn power_keeps_signed_zero_rules() {
    assert_eq!(bits(real_power(-0.0, 3.0)), Ok((-0.0_f64).to_bits()));
    assert_eq!(bits(real_power(-0.0, 2.0)), Ok(0));
    assert_eq!(real_power(0.0, -1.0), Err(LibraryError::NonFiniteResult));
}

#[test]
fn power_traps_undefined_and_overflowing_results() {
    assert_eq!(real_power(-2.0, 0.5), Err(LibraryError::NonFiniteResult));
    assert_eq!(real_power(10.0, 400.0), Err(LibraryError::NonFiniteResult));
    assert_eq!(bits(real_power(10.0, -400.0)), Ok(0));
    assert_eq!(real_power(f64::NAN, 2.0), Err(LibraryError::NonFiniteInput));
    assert_eq!(real_power(1.0, 1.0e300), Ok(1.0));
}
