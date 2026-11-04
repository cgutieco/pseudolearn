use crate::rational::{self, Rational, integer};
use num_traits::Signed;

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
    if left.lower >= integer(0) {
        return positive_product(left, right);
    }
    if left.upper <= integer(0) {
        return negative_product(left, right);
    }
    if right.lower >= integer(0) || right.upper <= integer(0) {
        return multiply(right, left);
    }
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

fn positive_product(left: &Interval, right: &Interval) -> Result<Interval, String> {
    let lower = if right.lower >= integer(0) {
        &left.lower
    } else {
        &left.upper
    };
    let upper = if right.upper <= integer(0) {
        &left.lower
    } else {
        &left.upper
    };
    Ok(Interval {
        lower: rational::multiply(lower, &right.lower)?,
        upper: rational::multiply(upper, &right.upper)?,
    })
}

fn negative_product(left: &Interval, right: &Interval) -> Result<Interval, String> {
    let lower = if right.upper <= integer(0) {
        &left.upper
    } else {
        &left.lower
    };
    let upper = if right.lower >= integer(0) {
        &left.upper
    } else {
        &left.lower
    };
    Ok(Interval {
        lower: rational::multiply(lower, &right.upper)?,
        upper: rational::multiply(upper, &right.lower)?,
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
    let (lower, upper) = if factor.is_negative() {
        (&value.upper, &value.lower)
    } else {
        (&value.lower, &value.upper)
    };
    Ok(Interval {
        lower: rational::multiply(lower, factor)?,
        upper: rational::multiply(upper, factor)?,
    })
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

#[cfg(test)]
#[path = "interval_tests.rs"]
mod tests;
