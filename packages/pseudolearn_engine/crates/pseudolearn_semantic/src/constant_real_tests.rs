use crate::constant_real::integer_to_real;

#[test]
fn matches_exact_conversion_for_small_integers() {
    for value in [-70_000_i32, -1, 0, 1, 2, 255, 65_536, 2_000_000_000] {
        assert_eq!(
            integer_to_real(i64::from(value)).to_bits(),
            f64::from(value).to_bits()
        );
    }
}

#[test]
fn rounds_ties_to_even_beyond_the_significand() {
    assert_eq!(
        integer_to_real(9_007_199_254_740_993),
        9_007_199_254_740_992.0
    );
    assert_eq!(
        integer_to_real(9_007_199_254_740_995),
        9_007_199_254_740_996.0
    );
}

#[test]
fn handles_the_extreme_integers() {
    assert_eq!(integer_to_real(i64::MAX), 9_223_372_036_854_775_808.0);
    assert_eq!(integer_to_real(i64::MIN), -9_223_372_036_854_775_808.0);
}
