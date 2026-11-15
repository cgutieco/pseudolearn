use crate::interval::Interval;
use crate::rational::{self, Rational, arithmetic_error};
use num_bigint::BigInt;
use num_traits::One;

pub(crate) fn bound(value: &Rational, precision: i64) -> Result<Interval, String> {
    let scale = rational::power_two(precision)?;
    let scaled = rational::multiply(value, &scale)?;
    let floor = scaled.floor().to_integer();
    let lower = rational::divide(&Rational::from_integer(floor.clone()), &scale)?;
    let successor = floor
        .checked_add(&BigInt::one())
        .ok_or_else(arithmetic_error)?;
    let upper = if scaled.is_integer() {
        lower.clone()
    } else {
        rational::divide(&Rational::from_integer(successor), &scale)?
    };
    Ok(Interval { lower, upper })
}

pub(crate) fn compress(value: &Interval, precision: i64) -> Result<Interval, String> {
    Ok(Interval {
        lower: bound(&value.lower, precision)?.lower,
        upper: bound(&value.upper, precision)?.upper,
    })
}

pub(crate) fn precision(epsilon: &Rational) -> Result<i64, String> {
    let bits = i64::try_from(epsilon.denom().bits()).map_err(|_| arithmetic_error())?;
    bits.checked_add(32).ok_or_else(arithmetic_error)
}
