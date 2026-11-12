#![forbid(unsafe_code)]

use std::cmp::Ordering;

mod division;

#[cfg(test)]
mod division_tests;

const LIMB_BITS: u64 = 64;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub(crate) struct Natural {
    limbs: Vec<u64>,
}

impl Natural {
    pub(crate) fn zero() -> Self {
        Self { limbs: Vec::new() }
    }

    pub(crate) fn from_u64(value: u64) -> Self {
        Self::normalized(vec![value])
    }

    pub(crate) fn power_of_two(exponent: u64) -> Self {
        Self::from_u64(1).shift_left(exponent)
    }

    pub(super) fn normalized(mut limbs: Vec<u64>) -> Self {
        while limbs.last() == Some(&0) {
            limbs.pop();
        }
        Self { limbs }
    }

    pub(crate) fn is_zero(&self) -> bool {
        self.limbs.is_empty()
    }

    pub(crate) fn to_u64(&self) -> Option<u64> {
        match self.limbs.as_slice() {
            [] => Some(0),
            [single] => Some(*single),
            _ => None,
        }
    }

    pub(crate) fn bit_length(&self) -> u64 {
        let Some(top) = self.limbs.last() else {
            return 0;
        };
        let full = u64::try_from(self.limbs.len().saturating_sub(1)).unwrap_or(u64::MAX);
        full.saturating_mul(LIMB_BITS)
            .saturating_add(LIMB_BITS.saturating_sub(u64::from(top.leading_zeros())))
    }

    pub(crate) fn bit(&self, index: u64) -> bool {
        let limb = usize::try_from(index / LIMB_BITS).ok();
        let offset = u32::try_from(index % LIMB_BITS).unwrap_or(0);
        limb.and_then(|position| self.limbs.get(position))
            .is_some_and(|value| value.wrapping_shr(offset) & 1 == 1)
    }

    pub(crate) fn has_bits_below(&self, count: u64) -> bool {
        let whole = usize::try_from(count / LIMB_BITS).unwrap_or(usize::MAX);
        let rest = u32::try_from(count % LIMB_BITS).unwrap_or(0);
        if self.limbs.iter().take(whole).any(|limb| *limb != 0) {
            return true;
        }
        let mask = 1_u64
            .checked_shl(rest)
            .map_or(u64::MAX, |bit| bit.wrapping_sub(1));
        self.limbs.get(whole).is_some_and(|limb| limb & mask != 0)
    }

    pub(crate) fn add(&self, other: &Self) -> Self {
        let length = self.limbs.len().max(other.limbs.len());
        let mut limbs = Vec::with_capacity(length.saturating_add(1));
        let mut carry = false;
        for position in 0..length {
            let left = self.limbs.get(position).copied().unwrap_or(0);
            let right = other.limbs.get(position).copied().unwrap_or(0);
            let (partial, first) = left.overflowing_add(right);
            let (sum, second) = partial.overflowing_add(u64::from(carry));
            limbs.push(sum);
            carry = first || second;
        }
        if carry {
            limbs.push(1);
        }
        Self::normalized(limbs)
    }

    pub(crate) fn increment(mut self) -> Self {
        for limb in &mut self.limbs {
            let (sum, carry) = limb.overflowing_add(1);
            *limb = sum;
            if !carry {
                return self;
            }
        }
        self.limbs.push(1);
        self
    }

    pub(crate) fn subtract(&self, other: &Self) -> Option<Self> {
        if self < other {
            return None;
        }
        let mut limbs = Vec::with_capacity(self.limbs.len());
        let mut borrow = false;
        for (position, left) in self.limbs.iter().enumerate() {
            let right = other.limbs.get(position).copied().unwrap_or(0);
            let (partial, first) = left.overflowing_sub(right);
            let (difference, second) = partial.overflowing_sub(u64::from(borrow));
            limbs.push(difference);
            borrow = first || second;
        }
        Some(Self::normalized(limbs))
    }

    pub(crate) fn multiply(&self, other: &Self) -> Self {
        if self.is_zero() || other.is_zero() {
            return Self::zero();
        }
        let mut limbs = vec![0_u64; self.limbs.len().saturating_add(other.limbs.len())];
        for (left_position, left) in self.limbs.iter().enumerate() {
            let mut carry = 0_u128;
            for (right_position, right) in other.limbs.iter().enumerate() {
                let Some(slot) = limbs.get_mut(left_position.saturating_add(right_position)) else {
                    continue;
                };
                let product = u128::from(*left)
                    .wrapping_mul(u128::from(*right))
                    .wrapping_add(u128::from(*slot))
                    .wrapping_add(carry);
                *slot = low_limb(product);
                carry = product.wrapping_shr(64);
            }
            let position = left_position.saturating_add(other.limbs.len());
            if let Some(slot) = limbs.get_mut(position) {
                *slot = low_limb(carry);
            }
        }
        Self::normalized(limbs)
    }

