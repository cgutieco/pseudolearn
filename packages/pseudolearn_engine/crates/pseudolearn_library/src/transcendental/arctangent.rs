#![forbid(unsafe_code)]

use crate::LibraryError;
use crate::precision::Interval;

use super::binary64::{Decomposed, decompose, exact_interval, round_interval};
use super::constants::half_turn;
use super::series::{OddPowerSeries, odd_power_sum};
use super::ziv::{correctly_rounded, signed_precision};

const GUARD_BITS: u64 = 32;
const HALVINGS: u64 = 2;
const IDENTITY_ARGUMENT: f64 = 1.0 / 1_073_741_824.0;

pub fn arctangent(value: f64) -> Result<f64, LibraryError> {
    let decomposed = decompose(value)?;
    if value.abs() < IDENTITY_ARGUMENT {
        return Ok(value);
    }
    correctly_rounded(|precision| attempt(&decomposed, precision))
}

fn attempt(argument: &Decomposed, precision: u64) -> Result<Option<f64>, LibraryError> {
    let working = precision.saturating_add(GUARD_BITS);
    let positive = Decomposed {
        negative: false,
        ..*argument
    };
    let magnitude = exact_interval(&positive, working);
    let one = Interval::one(working);
    let inverted = magnitude.lower > one.lower;
    let base = if inverted {
        one.divide(&magnitude, working)
            .ok_or(LibraryError::PrecisionExhausted)?
    } else {
        magnitude
    };
    let mut angle = halved_arctangent(&base, working)?;
    if inverted {
        angle = half_turn(working)?.shift_right(1).subtract(&angle);
    }
    if argument.negative {
        angle = angle.negate();
    }
    Ok(round_interval(&angle, signed_precision(working)))
}

fn halved_arctangent(base: &Interval, precision: u64) -> Result<Interval, LibraryError> {
    let one = Interval::one(precision);
    let mut reduced = base.clone();
    for _ in 0..HALVINGS {
        let hypotenuse = one
            .add(&reduced.multiply(&reduced, precision))
            .square_root(precision)
            .ok_or(LibraryError::PrecisionExhausted)?;
        reduced = reduced
            .divide(&one.add(&hypotenuse), precision)
            .ok_or(LibraryError::PrecisionExhausted)?;
    }
    let series = OddPowerSeries {
        argument: &reduced,
        alternating: true,
        precision,
    };
    Ok(odd_power_sum(&series)?.shift_left(HALVINGS))
}
