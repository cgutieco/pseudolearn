use super::{Integer, Interval};

fn interval(lower: i64, upper: i64) -> Interval {
    Interval {
        lower: Integer::from_i64(lower),
        upper: Integer::from_i64(upper),
    }
}

#[test]
fn multiplication_keeps_every_sign_combination_inside() {
    assert_eq!(
        interval(-2, 3).multiply(&interval(-5, 4), 0),
        interval(-15, 12)
    );
    assert_eq!(interval(2, 3).multiply(&interval(4, 5), 0), interval(8, 15));
    assert_eq!(
        interval(-3, -2).multiply(&interval(4, 5), 0),
        interval(-15, -8)
    );
}

#[test]
fn scaled_multiplication_rounds_outward() {
    assert_eq!(interval(3, 3).multiply(&interval(3, 3), 2), interval(2, 3));
}

#[test]
fn division_requires_a_positive_denominator() {
    assert_eq!(interval(1, 1).divide(&interval(0, 2), 4), None);
    assert_eq!(interval(1, 1).divide(&interval(-1, 2), 4), None);
    assert_eq!(
        interval(1, 1).divide(&interval(3, 3), 4),
        Some(interval(5, 6))
    );
}

#[test]
fn square_root_rounds_outward_and_rejects_negative_bounds() {
    assert_eq!(interval(2, 2).square_root(0), Some(interval(1, 2)));
    assert_eq!(interval(4, 9).square_root(0), Some(interval(2, 3)));
    assert_eq!(interval(-1, 4).square_root(0), None);
}

#[test]
fn widening_and_bounds() {
    assert_eq!(interval(0, 0).widen(2), interval(-2, 2));
    assert!(interval(-1, 1).is_within_units(1));
    assert!(!interval(-2, 1).is_within_units(1));
    assert_eq!(interval(-7, 3).negate(), interval(-3, 7));
}