    pub(crate) fn multiply_small(&self, factor: u64) -> Self {
        self.multiply(&Self::from_u64(factor))
    }

    pub(crate) fn divide_small(&self, divisor: u64) -> Option<(Self, u64)> {
        if divisor == 0 {
            return None;
        }
        if let Ok(narrow) = u32::try_from(divisor) {
            return self.divide_narrow(u64::from(narrow));
        }
        let mut quotient = vec![0_u64; self.limbs.len()];
        let mut remainder = 0_u128;
        for (position, limb) in self.limbs.iter().enumerate().rev() {
            let current = remainder.wrapping_shl(64) | u128::from(*limb);
            let digit = current.checked_div(u128::from(divisor))?;
            remainder = current.checked_rem(u128::from(divisor))?;
            if let Some(slot) = quotient.get_mut(position) {
                *slot = low_limb(digit);
            }
        }
        Some((Self::normalized(quotient), low_limb(remainder)))
    }

    fn divide_narrow(&self, divisor: u64) -> Option<(Self, u64)> {
        let mut quotient = vec![0_u64; self.limbs.len()];
        let mut remainder = 0_u64;
        for (position, limb) in self.limbs.iter().enumerate().rev() {
            let mut digit = 0_u64;
            for half in [limb.wrapping_shr(32), limb & u64::from(u32::MAX)] {
                let current = remainder.wrapping_shl(32) | half;
                digit = digit.wrapping_shl(32) | current.checked_div(divisor)?;
                remainder = current.checked_rem(divisor)?;
            }
            if let Some(slot) = quotient.get_mut(position) {
                *slot = digit;
            }
        }
        Some((Self::normalized(quotient), remainder))
    }

    pub(crate) fn shift_left(&self, bits: u64) -> Self {
        if self.is_zero() {
            return Self::zero();
        }
        let whole = usize::try_from(bits / LIMB_BITS).unwrap_or(usize::MAX);
        let rest = u32::try_from(bits % LIMB_BITS).unwrap_or(0);
        let mut limbs = vec![0_u64; whole];
        let mut carry = 0_u64;
        for limb in &self.limbs {
            limbs.push(limb.wrapping_shl(rest) | carry);
            carry = if rest == 0 {
                0
            } else {
                limb.wrapping_shr(64_u32.wrapping_sub(rest))
            };
        }
        limbs.push(carry);
        Self::normalized(limbs)
    }

    pub(crate) fn shift_right(&self, bits: u64) -> Self {
        let whole = usize::try_from(bits / LIMB_BITS).unwrap_or(usize::MAX);
        let rest = u32::try_from(bits % LIMB_BITS).unwrap_or(0);
        let kept = self.limbs.get(whole..).unwrap_or_default();
        let mut limbs = Vec::with_capacity(kept.len());
        for (position, limb) in kept.iter().enumerate() {
            let upper = kept.get(position.saturating_add(1)).copied().unwrap_or(0);
            let carried = if rest == 0 {
                0
            } else {
                upper.wrapping_shl(64_u32.wrapping_sub(rest))
            };
            limbs.push(limb.wrapping_shr(rest) | carried);
        }
        Self::normalized(limbs)
    }

    pub(crate) fn power(&self, exponent: u32) -> Self {
        let mut result = Self::from_u64(1);
        let mut base = self.clone();
        let mut remaining = exponent;
        while remaining > 0 {
            if remaining & 1 == 1 {
                result = result.multiply(&base);
            }
            remaining = remaining.wrapping_shr(1);
            if remaining > 0 {
                base = base.multiply(&base);
            }
        }
        result
    }
}

pub(super) fn low_limb(value: u128) -> u64 {
    u64::try_from(value & u128::from(u64::MAX)).unwrap_or(0)
}

impl Ord for Natural {
    fn cmp(&self, other: &Self) -> Ordering {
        self.limbs
            .len()
            .cmp(&other.limbs.len())
            .then_with(|| self.limbs.iter().rev().cmp(other.limbs.iter().rev()))
    }
}

impl PartialOrd for Natural {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
