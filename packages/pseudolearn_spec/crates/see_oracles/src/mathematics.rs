use crate::interval::{self, Interval};
use crate::rational::{self, Rational, arithmetic_error, integer};
use crate::transcendentals;
use num_traits::{Signed, ToPrimitive, Zero};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Function {
    SquareRoot,
    Logarithm,
    Exponential,
    Sine,
    Cosine,
    Arctangent,
}

pub fn rounded(function: Function, argument: f64) -> Result<f64, String> {
    let exact = rational::exact(argument)?;
    if argument == 0.0
        && matches!(
            function,
            Function::SquareRoot | Function::Sine | Function::Arctangent
        )
    {
        return Ok(argument);
    }
    if function == Function::Exponential && argument > 1024.0 {
        return Ok(f64::INFINITY);
    }
    refine(|precision| enclose(function, &exact, precision))
}

pub fn power(base: f64, exponent: f64) -> Result<f64, String> {
    let negative_zero = base.to_bits() == (-0.0_f64).to_bits();
    let base = rational::exact(base)?;
    let exponent = rational::exact(exponent)?;
    if exponent.is_zero() {
        return Ok(1.0);
    }
    if base.is_zero() {
        return if exponent > integer(0) {
            Ok(
                if negative_zero && exponent.is_integer() && exponent.to_integer().bit(0) {
                    -0.0
                } else {
                    0.0
                },
            )
        } else {
            Err("ORACLE-DOMAIN".to_owned())
        };
    }
    if base.is_negative() && !exponent.is_integer() {
        return Err("ORACLE-DOMAIN".to_owned());
    }
    if let Some(exact) = crate::exact_power::dyadic_power(&base.abs(), &exponent)? {
        let negative = base.is_negative() && exponent.is_integer() && exponent.to_integer().bit(0);
        return Ok(if negative { -exact } else { exact });
    }
    if let Some(integer) = exponent.to_integer().to_i32()
        && exponent.is_integer()
        && integer.unsigned_abs() <= 4096
    {
        return crate::rounding::round_binary64(&base.pow(integer));
    }
    let negative = base.is_negative() && exponent.to_integer().bit(0);
    let result = refine(|precision| power_interval(&base.abs(), &exponent, precision))?;
    Ok(if negative { -result } else { result })
}

pub fn enclose(
    function: Function,
    argument: &Rational,
    precision: i64,
) -> Result<Interval, String> {
    if precision < 8 {
        return Err("ORACLE-PRECISION".to_owned());
    }
    match function {
        Function::SquareRoot => square_root(argument, precision),
        Function::Logarithm => transcendentals::logarithm(argument, precision),
        Function::Exponential => transcendentals::exponential(argument, precision),
        Function::Sine => Ok(transcendentals::sine_cosine(argument, precision)?.0),
        Function::Cosine => Ok(transcendentals::sine_cosine(argument, precision)?.1),
        Function::Arctangent => transcendentals::arctangent(argument, precision),
    }
}

fn refine(mut enclosure: impl FnMut(i64) -> Result<Interval, String>) -> Result<f64, String> {
    let mut precision = 96_i64;
    loop {
        let interval = match enclosure(precision) {
            Ok(interval) => interval,
            Err(error) if error == "ORACLE-NON-FINITE-RESULT" => return Ok(f64::INFINITY),
            Err(error) => return Err(error),
        };
        let lower = crate::rounding::round_binary64(&interval.lower)?;
        let upper = crate::rounding::round_binary64(&interval.upper)?;
        if lower.to_bits() == upper.to_bits() {
            return Ok(lower);
        }
        precision = precision.checked_mul(2).ok_or_else(arithmetic_error)?;
    }
}

fn power_interval(
    base: &Rational,
    exponent: &Rational,
    precision: i64,
) -> Result<Interval, String> {
    if base == &integer(1) || exponent.is_zero() {
        return Ok(interval::point(integer(1)));
    }
    let numerator = i64::try_from(exponent.numer().bits()).map_err(|_| arithmetic_error())?;
    let denominator = i64::try_from(exponent.denom().bits()).map_err(|_| arithmetic_error())?;
    let magnitude = numerator
        .checked_sub(denominator)
        .ok_or_else(arithmetic_error)?
        .max(0);
    let guard = precision
        .checked_add(magnitude)
        .and_then(|value| value.checked_add(32))
        .ok_or_else(arithmetic_error)?;
    let logarithm = transcendentals::logarithm(base, guard)?;
    let product = interval::scale(&logarithm, exponent)?;
    let lower = transcendentals::exponential(&product.lower, precision)?;
    let upper = transcendentals::exponential(&product.upper, precision)?;
    Ok(Interval {
        lower: lower.lower,
        upper: upper.upper,
    })
}

fn square_root(argument: &Rational, precision: i64) -> Result<Interval, String> {
    if argument.is_negative() {
        return Err("ORACLE-DOMAIN".to_owned());
    }
    let doubled = precision.checked_mul(2).ok_or_else(arithmetic_error)?;
    let scaled = rational::multiply(argument, &rational::power_two(doubled)?)?;
    let floor = scaled.to_integer().sqrt();
    let lower = rational::multiply(
        &Rational::from_integer(floor),
        &rational::epsilon(precision)?,
    )?;
    if rational::multiply(&lower, &lower)? == *argument {
        return Ok(interval::point(lower));
    }
    let upper = rational::add(&lower, &rational::epsilon(precision)?)?;
    Ok(Interval { lower, upper })
}
