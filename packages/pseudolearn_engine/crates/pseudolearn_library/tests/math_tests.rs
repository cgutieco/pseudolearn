use pseudolearn_library::{LibraryError, absolute, square_root};

#[test]
fn absolute_clears_only_the_sign_bit() {
    let values = [-0.0, -42.5, f64::from_bits(0xfff8_0000_0000_0042)];
    for value in values {
        assert_eq!(absolute(value).to_bits(), value.to_bits() & !(1_u64 << 63));
    }
}

#[test]
fn square_root_returns_finite_results() {
    assert_eq!(square_root(0.0), Ok(0.0));
    assert_eq!(square_root(4.0), Ok(2.0));
    assert_eq!(square_root(2.0), Ok(2.0_f64.sqrt()));
    assert_eq!(square_root(f64::from_bits(1)), Ok(f64::from_bits(1).sqrt()));
    assert_eq!(square_root(f64::MIN_POSITIVE), Ok(f64::MIN_POSITIVE.sqrt()));
    assert_eq!(square_root(f64::MAX), Ok(f64::MAX.sqrt()));
}

#[test]
fn square_root_preserves_negative_zero() {
    let negative_zero = f64::from_bits(1_u64 << 63);
    let result = square_root(negative_zero);
    assert_eq!(result.map(f64::to_bits), Ok(negative_zero.to_bits()));
}

#[test]
fn square_root_matches_binary64_rounding_for_seeded_values() {
    let mut state = 42_u64;
    for _ in 0..100_000 {
        state = state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        let bits = state & !(1_u64 << 63);
        let value = f64::from_bits(bits);
        if value.is_finite() {
            assert_eq!(
                square_root(value).map(f64::to_bits),
                Ok(value.sqrt().to_bits())
            );
        }
    }
}

#[test]
fn square_root_reports_invalid_inputs() {
    assert_eq!(square_root(-1.0), Err(LibraryError::NegativeSquareRoot));
    assert_eq!(
        square_root(f64::INFINITY),
        Err(LibraryError::NonFiniteInput)
    );
}
