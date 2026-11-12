use see_oracles::mathematics::{Function, rounded};

#[test]
fn exact_extended_results_terminate() -> Result<(), String> {
    assert_eq!(
        rounded(Function::Tangent, -0.0)?.to_bits(),
        (-0.0_f64).to_bits()
    );
    assert_eq!(
        rounded(Function::ArcSine, 1.0)?,
        std::f64::consts::FRAC_PI_2
    );
    assert_eq!(rounded(Function::ArcCosine, 1.0)?, 0.0);
    assert_eq!(rounded(Function::Logarithm2, f64::from_bits(1))?, -1074.0);
    assert_eq!(rounded(Function::Logarithm10, 1000.0)?, 3.0);
    assert_eq!(see_oracles::atan2(1.0, 1.0)?, std::f64::consts::FRAC_PI_4);
    Ok(())
}

#[test]
fn extended_domains_are_explicit() {
    assert!(rounded(Function::ArcSine, 2.0).is_err());
    assert!(rounded(Function::Logarithm2, 0.0).is_err());
    assert!(rounded(Function::Logarithm2, -1.0).is_err());
    assert!(see_oracles::atan2(f64::NAN, 1.0).is_err());
}
