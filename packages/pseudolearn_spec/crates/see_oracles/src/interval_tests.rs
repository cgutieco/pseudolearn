use super::{Interval, multiply, scale};
use crate::rational::integer;

#[test]
fn interval_products_cover_all_sign_pairs_and_degenerate_endpoints() -> Result<(), String> {
    for left in [(-3_i64, -1_i64), (-2, 2), (1, 3), (0, 0)] {
        for right in [(-3_i64, -1_i64), (-2, 2), (1, 3), (0, 0)] {
            let products = [left.0, left.1]
                .into_iter()
                .flat_map(|left| {
                    [right.0, right.1]
                        .into_iter()
                        .map(move |right| left.checked_mul(right).unwrap_or_default())
                })
                .collect::<Vec<_>>();
            let actual = multiply(
                &Interval {
                    lower: integer(left.0),
                    upper: integer(left.1),
                },
                &Interval {
                    lower: integer(right.0),
                    upper: integer(right.1),
                },
            )?;
            assert_eq!(
                Some(&actual.lower),
                products.iter().min().map(|value| integer(*value)).as_ref()
            );
            assert_eq!(
                Some(&actual.upper),
                products.iter().max().map(|value| integer(*value)).as_ref()
            );
        }
    }
    Ok(())
}

#[test]
fn scaling_reverses_negative_endpoints_and_preserves_zero() -> Result<(), String> {
    let value = Interval {
        lower: integer(-2),
        upper: integer(3),
    };
    assert_eq!(
        scale(&value, &integer(-2))?,
        Interval {
            lower: integer(-6),
            upper: integer(4)
        }
    );
    assert_eq!(
        scale(&value, &integer(0))?,
        Interval {
            lower: integer(0),
            upper: integer(0)
        }
    );
    Ok(())
}
