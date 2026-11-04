use super::binary64::{decompose, exact_interval, round_interval};
use super::constants::half_turn;
use super::ziv::{correctly_rounded, signed_precision};
use crate::LibraryError;
use crate::precision::Interval;

pub fn tangent(value: f64) -> Result<f64, LibraryError> {
    let argument = decompose(value)?;
    if value.abs() < 1.0 / 1_073_741_824.0 {
        return Ok(value);
    }
    correctly_rounded(|precision| {
        let working = precision.saturating_add(32);
        let mut sine = super::trigonometric::enclose(&argument, false, working)?;
        let mut cosine = super::trigonometric::enclose(&argument, true, working)?;
        if cosine.upper.is_negative() {
            sine = sine.negate();
            cosine = cosine.negate();
        }
        Ok(sine
            .divide(&cosine, working)
            .and_then(|value| round_interval(&value, signed_precision(working))))
    })
}

pub fn arc_sine(value: f64) -> Result<f64, LibraryError> {
    inverse(value, false)
}
pub fn arc_cosine(value: f64) -> Result<f64, LibraryError> {
    inverse(value, true)
}

fn inverse(value: f64, cosine: bool) -> Result<f64, LibraryError> {
    decompose(value)?;
    if value.abs() > 1.0 {
        return Err(LibraryError::NonFiniteResult);
    }
    if cosine && value == 1.0 {
        return Ok(0.0);
    }
    if !cosine && value.abs() < 1.0 / 1_073_741_824.0 {
        return Ok(value);
    }
    correctly_rounded(|precision| {
        let working = precision.saturating_add(64);
        let half_pi = half_turn(working)?.shift_right(1);
        let mut angle = if value.abs() == 1.0 {
            half_pi.clone()
        } else {
            let argument = exact_interval(&decompose(value.abs())?, working);
            let root = Interval::one(working)
                .subtract(&argument.multiply(&argument, working))
                .square_root(working)
                .ok_or(LibraryError::PrecisionExhausted)?;
            angle(&argument, &root, working)?
        };
        if value.is_sign_negative() {
            angle = angle.negate();
        }
        if cosine {
            angle = half_pi.subtract(&angle);
        }
        Ok(round_interval(&angle, signed_precision(working)))
    })
}

pub fn arc_tangent2(vertical: f64, horizontal: f64) -> Result<f64, LibraryError> {
    let ordinate = decompose(vertical)?;
    let abscissa = decompose(horizontal)?;
    if vertical == 0.0 && !horizontal.is_sign_negative() {
        return Ok(vertical);
    }
    correctly_rounded(|precision| {
        let working = precision.saturating_add(64);
        let mut result = if horizontal == 0.0 {
            let half_turn = half_turn(working)?;
            if vertical == 0.0 {
                half_turn
            } else {
                half_turn.shift_right(1)
            }
        } else {
            let angle = scaled_angle(ordinate, abscissa, working)?;
            if horizontal.is_sign_negative() {
                half_turn(working)?.subtract(&angle)
            } else {
                angle
            }
        };
        if vertical.is_sign_negative() {
            result = result.negate();
        }
        Ok(round_interval(&result, signed_precision(working)))
    })
}

fn angle(
    vertical: &Interval,
    horizontal: &Interval,
    precision: u64,
) -> Result<Interval, LibraryError> {
    let inverted = vertical.lower > horizontal.lower;
    let (small, large) = if inverted {
        (horizontal, vertical)
    } else {
        (vertical, horizontal)
    };
    let ratio = small
        .divide(large, precision)
        .ok_or(LibraryError::PrecisionExhausted)?;
    let angle = super::arctangent::halved_arctangent(&ratio, precision)?;
    Ok(if inverted {
        half_turn(precision)?.shift_right(1).subtract(&angle)
    } else {
        angle
    })
}

fn scaled_angle(
    ordinate: super::binary64::Decomposed,
    abscissa: super::binary64::Decomposed,
    working: u64,
) -> Result<Interval, LibraryError> {
    let scale = ordinate.exponent.max(abscissa.exponent);
    let ordinate = super::binary64::Decomposed {
        negative: false,
        exponent: ordinate.exponent.saturating_sub(scale),
        ..ordinate
    };
    let abscissa = super::binary64::Decomposed {
        negative: false,
        exponent: abscissa.exponent.saturating_sub(scale),
        ..abscissa
    };
    let angle = angle(
        &exact_interval(&ordinate, working),
        &exact_interval(&abscissa, working),
        working,
    )?;
    Ok(angle)
}
