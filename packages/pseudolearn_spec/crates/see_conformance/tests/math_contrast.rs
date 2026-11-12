use see_conformance::math_arguments::MathFunction;
use see_conformance::math_contrast::{
    MathOutcome, expected, format_arguments, format_outcome, parse_arguments, parse_outcome,
};

fn finite(value: f64) -> Result<MathOutcome, String> {
    Ok(MathOutcome::Finite(value.to_bits()))
}

#[test]
fn oracle_decides_ordinary_values() {
    assert_eq!(expected(MathFunction::Exponential, &[0.0]), finite(1.0));
    assert_eq!(
        expected(MathFunction::Arctangent, &[1.0]),
        finite(std::f64::consts::FRAC_PI_4)
    );
    assert_eq!(expected(MathFunction::Power, &[2.0, 10.0]), finite(1024.0));
}

#[test]
fn invalid_domains_and_overflow_are_non_finite() {
    assert_eq!(
        expected(MathFunction::Logarithm, &[0.0]),
        Ok(MathOutcome::NonFinite)
    );
    assert_eq!(
        expected(MathFunction::Power, &[-2.0, 0.5]),
        Ok(MathOutcome::NonFinite)
    );
    assert_eq!(
        expected(MathFunction::Exponential, &[1000.0]),
        Ok(MathOutcome::NonFinite)
    );
}

#[test]
fn exact_power_midpoints_terminate() {
    assert_eq!(expected(MathFunction::Power, &[4.0, -537.5]), finite(0.0));
    assert_eq!(expected(MathFunction::Power, &[9.0, 1.5]), finite(27.0));
}

#[test]
fn argument_count_must_match_the_function() {
    assert!(expected(MathFunction::Sine, &[1.0, 2.0]).is_err());
    assert!(expected(MathFunction::Power, &[1.0]).is_err());
}

#[test]
fn text_forms_round_trip() {
    let row = [1.5, -0.0];
    assert_eq!(
        parse_arguments(&format_arguments(&row)).map(|values| values
            .iter()
            .map(|value| value.to_bits())
            .collect::<Vec<_>>()),
        Ok(vec![1.5_f64.to_bits(), (-0.0_f64).to_bits()])
    );
    for outcome in [MathOutcome::Finite(42), MathOutcome::NonFinite] {
        assert_eq!(parse_outcome(&format_outcome(outcome)), Ok(outcome));
    }
}

#[test]
fn malformed_text_is_rejected() {
    assert!(parse_arguments("xyz").is_err());
    assert!(parse_outcome("trap").is_err());
}
