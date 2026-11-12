use super::statistics::{Sampler, geometric_mean, mean, median, percentile};

#[test]
fn mean_and_geometric_mean_match_known_values() {
    assert!((mean(&[1.0, 2.0, 3.0]) - 2.0).abs() < 1e-12);
    assert!((geometric_mean(&[2.0, 8.0]) - 4.0).abs() < 1e-12);
}

#[test]
fn empty_and_non_positive_inputs_have_no_result() {
    assert!(mean(&[]).is_nan());
    assert!(geometric_mean(&[]).is_nan());
    assert!(geometric_mean(&[1.0, 0.0]).is_nan());
    assert!(percentile(&[], 0.5).is_nan());
}

#[test]
fn percentile_uses_nearest_rank() {
    let values = [5.0, 1.0, 4.0, 2.0, 3.0];
    assert_eq!(percentile(&values, 0.95), 5.0);
    assert_eq!(percentile(&values, 0.2), 1.0);
    assert_eq!(median(&values), 3.0);
}

#[test]
fn resampling_is_deterministic_and_draws_only_from_the_input() {
    let values = [1.0, 2.0, 3.0, 4.0];
    let first = Sampler::seeded(42).resample(&values);
    let second = Sampler::seeded(42).resample(&values);
    assert_eq!(first, second);
    assert_eq!(first.len(), values.len());
    assert!(first.iter().all(|value| values.contains(value)));
}

#[test]
fn resampling_an_empty_input_yields_nothing() {
    assert!(Sampler::seeded(1).resample(&[]).is_empty());
}
