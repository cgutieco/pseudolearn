use crate::interval::{self, Interval};
use crate::rational::{self, Rational, arithmetic_error, integer};
use num_traits::Signed;

pub(crate) fn arctangent(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    let square = rational::multiply(argument, argument)?;
    let cube = rational::multiply(argument, &square)?;
    let radius = rational::divide(&cube.abs(), &integer(3))?;
    if radius < *epsilon {
        return Ok(Interval {
            lower: rational::subtract(argument, &radius)?,
            upper: rational::add(argument, &radius)?,
        });
    }
    crate::bounded_series::arctangent(argument, epsilon)
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
    crate::bounded_series::logarithm(argument, epsilon)
}

pub(crate) fn sine(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    crate::bounded_series::alternating(argument.clone(), argument, 1, epsilon)
}

pub(crate) fn cosine(argument: &Rational, epsilon: &Rational) -> Result<Interval, String> {
    crate::bounded_series::alternating(integer(1), argument, 0, epsilon)
}
