use super::{Integer, Natural};

fn integer(value: i64) -> Integer {
    Integer::from_i64(value)
}

#[test]
fn negative_zero_is_normalized() {
    assert_eq!(Integer::new(true, Natural::zero()), integer(0));
    assert!(!integer(0).negate().is_negative());
}

#[test]
fn signed_addition_and_subtraction() {
    assert_eq!(integer(5).add(&integer(-8)), integer(-3));
    assert_eq!(integer(-5).subtract(&integer(-8)), integer(3));
    assert_eq!(integer(-5).multiply(&integer(-3)), integer(15));
}

#[test]
fn directed_shifts_round_toward_their_infinities() {
    assert_eq!(integer(-5).floor_shift_right(1), integer(-3));
    assert_eq!(integer(-5).ceiling_shift_right(1), integer(-2));
    assert_eq!(integer(5).floor_shift_right(1), integer(2));
    assert_eq!(integer(5).ceiling_shift_right(1), integer(3));
    assert_eq!(integer(4).ceiling_shift_right(1), integer(2));
}

#[test]
fn directed_divisions_round_toward_their_infinities() {
    let three = Natural::from_u64(3);
    assert_eq!(integer(-7).floor_divide(&three), Some(integer(-3)));
    assert_eq!(integer(-7).ceiling_divide(&three), Some(integer(-2)));
    assert_eq!(integer(7).ceiling_divide(&three), Some(integer(3)));
    assert_eq!(integer(6).ceiling_divide(&three), Some(integer(2)));
    assert_eq!(integer(1).floor_divide(&Natural::zero()), None);
}

#[test]
fn ordering_respects_sign() {
    assert!(integer(-10) < integer(-2));
    assert!(integer(-1) < integer(0));
    assert!(integer(3) > integer(2));
}
