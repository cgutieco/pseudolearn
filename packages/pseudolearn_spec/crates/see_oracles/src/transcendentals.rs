use crate::interval::{self, Interval};
use crate::rational::{self, Rational, arithmetic_error, integer};
use crate::series;
use num_integer::Integer;
use num_traits::{CheckedMul, Signed, ToPrimitive};

pub(crate) fn exponential(argument: &Rational, precision: i64) -> Result<Interval, String> {
    if argument > &integer(1024) {
        return Err("ORACLE-NON-FINITE-RESULT".to_owned());
    }
    if argument < &integer(-2048) {
        return Ok(Interval {
            lower: integer(0),
            upper: rational::power_two(-2048)?,
        });
    }
    let mut reduced = argument.abs();
    let mut halvings = 0_i64;
    let threshold = rational::divide(&integer(1), &integer(8))?;
    while reduced > threshold {
        reduced = rational::divide(&reduced, &integer(2))?;
        halvings = halvings.checked_add(1).ok_or_else(arithmetic_error)?;
    }
    let guard = exponential_precision(argument, precision, halvings)?;
    let mut result = series::exponential(&reduced, &rational::epsilon(guard)?)?;
    for _ in 0..halvings {
        result = crate::dyadic::compress(&interval::multiply(&result, &result)?, guard)?;
    }
    if argument.is_negative() {
        interval::reciprocal(&result)
    } else {
        Ok(result)
    }
}

pub(crate) fn logarithm(argument: &Rational, precision: i64) -> Result<Interval, String> {
    if argument <= &integer(0) {
        return Err("ORACLE-DOMAIN".to_owned());
    }
    let numerator = i64::try_from(argument.numer().bits()).map_err(|_| arithmetic_error())?;
    let denominator = i64::try_from(argument.denom().bits()).map_err(|_| arithmetic_error())?;
    let mut exponent = numerator
        .checked_sub(denominator)
        .ok_or_else(arithmetic_error)?;
    if argument < &rational::power_two(exponent)? {
        exponent = exponent.checked_sub(1).ok_or_else(arithmetic_error)?;
    }
    let reduced = rational::divide(argument, &rational::power_two(exponent)?)?;
    let guard = precision.checked_add(32).ok_or_else(arithmetic_error)?;
    let epsilon = rational::epsilon(guard)?;
    let logarithm = series::logarithm(&reduced, &epsilon)?;
    let binary_scale = interval::scale(
        &series::logarithm(&integer(2), &epsilon)?,
        &integer(exponent),
    )?;
    interval::add(&logarithm, &binary_scale)
}

pub(crate) fn quarter_pi(precision: i64) -> Result<Interval, String> {
    let epsilon = rational::epsilon(precision.checked_add(16).ok_or_else(arithmetic_error)?)?;
    let first = series::arctangent(&rational::divide(&integer(1), &integer(5))?, &epsilon)?;
    let second = series::arctangent(&rational::divide(&integer(1), &integer(239))?, &epsilon)?;
    interval::subtract(&interval::scale(&first, &integer(4))?, &second)
}

pub(crate) fn arctangent(argument: &Rational, precision: i64) -> Result<Interval, String> {
    if argument.is_negative() {
        return interval::scale(&arctangent(&argument.abs(), precision)?, &integer(-1));
    }
    let constant = quarter_pi(precision)?;
    if argument > &integer(1) {
        let inverse = rational::divide(&integer(1), argument)?;
        return interval::subtract(
            &interval::scale(&constant, &integer(2))?,
            &arctangent(&inverse, precision)?,
        );
    }
    let epsilon = rational::epsilon(precision.checked_add(16).ok_or_else(arithmetic_error)?)?;
    if argument > &rational::divide(&integer(1), &integer(2))? {
        let transformed = rational::divide(
            &rational::subtract(argument, &integer(1))?,
            &rational::add(argument, &integer(1))?,
        )?;
        return interval::add(&constant, &series::arctangent(&transformed, &epsilon)?);
    }
    series::arctangent(argument, &epsilon)
}

pub(crate) fn sine_cosine(
    argument: &Rational,
    precision: i64,
) -> Result<(Interval, Interval), String> {
    let (center, radius, quadrant) = reduce_angle(argument, precision)?;
    let epsilon = rational::epsilon(precision.checked_add(16).ok_or_else(arithmetic_error)?)?;
    let sine = widen(series::sine(&center, &epsilon)?, &radius)?;
    let cosine = widen(series::cosine(&center, &epsilon)?, &radius)?;
    rotate(sine, cosine, quadrant)
}

fn reduce_angle(argument: &Rational, precision: i64) -> Result<(Rational, Rational, i64), String> {
    let magnitude = i64::try_from(argument.numer().bits()).map_err(|_| arithmetic_error())?;
    let denominator = i64::try_from(argument.denom().bits()).map_err(|_| arithmetic_error())?;
    let exponent = magnitude
        .checked_sub(denominator)
        .ok_or_else(arithmetic_error)?
        .max(0);
    let guard = precision
        .checked_add(exponent)
        .and_then(|value| value.checked_add(32))
        .ok_or_else(arithmetic_error)?;
    let half_pi = interval::scale(&quarter_pi(guard)?, &integer(2))?;
    let quotient = rational::divide(argument, &interval::center(&half_pi)?)?;
    let nearest = rational::add(&quotient, &rational::divide(&integer(1), &integer(2))?)?
        .floor()
        .to_integer();
    let multiple = Rational::from_integer(nearest.clone());
    let reduced = interval::subtract(
        &interval::point(argument.clone()),
        &interval::scale(&half_pi, &multiple)?,
    )?;
    let center_bound = crate::dyadic::bound(&interval::center(&reduced)?, guard)?;
    let radius = rational::add(
        &interval::radius(&reduced)?,
        &interval::radius(&center_bound)?
            .checked_mul(&integer(2))
            .ok_or_else(arithmetic_error)?,
    )?;
    let quadrant = nearest
        .mod_floor(&num_bigint::BigInt::from(4))
        .to_i64()
        .ok_or_else(arithmetic_error)?;
    Ok((center_bound.lower, radius, quadrant))
}

fn widen(value: Interval, radius: &Rational) -> Result<Interval, String> {
    Ok(Interval {
        lower: rational::subtract(&value.lower, radius)?,
        upper: rational::add(&value.upper, radius)?,
    })
}

fn rotate(sine: Interval, cosine: Interval, quadrant: i64) -> Result<(Interval, Interval), String> {
    match quadrant {
        0 => Ok((sine, cosine)),
        1 => Ok((cosine, interval::scale(&sine, &integer(-1))?)),
        2 => Ok((
            interval::scale(&sine, &integer(-1))?,
            interval::scale(&cosine, &integer(-1))?,
        )),
        3 => Ok((interval::scale(&cosine, &integer(-1))?, sine)),
        _ => Err(arithmetic_error()),
    }
}

fn exponential_precision(
    argument: &Rational,
    precision: i64,
    halvings: i64,
) -> Result<i64, String> {
    let magnitude = argument
        .abs()
        .ceil()
        .to_integer()
        .to_i64()
        .ok_or_else(arithmetic_error)?;
    let amplification = magnitude
        .checked_mul(2)
        .and_then(|value| value.checked_add(32))
        .ok_or_else(arithmetic_error)?;
    let guard = precision
        .checked_add(halvings)
        .and_then(|value| value.checked_add(amplification))
        .ok_or_else(arithmetic_error)?;
    Ok(guard)
}
