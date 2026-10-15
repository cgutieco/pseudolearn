use crate::rational::{self, Rational, integer};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Interval {
    pub lower: Rational,
    pub upper: Rational,
}

pub(crate) fn point(value: Rational) -> Interval {
    Interval {
        lower: value.clone(),
        upper: value,
    }
}

pub(crate) fn around(center: Rational, radius: Rational) -> Result<Interval, String> {
    Ok(Interval {
        lower: rational::subtract(&center, &radius)?,
        upper: rational::add(&center, &radius)?,
    })
}

pub(crate) fn add(left: &Interval, right: &Interval) -> Result<Interval, String> {
    Ok(Interval {
        lower: rational::add(&left.lower, &right.lower)?,
        upper: rational::add(&left.upper, &right.upper)?,
    })
}

pub(crate) fn subtract(left: &Interval, right: &Interval) -> Result<Interval, String> {
    Ok(Interval {
        lower: rational::subtract(&left.lower, &right.upper)?,
        upper: rational::subtract(&left.upper, &right.lower)?,
    })
}

pub(crate) fn multiply(left: &Interval, right: &Interval) -> Result<Interval, String> {
    let products = [
        rational::multiply(&left.lower, &right.lower)?,
        rational::multiply(&left.lower, &right.upper)?,
        rational::multiply(&left.upper, &right.lower)?,
        rational::multiply(&left.upper, &right.upper)?,
    ];
    Ok(Interval {
        lower: products
            .iter()
            .min()
            .ok_or("ORACLE-EMPTY-INTERVAL")?
            .clone(),
        upper: products
            .iter()
            .max()
            .ok_or("ORACLE-EMPTY-INTERVAL")?
            .clone(),
    })
}

pub(crate) fn reciprocal(value: &Interval) -> Result<Interval, String> {
    if value.lower <= integer(0) && value.upper >= integer(0) {
        return Err("ORACLE-INTERVAL-CONTAINS-ZERO".to_owned());
    }
    Ok(Interval {
        lower: rational::divide(&integer(1), &value.upper)?,
        upper: rational::divide(&integer(1), &value.lower)?,
    })
}

pub(crate) fn scale(value: &Interval, factor: &Rational) -> Result<Interval, String> {
    multiply(value, &point(factor.clone()))
}

pub(crate) fn radius(value: &Interval) -> Result<Rational, String> {
    rational::divide(
        &rational::subtract(&value.upper, &value.lower)?,
        &integer(2),
    )
}

pub(crate) fn center(value: &Interval) -> Result<Rational, String> {
    rational::divide(&rational::add(&value.upper, &value.lower)?, &integer(2))
}
