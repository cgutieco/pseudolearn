use crate::dyadic;
use crate::interval::{self, Interval};
use crate::rational::{self, Rational, arithmetic_error, integer};
use num_traits::Signed;

pub(crate) fn arctangent(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let precision = dyadic::precision(epsilon)?;
    let mut power = dyadic::bound(argument, precision)?;
    let square = dyadic::compress(&interval::multiply(&power, &power)?, precision)?;
    let mut sum = interval::point(integer(0));
    let mut index = 0_i64;
    loop {
        let divisor = index
            .checked_mul(2)
            .and_then(|value| value.checked_add(1))
            .ok_or_else(arithmetic_error)?;
        let factor = rational::divide(
            &integer(if index & 1 == 0 { 1 } else { -1 }),
            &integer(divisor),
        )?;
        sum = dyadic::compress(
            &interval::add(&sum, &interval::scale(&power, &factor)?)?,
            precision,
        )?;
        power = dyadic::compress(&interval::multiply(&power, &square)?, precision)?;
        index = index.checked_add(1).ok_or_else(arithmetic_error)?;
        let next = divisor.checked_add(2).ok_or_else(arithmetic_error)?;
        let remainder = rational::divide(&magnitude(&power), &integer(next))?;
        if remainder < *epsilon {
            return widen(sum, remainder);
        }
    }
}

pub(crate) fn logarithm(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let fraction = rational::divide(
        &rational::subtract(argument, &integer(1))?,
        &rational::add(argument, &integer(1))?,
    )?;
    let precision = dyadic::precision(epsilon)?;
    let mut power = dyadic::bound(&fraction, precision)?;
    let square = dyadic::compress(&interval::multiply(&power, &power)?, precision)?;
    let scale = rational::divide(
        &integer(2),
        &rational::subtract(&integer(1), &square.upper)?,
    )?;
    let mut sum = interval::point(integer(0));
    let mut divisor = 1_i64;
    loop {
        let term = interval::scale(&power, &rational::divide(&integer(1), &integer(divisor))?)?;
        sum = dyadic::compress(&interval::add(&sum, &term)?, precision)?;
        power = dyadic::compress(&interval::multiply(&power, &square)?, precision)?;
        divisor = divisor.checked_add(2).ok_or_else(arithmetic_error)?;
        let remainder = rational::multiply(
            &scale,
            &rational::divide(&magnitude(&power), &integer(divisor))?,
        )?;
        if remainder < *epsilon {
            return widen(interval::scale(&sum, &integer(2))?, remainder);
        }
    }
}

pub(crate) fn alternating(
    initial: Rational,
    argument: &Rational,
    index: i64,
    epsilon: &Rational,
) -> Result<Interval, String> {
    let precision = dyadic::precision(epsilon)?;
    let argument = dyadic::bound(argument, precision)?;
    let negative_square =
        interval::scale(&interval::multiply(&argument, &argument)?, &integer(-1))?;
    let mut term = dyadic::bound(&initial, precision)?;
    let mut sum = interval::point(integer(0));
    let mut index = index;
    loop {
        sum = dyadic::compress(&interval::add(&sum, &term)?, precision)?;
        let first = index.checked_add(1).ok_or_else(arithmetic_error)?;
        index = index.checked_add(2).ok_or_else(arithmetic_error)?;
        let denominator = first.checked_mul(index).ok_or_else(arithmetic_error)?;
        let product = interval::multiply(&term, &negative_square)?;
        term = dyadic::compress(
            &interval::scale(
                &product,
                &rational::divide(&integer(1), &integer(denominator))?,
            )?,
            precision,
        )?;
        let remainder = magnitude(&term);
        if remainder < *epsilon {
            return widen(sum, remainder);
        }
    }
}

fn magnitude(value: &Interval) -> Rational {
    value.lower.abs().max(value.upper.abs())
}

fn widen(value: Interval, radius: Rational) -> Result<Interval, String> {
    Ok(Interval {
        lower: rational::subtract(&value.lower, &radius)?,
        upper: rational::add(&value.upper, &radius)?,
    })
}
