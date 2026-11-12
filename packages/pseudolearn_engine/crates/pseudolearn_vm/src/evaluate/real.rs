#![forbid(unsafe_code)]

use pseudolearn_library::{round_real, truncate_real};
use pseudolearn_runtime::{ArithmeticError, real_add, real_divide, real_multiply, real_subtract};

use super::{arithmetic_fault, word_of_integer, word_of_truth};
use crate::Fault;

const SIGN_BIT: u64 = 1_u64 << 63;

#[inline(always)]
fn checked(
    left: u64,
    right: u64,
    operation: fn(f64, f64) -> Result<f64, ArithmeticError>,
) -> Result<u64, Fault> {
    operation(f64::from_bits(left), f64::from_bits(right))
        .map(f64::to_bits)
        .map_err(arithmetic_fault)
}

#[inline(always)]
pub(crate) fn real_add_word(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, real_add)
}

#[inline(always)]
pub(crate) fn real_sub(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, real_subtract)
}

#[inline(always)]
pub(crate) fn real_mul(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, real_multiply)
}

#[inline(always)]
pub(crate) fn real_div(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, real_divide)
}

#[inline(always)]
pub(crate) fn real_neg(source: u64) -> Result<u64, Fault> {
    Ok(source ^ SIGN_BIT)
}

#[inline(always)]
pub(crate) fn real_trunc(source: u64) -> Result<u64, Fault> {
    truncate_real(f64::from_bits(source))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

#[inline(always)]
pub(crate) fn real_round(source: u64) -> Result<u64, Fault> {
    round_real(f64::from_bits(source))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

#[inline(always)]
fn compare(left: u64, right: u64, relation: fn(&f64, &f64) -> bool) -> Result<u64, Fault> {
    Ok(word_of_truth(relation(
        &f64::from_bits(left),
        &f64::from_bits(right),
    )))
}

#[inline(always)]
pub(crate) fn real_eq(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialEq::eq)
}

#[inline(always)]
pub(crate) fn real_ne(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialEq::ne)
}

#[inline(always)]
pub(crate) fn real_lt(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialOrd::lt)
}

#[inline(always)]
pub(crate) fn real_le(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialOrd::le)
}

#[inline(always)]
pub(crate) fn real_gt(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialOrd::gt)
}

#[inline(always)]
pub(crate) fn real_ge(left: u64, right: u64) -> Result<u64, Fault> {
    compare(left, right, PartialOrd::ge)
}
