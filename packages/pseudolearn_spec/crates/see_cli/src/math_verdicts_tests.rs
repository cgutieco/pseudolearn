use super::{Row, compare};
use see_conformance::math_arguments::MathFunction;
use see_conformance::math_contrast::MathOutcome;

#[test]
fn altered_result_is_detected_by_the_independent_oracle() -> Result<(), String> {
    let rows = [Row {
        arguments: vec![1.0],
        engine: MathOutcome::Finite(1.0_f64.to_bits()),
    }];
    let summary = compare(MathFunction::Logarithm2, &rows)?;
    assert_eq!(summary.checked, 1);
    assert_eq!(summary.mismatches.len(), 1);
    Ok(())
}
