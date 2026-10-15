#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::{Integer, Interval, Natural};

use super::binary64::{Decomposed, decompose, exact_interval, round_interval};
use super::constants::half_turn;
use super::series::{FactorialSeries, factorial_sum};
use super::ziv::{correctly_rounded, signed_precision};

const GUARD_BITS: u64 = 32;
const REDUCTION_GUARD_BITS: u64 = 96;
const IDENTITY_ARGUMENT: f64 = 1.0 / 1_073_741_824.0;

#[derive(Clone, Copy, Eq, PartialEq)]
enum Wave {
    Sine,
    Cosine,
}

pub fn sine(value: f64) -> Result<f64, LibraryError> {
    let decomposed = decompose(value)?;
    if value.abs() < IDENTITY_ARGUMENT {
        return Ok(value);
    }
    correctly_rounded(|precision| attempt(&decomposed, Wave::Sine, precision))
}

pub fn cosine(value: f64) -> Result<f64, LibraryError> {
    let decomposed = decompose(value)?;
    if value.abs() < IDENTITY_ARGUMENT {
        return Ok(1.0);
    }
    correctly_rounded(|precision| attempt(&decomposed, Wave::Cosine, precision))
}

fn attempt(argument: &Decomposed, wave: Wave, precision: u64) -> Result<Option<f64>, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let (reduced, quadrant) = reduce(argument, working)?;
    let square = reduced.multiply(&reduced, working);
    let series = FactorialSeries {
        argument: &square,
        alternating: true,
        precision: working,
    };
    let shifted = match wave {
        Wave::Sine => quadrant,
        Wave::Cosine => quadrant.wrapping_add(1) & 3,
    };
    let value = if shifted & 1 == 0 {
        factorial_sum(&series, reduced, sine_divisor)?
    } else {
        factorial_sum(&series, Interval::one(working), cosine_divisor)?
    };
    let result = if shifted >= 2 { value.negate() } else { value };
    Ok(round_interval(&result, signed_precision(working)))
}

fn sine_divisor(index: u64) -> Option<u64> {
    let even = index.checked_mul(2)?;
    even.checked_mul(even.checked_add(1)?)
}

fn cosine_divisor(index: u64) -> Option<u64> {
    let even = index.checked_mul(2)?;
    even.checked_mul(even.checked_sub(1)?)
}

fn reduce(argument: &Decomposed, precision: u64) -> Result<(Interval, u64), LibraryError> {
    let magnitude_bits = u64::try_from(argument.exponent.saturating_add(53).max(0)).unwrap_or(0);
    let extended = precision
        .saturating_add(magnitude_bits)
        .saturating_add(REDUCTION_GUARD_BITS);
    let half_turn = half_turn(extended)?;
    let two_over_pi = Interval::one(extended)
        .shift_left(1)
        .divide(&half_turn, extended)
        .ok_or(LibraryError::PrecisionExhausted)?;
    let scaled = exact_interval(argument, extended).multiply(&two_over_pi, extended);
    let half = Integer::new(false, Natural::power_of_two(extended.saturating_sub(1)));
    let quotient = scaled.lower.add(&half).floor_shift_right(extended);
    let fraction = scaled.subtract(&Interval::point(quotient.shift_left(extended)));
    let quarter_turn = half_turn.shift_right(1);
    let reduced = fraction
        .multiply(&quarter_turn, extended)
        .shift_right(extended.saturating_sub(precision));
    if !reduced.is_within_units_of_power(precision) {
        return Err(LibraryError::PrecisionExhausted);
    }
    Ok((reduced, quadrant_of(&quotient)))
}

fn quadrant_of(quotient: &Integer) -> u64 {
    let low = quotient
        .magnitude()
        .divide_small(4)
        .map_or(0, |(_, remainder)| remainder);
    if quotient.is_negative() {
        4_u64.wrapping_sub(low) & 3
    } else {
        low
    }
}
