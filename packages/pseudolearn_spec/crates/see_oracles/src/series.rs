use crate::interval::{self, Interval};
use crate::rational::{self, Rational, arithmetic_error, integer};
use num_traits::{Signed, Zero};

pub(crate) fn arctangent(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let square = rational::multiply(argument, argument)?;
    let mut power = argument.clone();
    let mut sum = integer(0);
    let mut index = 0_i64;
    loop {
        let divisor = index
            .checked_mul(2)
            .and_then(|value| value.checked_add(1))
            .ok_or_else(arithmetic_error)?;
        let term = rational::divide(&power, &integer(divisor))?;
        let signed = if index & 1 == 0 {
            term.clone()
        } else {
            rational::subtract(&integer(0), &term)?
        };
        sum = rational::add(&sum, &signed)?;
        power = rational::multiply(&power, &square)?;
        index = index.checked_add(1).ok_or_else(arithmetic_error)?;
        let next_divisor = divisor.checked_add(2).ok_or_else(arithmetic_error)?;
        let remainder = rational::divide(&power.abs(), &integer(next_divisor))?;
        if remainder < *epsilon {
            return interval::around(sum, remainder);
        }
    }
}

pub(crate) fn exponential(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let precision = crate::dyadic::precision(epsilon)?;
    let argument = crate::dyadic::bound(argument, precision)?;
    let mut term = interval::point(integer(1));
    let mut sum = term.clone();
    let mut index = 0_i64;
    loop {
        index = index.checked_add(1).ok_or_else(arithmetic_error)?;
        let product = interval::multiply(&term, &argument)?;
        term = crate::dyadic::compress(
            &interval::scale(&product, &rational::divide(&integer(1), &integer(index))?)?,
            precision,
        )?;
        sum = crate::dyadic::compress(&interval::add(&sum, &term)?, precision)?;
        let remainder = rational::multiply(&term.upper.abs(), &integer(2))?;
        if remainder < *epsilon {
            return Ok(Interval {
                lower: sum.lower,
                upper: rational::add(&sum.upper, &remainder)?,
            });
        }
    }
}

pub(crate) fn logarithm(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let fraction = rational::divide(
        &rational::subtract(argument, &integer(1))?,
        &rational::add(argument, &integer(1))?,
    )?;
    let square = rational::multiply(&fraction, &fraction)?;
    let tail_scale = rational::divide(&integer(2), &rational::subtract(&integer(1), &square)?)?;
    let mut power = fraction;
    let mut sum = integer(0);
    let mut divisor = 1_i64;
    loop {
        sum = rational::add(&sum, &rational::divide(&power, &integer(divisor))?)?;
        power = rational::multiply(&power, &square)?;
        divisor = divisor.checked_add(2).ok_or_else(arithmetic_error)?;
        let remainder = rational::multiply(
            &tail_scale,
            &rational::divide(&power.abs(), &integer(divisor))?,
        )?;
        if remainder < *epsilon {
            return interval::around(rational::multiply(&sum, &integer(2))?, remainder);
        }
    }
}

pub(crate) fn sine(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    alternating(argument.clone(), argument, 1, epsilon)
}

pub(crate) fn cosine(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    alternating(integer(1), argument, 0, epsilon)
}

fn alternating(
    initial: Rational,
    argument: &Rational,
    index: i64,
    epsilon: &Rational,
) -> Result<Interval, String> {
    let negative_square =
        rational::subtract(&integer(0), &rational::multiply(argument, argument)?)?;
    let mut term = initial;
    let mut sum = integer(0);
    let mut index = index;
    loop {
        sum = rational::add(&sum, &term)?;
        let first = index.checked_add(1).ok_or_else(arithmetic_error)?;
        index = index.checked_add(2).ok_or_else(arithmetic_error)?;
        let denominator = first.checked_mul(index).ok_or_else(arithmetic_error)?;
        term = rational::divide(
            &rational::multiply(&term, &negative_square)?,
            &integer(denominator),
        )?;
        if term.is_zero() || term.abs() < *epsilon {
            return interval::around(sum, term.abs());
        }
    }
}
