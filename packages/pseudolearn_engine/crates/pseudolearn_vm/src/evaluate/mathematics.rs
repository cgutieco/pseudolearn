#![forbid(unsafe_code)]

use pseudolearn_library::{
    LibraryError, absolute, arctangent, cosine, exponential, natural_logarithm, real_power, sine,
    square_root,
};

use super::arithmetic_fault;
use crate::Fault;

#[cold]
#[inline(never)]
fn library_fault(error: LibraryError) -> Fault {
    match error {
        LibraryError::Arithmetic(arithmetic) => arithmetic_fault(arithmetic),
        LibraryError::NegativeSquareRoot
        | LibraryError::NonFiniteInput
        | LibraryError::NonFiniteResult => "nonFiniteRealResult",
        LibraryError::PrecisionExhausted => "internalFault",
    }
}

#[inline(always)]
fn unary(source: u64, function: fn(f64) -> Result<f64, LibraryError>) -> Result<u64, Fault> {
    function(f64::from_bits(source))
        .map(f64::to_bits)
        .map_err(library_fault)
}

#[inline(always)]
pub(crate) fn math_sqrt(source: u64) -> Result<u64, Fault> {
    unary(source, square_root)
}

#[inline(always)]
pub(crate) fn math_abs(source: u64) -> Result<u64, Fault> {
    Ok(absolute(f64::from_bits(source)).to_bits())
}

#[inline(always)]
pub(crate) fn math_ln(source: u64) -> Result<u64, Fault> {
    unary(source, natural_logarithm)
}

#[inline(always)]
pub(crate) fn math_exp(source: u64) -> Result<u64, Fault> {
    unary(source, exponential)
}

#[inline(always)]
pub(crate) fn math_sin(source: u64) -> Result<u64, Fault> {
    unary(source, sine)
}

#[inline(always)]
pub(crate) fn math_cos(source: u64) -> Result<u64, Fault> {
    unary(source, cosine)
}

#[inline(always)]
pub(crate) fn math_atan(source: u64) -> Result<u64, Fault> {
    unary(source, arctangent)
}

#[inline(always)]
pub(crate) fn real_pow(left: u64, right: u64) -> Result<u64, Fault> {
    real_power(f64::from_bits(left), f64::from_bits(right))
        .map(f64::to_bits)
        .map_err(library_fault)
}
