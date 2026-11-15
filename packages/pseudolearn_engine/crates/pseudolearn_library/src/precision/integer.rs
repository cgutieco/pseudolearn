#![forbid(unsafe_code)]

use std::cmp::Ordering;

use super::natural::Natural;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub(crate) struct Integer {
    negative: bool,
    magnitude: Natural,
}

impl Integer {
    pub(crate) fn new(negative: bool, magnitude: Natural) -> Self {
        let negative = negative && !magnitude.is_zero();
        Self {
            negative,
            magnitude,
        }
    }

    pub(crate) fn from_i64(value: i64) -> Self {
        Self::new(value < 0, Natural::from_u64(value.unsigned_abs()))
    }

    pub(crate) fn is_negative(&self) -> bool {
        self.negative
    }

    pub(crate) fn is_zero(&self) -> bool {
        self.magnitude.is_zero()
    }

    pub(crate) fn magnitude(&self) -> &Natural {
        &self.magnitude
    }

    pub(crate) fn negate(&self) -> Self {
        Self::new(!self.negative, self.magnitude.clone())
    }

    pub(crate) fn add(&self, other: &Self) -> Self {
        if self.negative == other.negative {
            return Self::new(self.negative, self.magnitude.add(&other.magnitude));
        }
        match self.magnitude.subtract(&other.magnitude) {
            Some(difference) => Self::new(self.negative, difference),
            None => Self::new(
                other.negative,
                other
                    .magnitude
                    .subtract(&self.magnitude)
                    .unwrap_or_default(),
            ),
        }
    }

    pub(crate) fn subtract(&self, other: &Self) -> Self {
        self.add(&other.negate())
    }

    pub(crate) fn multiply(&self, other: &Self) -> Self {
        Self::new(
            self.negative != other.negative,
            self.magnitude.multiply(&other.magnitude),
        )
    }

    pub(crate) fn shift_left(&self, bits: u64) -> Self {
        Self::new(self.negative, self.magnitude.shift_left(bits))
    }

    pub(crate) fn floor_shift_right(&self, bits: u64) -> Self {
        self.directed_shift_right(bits, self.negative)
    }

    pub(crate) fn ceiling_shift_right(&self, bits: u64) -> Self {
        self.directed_shift_right(bits, !self.negative)
    }

    fn directed_shift_right(&self, bits: u64, away_from_zero: bool) -> Self {
        let truncated = self.magnitude.shift_right(bits);
        if away_from_zero && self.magnitude.has_bits_below(bits) {
            return Self::new(self.negative, truncated.increment());
        }
        Self::new(self.negative, truncated)
    }

    pub(crate) fn floor_divide(&self, divisor: &Natural) -> Option<Self> {
        self.directed_divide(divisor, self.negative)
    }

    pub(crate) fn ceiling_divide(&self, divisor: &Natural) -> Option<Self> {
        self.directed_divide(divisor, !self.negative)
    }

    fn directed_divide(&self, divisor: &Natural, away_from_zero: bool) -> Option<Self> {
        let (quotient, remainder) = self.magnitude.divide(divisor)?;
        if away_from_zero && !remainder.is_zero() {
            return Some(Self::new(self.negative, quotient.increment()));
        }
        Some(Self::new(self.negative, quotient))
    }
}

impl Ord for Integer {
    fn cmp(&self, other: &Self) -> Ordering {
        match (self.negative, other.negative) {
            (false, true) => Ordering::Greater,
            (true, false) => Ordering::Less,
            (false, false) => self.magnitude.cmp(&other.magnitude),
            (true, true) => other.magnitude.cmp(&self.magnitude),
        }
    }
}

impl PartialOrd for Integer {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
