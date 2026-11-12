use super::stats::{geometric_mean, median, percentile, regression_slope};

#[test]
fn percentile_uses_nearest_rank_and_rejects_empty_input() {
    let values = [5.0, 1.0, 4.0, 2.0, 3.0];
    assert_eq!(percentile(&values, 0.95), 5.0);
    assert_eq!(percentile(&values, 0.2), 1.0);
    assert_eq!(median(&values), 3.0);
    assert!(percentile(&[], 0.5).is_nan());
}

#[test]
fn geometric_mean_matches_known_value_and_rejects_non_positive_input() {
    assert!((geometric_mean(&[2.0, 8.0]) - 4.0).abs() < 1e-12);
    assert!(geometric_mean(&[1.0, 0.0]).is_nan());
    assert!(geometric_mean(&[]).is_nan());
}

#[test]
fn flat_noisy_series_has_slope_indistinguishable_from_zero() {
    let points: Vec<(f64, f64)> = (0..40)
        .map(|step| {
            let position = f64::from(step);
            (position, 100.0 + if step % 2 == 0 { 1.0 } else { -1.0 })
        })
        .collect();
    assert!(regression_slope(&points).is_indistinguishable_from_zero());
}

#[test]
fn growing_series_has_significant_slope() {
    let points: Vec<(f64, f64)> = (0..40)
        .map(|step| {
            let position = f64::from(step);
            (
                position,
                100.0 + 3.0 * position + if step % 2 == 0 { 0.5 } else { -0.5 },
            )
        })
        .collect();
    let fitted = regression_slope(&points);
    assert!((fitted.slope - 3.0).abs() < 0.05);
    assert!(!fitted.is_indistinguishable_from_zero());
}

#[test]
fn degenerate_series_yield_no_verdict() {
    assert!(!regression_slope(&[(1.0, 1.0), (2.0, 2.0)]).is_indistinguishable_from_zero());
    assert!(
        !regression_slope(&[(1.0, 1.0), (1.0, 2.0), (1.0, 3.0)]).is_indistinguishable_from_zero()
    );
}
