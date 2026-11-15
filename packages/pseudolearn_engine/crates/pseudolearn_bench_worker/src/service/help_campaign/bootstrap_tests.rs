use crate::service::help_campaign::bootstrap::{
    change_points, confidence_interval, mean, mean_of_means, percentile, pooled_percentile,
};
use crate::service::help_campaign::digest::digest_text;

#[test]
fn percentile_uses_the_nearest_rank_and_rejects_empty_input() {
    let values = [5.0, 1.0, 3.0, 2.0, 4.0];
    assert_eq!(percentile(&values, 50), Some(3.0));
    assert_eq!(percentile(&values, 95), Some(5.0));
    assert_eq!(percentile(&[], 95), None);
    assert_eq!(mean(&[]), None);
}

#[test]
fn the_interval_is_reproducible_and_ordered() {
    let groups = vec![
        vec![1.0, 2.0, 3.0],
        vec![2.0, 3.0, 4.0],
        vec![1.5, 2.5, 3.5],
    ];
    let first = confidence_interval(&groups, 42, mean_of_means);
    let second = confidence_interval(&groups, 42, mean_of_means);
    assert_eq!(first, second);
    let (low, high) = first.unwrap_or((1.0, 0.0));
    assert!(low <= high);
    assert!(confidence_interval(&[], 42, mean_of_means).is_none());
}

#[test]
fn a_different_seed_may_move_the_interval_but_not_break_it() {
    let groups = vec![
        vec![1.0, 9.0],
        vec![2.0, 8.0],
        vec![3.0, 7.0],
        vec![4.0, 6.0],
    ];
    let interval = confidence_interval(&groups, 7, |resample| pooled_percentile(resample, 95));
    assert!(interval.is_some_and(|(low, high)| low <= high));
}

#[test]
fn a_step_in_the_series_is_a_change_point_candidate() {
    let mut samples = vec![1.0; 12];
    samples.extend(vec![2.0; 12]);
    assert!(!change_points(&samples).is_empty());
}

#[test]
fn flat_noisy_and_short_series_have_no_candidates() {
    assert!(change_points(&[1.0; 30]).is_empty());
    assert!(
        change_points(&[1.0, 5.0, 1.0, 5.0, 1.0, 5.0, 1.0, 5.0, 1.0, 5.0, 1.0, 5.0]).is_empty()
    );
    assert!(change_points(&[1.0, 9.0, 1.0]).is_empty());
}

#[test]
fn the_digest_changes_with_any_byte() {
    assert_eq!(digest_text("abc"), digest_text("abc"));
    assert_ne!(digest_text("abc"), digest_text("abd"));
    assert_ne!(digest_text(""), digest_text(" "));
}
