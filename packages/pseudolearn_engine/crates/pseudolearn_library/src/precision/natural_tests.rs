use super::natural::Natural;

fn natural(value: u128) -> Natural {
    let high = u64::try_from(value >> 64).unwrap_or(0);
    let low = u64::try_from(value & u128::from(u64::MAX)).unwrap_or(0);
    Natural::from_u64(high)
        .shift_left(64)
        .add(&Natural::from_u64(low))
}

#[test]
fn zero_has_no_bits() {
    assert!(Natural::zero().is_zero());
    assert_eq!(Natural::zero().bit_length(), 0);
    assert_eq!(Natural::from_u64(0), Natural::zero());
}

#[test]
fn addition_carries_across_limbs() {
    let sum = Natural::from_u64(u64::MAX).add(&Natural::from_u64(1));
    assert_eq!(sum, Natural::power_of_two(64));
    assert_eq!(sum.bit_length(), 65);
}

#[test]
fn subtraction_borrows_and_rejects_negative_results() {
    let difference = Natural::power_of_two(64).subtract(&Natural::from_u64(1));
    assert_eq!(difference, Some(Natural::from_u64(u64::MAX)));
    assert_eq!(Natural::from_u64(1).subtract(&Natural::from_u64(2)), None);
}

#[test]
fn multiplication_matches_wide_arithmetic() {
    let left = 0xFFFF_FFFF_FFFF_FFFF_u128;
    let right = 0x1234_5678_9ABC_DEF0_u128;
    assert_eq!(
        natural(left).multiply(&natural(right)),
        natural(left.wrapping_mul(right))
    );
    assert!(natural(left).multiply(&Natural::zero()).is_zero());
}

#[test]
fn shifts_are_inverse_for_whole_and_partial_limbs() {
    let value = natural(0xDEAD_BEEF_0123_4567_89AB_u128);
    for bits in [0, 1, 63, 64, 65, 130] {
        assert_eq!(value.shift_left(bits).shift_right(bits), value);
    }
    assert!(value.shift_right(200).is_zero());
}

#[test]
fn bits_below_detect_discarded_ones() {
    let value = Natural::from_u64(0b1010_0000);
    assert!(!value.has_bits_below(5));
    assert!(value.has_bits_below(6));
    assert!(value.bit(7));
    assert!(!value.bit(6));
    assert!(!value.bit(1000));
}

#[test]
fn small_division_returns_quotient_and_remainder() {
    let value = natural(1_000_000_000_000_000_000_007_u128);
    assert_eq!(
        value.divide_small(10),
        Some((natural(100_000_000_000_000_000_000_u128), 7))
    );
    assert_eq!(value.divide_small(0), None);
    let wide = value.divide_small(1_u64 << 40);
    assert_eq!(
        wide.map(|(quotient, remainder)| quotient
            .shift_left(40)
            .add(&Natural::from_u64(remainder))),
        Some(value)
    );
}

#[test]
fn increment_carries_into_a_new_limb() {
    assert_eq!(
        Natural::from_u64(u64::MAX).increment(),
        Natural::power_of_two(64)
    );
    assert_eq!(Natural::zero().increment(), Natural::from_u64(1));
}

#[test]
fn power_by_squaring() {
    assert_eq!(Natural::from_u64(3).power(5), Natural::from_u64(243));
    assert_eq!(Natural::from_u64(7).power(0), Natural::from_u64(1));
    assert_eq!(Natural::from_u64(2).power(130), Natural::power_of_two(130));
}
