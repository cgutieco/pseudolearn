#![forbid(unsafe_code)]

use super::integer::Integer;
use super::natural::Natural;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Interval {
    pub lower: Integer,
    pub upper: Integer,
}

impl Interval {
    pub(crate) fn point(value: Integer) -> Self {
        Self {
            lower: value.clone(),
            upper: value,
        }
    }

    pub(crate) fn one(precision: u64) -> Self {
        Self::point(Integer::new(false, Natural::power_of_two(precision)))
    }

    pub(crate) fn add(&self, other: &Self) -> Self {
        Self {
            lower: self.lower.add(&other.lower),
            upper: self.upper.add(&other.upper),
        }
    }

    pub(crate) fn negate(&self) -> Self {
        Self {
            lower: self.upper.negate(),
            upper: self.lower.negate(),
        }
    }

    pub(crate) fn subtract(&self, other: &Self) -> Self {
        self.add(&other.negate())
    }

    pub(crate) fn multiply(&self, other: &Self, precision: u64) -> Self {
        let (lower, upper) = self.product_bounds(other);
        Self {
            lower: lower.floor_shift_right(precision),
            upper: upper.ceiling_shift_right(precision),
        }
    }

    pub(crate) fn multiply_integer(&self, factor: &Integer) -> Self {
        self.product_bounds(&Self::point(factor.clone())).into()
    }

    fn product_bounds(&self, other: &Self) -> (Integer, Integer) {
        if !self.lower.is_negative() && !other.lower.is_negative() {
            return (
                self.lower.multiply(&other.lower),
                self.upper.multiply(&other.upper),
            );
        }
        let products = [
            self.lower.multiply(&other.lower),
            self.lower.multiply(&other.upper),
            self.upper.multiply(&other.lower),
            self.upper.multiply(&other.upper),
        ];
        let lower = products.iter().min().cloned().unwrap_or_default();
        let upper = products.iter().max().cloned().unwrap_or_default();
        (lower, upper)
    }

    pub(crate) fn divide_small(&self, divisor: u64) -> Option<Self> {
        let divisor = Natural::from_u64(divisor);
        Some(Self {
            lower: self.lower.floor_divide(&divisor)?,
            upper: self.upper.ceiling_divide(&divisor)?,
        })
    }

    pub(crate) fn divide(&self, other: &Self, precision: u64) -> Option<Self> {
        if other.lower.is_negative() || other.lower.is_zero() {
            return None;
        }
        let mut lower = None;
        let mut upper = None;
        for numerator in [&self.lower, &self.upper] {
            let scaled = numerator.shift_left(precision);
            for denominator in [&other.lower, &other.upper] {
                let floor = scaled.floor_divide(denominator.magnitude())?;
                let ceiling = scaled.ceiling_divide(denominator.magnitude())?;
                lower = Some(lower.map_or(floor.clone(), |current: Integer| current.min(floor)));
                upper =
                    Some(upper.map_or(ceiling.clone(), |current: Integer| current.max(ceiling)));
            }
        }
        Some(Self {
            lower: lower?,
            upper: upper?,
        })
    }

    pub(crate) fn square_root(&self, precision: u64) -> Option<Self> {
        if self.lower.is_negative() {
            return None;
        }
        let lower = self.lower.magnitude().shift_left(precision).square_root();
        let radicand = self.upper.magnitude().shift_left(precision);
        let mut upper = radicand.square_root();
        if upper.multiply(&upper) < radicand {
            upper = upper.increment();
        }
        Some(Self {
            lower: Integer::new(false, lower),
            upper: Integer::new(false, upper),
        })
    }

    pub(crate) fn widen(&self, units: u64) -> Self {
        let width = Integer::new(false, Natural::from_u64(units));
        Self {
            lower: self.lower.subtract(&width),
            upper: self.upper.add(&width),
        }
    }

    pub(crate) fn shift_left(&self, bits: u64) -> Self {
        Self {
            lower: self.lower.shift_left(bits),
            upper: self.upper.shift_left(bits),
        }
    }

    pub(crate) fn shift_right(&self, bits: u64) -> Self {
        Self {
            lower: self.lower.floor_shift_right(bits),
            upper: self.upper.ceiling_shift_right(bits),
        }
    }

    pub(crate) fn magnitude_bound(&self) -> Natural {
        self.lower
            .magnitude()
            .clone()
            .max(self.upper.magnitude().clone())
    }

    pub(crate) fn is_within_units_of_power(&self, precision: u64) -> bool {
        self.magnitude_bound() <= Natural::power_of_two(precision)
    }

    pub(crate) fn is_within_units(&self, units: u64) -> bool {
        self.magnitude_bound() <= Natural::from_u64(units)
    }
}

impl From<(Integer, Integer)> for Interval {
    fn from((lower, upper): (Integer, Integer)) -> Self {
        Self { lower, upper }
    }
}
