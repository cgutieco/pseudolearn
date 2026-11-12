use super::mathematics::library_fault;
use super::{arithmetic_fault, integer_of, word_of_integer};
use crate::Fault;

pub(crate) fn math_tan(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::tangent(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn math_asin(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::arc_sine(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn math_acos(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::arc_cosine(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn math_log10(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::logarithm10(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn math_log2(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::logarithm2(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn math_atan2(left: u64, right: u64) -> Result<u64, Fault> {
    pseudolearn_library::arc_tangent2(f64::from_bits(left), f64::from_bits(right))
        .map(f64::to_bits)
        .map_err(library_fault)
}

pub(crate) fn real_floor(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::floor_real(f64::from_bits(source))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

pub(crate) fn real_ceil(source: u64) -> Result<u64, Fault> {
    pseudolearn_library::ceiling_real(f64::from_bits(source))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

pub(crate) fn int_min(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_integer(integer_of(left).min(integer_of(right))))
}

pub(crate) fn real_min(left: u64, right: u64) -> Result<u64, Fault> {
    let left = f64::from_bits(left);
    let right = f64::from_bits(right);
    if left == 0.0 && right == 0.0 {
        return Ok(left.to_bits() | right.to_bits());
    }
    Ok(left.min(right).to_bits())
}

pub(crate) fn int_max(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_integer(integer_of(left).max(integer_of(right))))
}

pub(crate) fn real_max(left: u64, right: u64) -> Result<u64, Fault> {
    let left = f64::from_bits(left);
    let right = f64::from_bits(right);
    if left == 0.0 && right == 0.0 {
        return Ok(left.to_bits() & right.to_bits());
    }
    Ok(left.max(right).to_bits())
}
