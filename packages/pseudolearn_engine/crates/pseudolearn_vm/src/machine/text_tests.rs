use super::finite_real;

#[test]
fn finite_real_preserves_finite_values() {
    for value in [0.0, -0.0, f64::MIN_POSITIVE, f64::MAX] {
        assert_eq!(finite_real(value).map(f64::to_bits), Ok(value.to_bits()));
    }
}

#[test]
fn finite_real_rejects_non_finite_values() {
    for value in [f64::NAN, f64::INFINITY, f64::NEG_INFINITY] {
        assert_eq!(finite_real(value), Err("nonFiniteRealResult"));
    }
}
