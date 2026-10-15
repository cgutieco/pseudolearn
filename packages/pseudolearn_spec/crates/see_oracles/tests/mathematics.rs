use see_oracles::mathematics::{Function, power, rounded};

#[test]
fn elementary_values_match_independently_derived_bits() -> Result<(), String> {
    for (function, argument, expected) in [
        (Function::SquareRoot, 2.0, 0x3ff6_a09e_667f_3bcd),
        (Function::Logarithm, 2.0, 0x3fe6_2e42_fefa_39ef),
        (Function::Exponential, 1.0, 0x4005_bf0a_8b14_5769),
        (Function::Sine, 1.0, 0x3fea_ed54_8f09_0cee),
        (Function::Cosine, 1.0, 0x3fe1_4a28_0fb5_068c),
        (Function::Arctangent, 1.0, 0x3fe9_21fb_5444_2d18),
    ] {
        assert_eq!(
            rounded(function, argument)?.to_bits(),
            expected,
            "{function:?}"
        );
    }
    Ok(())
}

#[test]
fn exact_values_and_domain_boundaries_are_explicit() -> Result<(), String> {
    assert_eq!(rounded(Function::Logarithm, 1.0)?, 0.0);
    assert_eq!(rounded(Function::Exponential, 0.0)?, 1.0);
    assert_eq!(
        rounded(Function::SquareRoot, f64::from_bits(1))?,
        f64::from_bits(0x1e60_0000_0000_0000)
    );
    for function in [Function::SquareRoot, Function::Sine, Function::Arctangent] {
        assert_eq!(rounded(function, -0.0)?.to_bits(), (-0.0_f64).to_bits());
    }
    assert!(rounded(Function::Logarithm, 0.0).is_err());
    assert!(rounded(Function::SquareRoot, -1.0).is_err());
    assert!(rounded(Function::Cosine, f64::NAN).is_err());
    assert_eq!(rounded(Function::Exponential, -2049.0)?.to_bits(), 0);
    assert_eq!(rounded(Function::Exponential, 2049.0)?, f64::INFINITY);
    Ok(())
}

#[test]
fn power_resolves_exact_integer_results_and_fractional_domains() -> Result<(), String> {
    assert_eq!(power(2.0, 0.5)?.to_bits(), 0x3ff6_a09e_667f_3bcd);
    assert_eq!(power(-2.0, 3.0)?, -8.0);
    assert_eq!(power(-2.0, -3.0)?, -0.125);
    assert_eq!(power(1.0, f64::MAX)?, 1.0);
    assert_eq!(power(3.0, 34.0)?.to_bits(), 0x434d_9fe7_7988_1944);
    assert!(power(-2.0, 0.5).is_err());
    assert_eq!(power(0.0, 0.0)?, 1.0);
    assert!(power(f64::INFINITY, 2.0).is_err());
    Ok(())
}

#[test]
fn real_edges_cover_subnormal_parity_overflow_and_sign() -> Result<(), String> {
    assert_eq!(power(-0.0, 3.0)?.to_bits(), (-0.0_f64).to_bits());
    assert_eq!(power(-0.0, 2.0)?.to_bits(), 0);
    assert_eq!(power(2.0, 1024.0)?, f64::INFINITY);
    assert_eq!(power(2.0, -1075.0)?.to_bits(), 0);
    assert_eq!(
        rounded(Function::Arctangent, f64::MAX)?.to_bits(),
        0x3ff9_21fb_5444_2d18
    );
    assert_eq!(rounded(Function::Sine, f64::from_bits(1))?.to_bits(), 1);
    assert_eq!(rounded(Function::Cosine, f64::from_bits(1))?, 1.0);
    assert!(
        see_oracles::mathematics::enclose(
            Function::Sine,
            &num_rational::BigRational::from_integer(1.into()),
            0
        )
        .is_err()
    );
    Ok(())
}

#[test]
fn exact_dyadic_powers_terminate_on_rounding_midpoints() -> Result<(), String> {
    use see_oracles::mathematics::power;
    assert_eq!(power(4.0, -537.5)?.to_bits(), 0);
    assert_eq!(power(9.0, 1.5)?, 27.0);
    assert_eq!(power(16.0, 0.25)?, 2.0);
    let root = 208_065.0_f64;
    let midpoint = power(root * root, 1.5)?;
    assert_eq!(midpoint, 9_007_351_116_674_625.0);
    Ok(())
}
