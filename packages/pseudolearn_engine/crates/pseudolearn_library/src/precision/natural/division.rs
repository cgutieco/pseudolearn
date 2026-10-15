#![forbid(unsafe_code)]

use super::{Natural, low_limb};

impl Natural {
    pub(crate) fn divide(&self, divisor: &Self) -> Option<(Self, Self)> {
        if divisor.is_zero() {
            return None;
        }
        if let Some(small) = divisor.to_u64() {
            let (quotient, remainder) = self.divide_small(small)?;
            return Some((quotient, Self::from_u64(remainder)));
        }
        if self < divisor {
            return Some((Self::zero(), self.clone()));
        }
        let shift = u64::from(divisor.limbs.last()?.leading_zeros());
        let normalized_divisor = divisor.shift_left(shift);
        let mut remainder = self.shift_left(shift).limbs;
        remainder.push(0);
        let quotient = long_division(&mut remainder, &normalized_divisor.limbs)?;
        let remainder = Self::normalized(remainder).shift_right(shift);
        Some((Self::normalized(quotient), remainder))
    }

    pub(crate) fn square_root(&self) -> Self {
        if self.is_zero() {
            return Self::zero();
        }
        let mut estimate = Self::power_of_two(self.bit_length().div_ceil(2));
        loop {
            let Some((quotient, _)) = self.divide(&estimate) else {
                return estimate;
            };
            let next = estimate.add(&quotient).shift_right(1);
            if next >= estimate {
                return estimate;
            }
            estimate = next;
        }
    }
}

fn long_division(remainder: &mut [u64], divisor: &[u64]) -> Option<Vec<u64>> {
    let size = divisor.len();
    let steps = remainder.len().checked_sub(size)?;
    let top = u128::from(*divisor.last()?);
    let next = u128::from(*divisor.get(size.checked_sub(2)?)?);
    let mut quotient = vec![0_u64; steps];
    for position in (0..steps).rev() {
        let window = remainder.get_mut(position..position.checked_add(size)?.checked_add(1)?)?;
        let digit = estimate_digit(window, top, next)?;
        let corrected = subtract_multiple(window, divisor, digit)?;
        if let Some(slot) = quotient.get_mut(position) {
            *slot = corrected;
        }
    }
    Some(quotient)
}

fn estimate_digit(window: &[u64], top: u128, next: u128) -> Option<u64> {
    let length = window.len();
    let high = u128::from(*window.get(length.checked_sub(1)?)?);
    let middle = u128::from(*window.get(length.checked_sub(2)?)?);
    let low = u128::from(*window.get(length.checked_sub(3)?).unwrap_or(&0));
    let numerator = high.wrapping_shl(64) | middle;
    let mut digit = numerator.checked_div(top)?.min(u128::from(u64::MAX));
    let mut rest = numerator.checked_sub(digit.checked_mul(top)?)?;
    while rest <= u128::from(u64::MAX) && digit.checked_mul(next)? > rest.wrapping_shl(64) | low {
        digit = digit.checked_sub(1)?;
        rest = rest.checked_add(top)?;
    }
    u64::try_from(digit).ok()
}

fn subtract_multiple(window: &mut [u64], divisor: &[u64], digit: u64) -> Option<u64> {
    let mut borrow = 0_u128;
    let mut carry = 0_u128;
    for (position, slot) in window.iter_mut().enumerate() {
        let factor = u128::from(divisor.get(position).copied().unwrap_or(0));
        let product = factor.checked_mul(u128::from(digit))?.checked_add(carry)?;
        carry = product.wrapping_shr(64);
        let subtrahend = (product & u128::from(u64::MAX)).checked_add(borrow)?;
        let (value, underflow) = u128::from(*slot).overflowing_sub(subtrahend);
        *slot = low_limb(value);
        borrow = u128::from(underflow);
    }
    if borrow == 0 {
        return Some(digit);
    }
    add_back(window, divisor);
    digit.checked_sub(1)
}

fn add_back(window: &mut [u64], divisor: &[u64]) {
    let mut carry = false;
    for (position, slot) in window.iter_mut().enumerate() {
        let addend = divisor.get(position).copied().unwrap_or(0);
        let (partial, first) = slot.overflowing_add(addend);
        let (sum, second) = partial.overflowing_add(u64::from(carry));
        *slot = sum;
        carry = first || second;
    }
}
