use crate::pg_http_growth::linear_fit;

#[test]
fn reports_a_linear_fit_for_distinct_sizes() {
    let points = [(0, 100.0), (1024, 1124.0), (65_536, 65_636.0)];
    let fit = linear_fit(&points);
    assert_eq!(
        fit.and_then(|value| value.get("r_squared")?.as_f64()),
        Some(1.0)
    );
}

#[test]
fn rejects_empty_and_equal_size_inputs() {
    assert!(linear_fit(&[]).is_none());
    assert!(linear_fit(&[(1024, 100.0), (1024, 200.0)]).is_none());
}
