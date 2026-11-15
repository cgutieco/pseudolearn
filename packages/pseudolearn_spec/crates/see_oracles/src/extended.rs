use crate::interval::{self, Interval};
use crate::mathematics::{self, Function};
use crate::rational::{self, Rational, integer};
use crate::transcendentals;
use num_traits::{Signed, Zero};

pub(crate) fn enclose(
    function: Function,
    value: &Rational,
    precision: i64,
) -> Result<Interval, String> {
    match function {
        Function::Tangent => {
            let (sine, cosine) = transcendentals::sine_cosine(value, precision)?;
            interval::multiply(&sine, &interval::reciprocal(&cosine)?)
        }
        Function::ArcSine | Function::ArcCosine => inverse(function, value, precision),
        Function::Logarithm2 | Function::Logarithm10 => {
            let base = if function == Function::Logarithm2 {
                2
            } else {
                10
            };
            interval::multiply(
                &transcendentals::logarithm(value, precision)?,
                &interval::reciprocal(&base_logarithm(base, precision)?)?,
            )
        }
        _ => Err("ORACLE-FUNCTION".to_owned()),
    }
}

std::thread_local! {
    static CACHED_DECIMAL_LOGARITHM: std::cell::RefCell<Option<(i64, Interval)>> = const { std::cell::RefCell::new(None) };
}

fn base_logarithm(base: i64, precision: i64) -> Result<Interval, String> {
    if base != 10 {
        return transcendentals::logarithm(&integer(base), precision);
    }
    if let Some(interval) = CACHED_DECIMAL_LOGARITHM.with(|cache| {
        cache
            .borrow()
            .as_ref()
            .filter(|(bits, _)| *bits == precision)
            .map(|(_, interval)| interval.clone())
    }) {
        return Ok(interval);
    }
    let interval = transcendentals::logarithm(&integer(base), precision)?;
    CACHED_DECIMAL_LOGARITHM
        .with(|cache| *cache.borrow_mut() = Some((precision, interval.clone())));
    Ok(interval)
}

fn inverse(function: Function, value: &Rational, precision: i64) -> Result<Interval, String> {
    if value.abs() > integer(1) {
        return Err("ORACLE-DOMAIN".to_owned());
    }
    let half_pi = interval::scale(&transcendentals::quarter_pi(precision)?, &integer(2))?;
    let sine = if value.abs() == integer(1) {
        interval::scale(&half_pi, &integer(if value.is_negative() { -1 } else { 1 }))?
    } else {
        let square = rational::multiply(value, value)?;
        let root = mathematics::enclose(
            Function::SquareRoot,
            &rational::subtract(&integer(1), &square)?,
            precision,
        )?;
        let ratio = interval::multiply(
            &interval::point(value.clone()),
            &interval::reciprocal(&root)?,
        )?;
        Interval {
            lower: transcendentals::arctangent(&ratio.lower, precision)?.lower,
            upper: transcendentals::arctangent(&ratio.upper, precision)?.upper,
        }
    };
    if function == Function::ArcCosine {
        interval::subtract(&half_pi, &sine)
    } else {
        Ok(sine)
    }
}

pub fn atan2(vertical: f64, horizontal: f64) -> Result<f64, String> {
    let ordinate = rational::exact(vertical)?;
    let abscissa = rational::exact(horizontal)?;
    if ordinate.is_zero() && !horizontal.is_sign_negative() {
        return Ok(vertical);
    }
    mathematics::refine(|precision| {
        let quarter = transcendentals::quarter_pi(precision)?;
        let angle = if abscissa.is_zero() {
            interval::scale(&quarter, &integer(if ordinate.is_zero() { 4 } else { 2 }))?
        } else {
            let ratio = rational::divide(&ordinate.abs(), &abscissa.abs())?;
            let angle = transcendentals::arctangent(&ratio, precision)?;
            if horizontal.is_sign_negative() {
                interval::subtract(&interval::scale(&quarter, &integer(4))?, &angle)?
            } else {
                angle
            }
        };
        interval::scale(
            &angle,
            &integer(if vertical.is_sign_negative() { -1 } else { 1 }),
        )
    })
}
