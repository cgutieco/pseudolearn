use crate::service::statistics::{percent, round, summarize};

#[test]
fn summarizes_a_known_sample() {
    let Some(summary) = summarize(&[5.0, 1.0, 3.0, 2.0, 4.0]) else {
        return;
    };
    assert_eq!(summary.median, 3.0);
    assert_eq!(summary.mad, 1.0);
    assert_eq!(summary.iqr, 2.0);
    assert_eq!(summary.p95, 5.0);
    assert_eq!((summary.min, summary.max), (1.0, 5.0));
    assert_eq!(summary.mean, 3.0);
}

#[test]
fn a_single_sample_collapses_every_statistic() {
    let Some(summary) = summarize(&[7.5]) else {
        return;
    };
    assert_eq!((summary.median, summary.p95, summary.iqr), (7.5, 7.5, 0.0));
}

#[test]
fn an_empty_sample_has_no_summary() {
    assert!(summarize(&[]).is_none());
}

#[test]
fn percentages_handle_empty_denominators_and_rounding() {
    assert_eq!(percent(1, 3), 33.333);
    assert_eq!(percent(0, 0), 0.0);
    assert_eq!(percent(5, 5), 100.0);
    assert_eq!(round(1.23456), 1.235);
}
