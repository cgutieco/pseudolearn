#![forbid(unsafe_code)]

use pseudolearn_library::integer_to_real;
use pseudolearn_runtime::{
    ArithmeticError, int_add, int_divide, int_modulo, int_multiply, int_negate, int_power,
    int_subtract,
};

use super::{arithmetic_fault, integer_of, word_of_integer, word_of_truth};
use crate::Fault;

#[inline(always)]
fn checked(
    left: u64,
    right: u64,
    operation: fn(i64, i64) -> Result<i64, ArithmeticError>,
) -> Result<u64, Fault> {
    operation(integer_of(left), integer_of(right))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

#[inline(always)]
pub(crate) fn integer_add(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_add)
}

#[inline(always)]
pub(crate) fn integer_sub(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_subtract)
}

#[inline(always)]
pub(crate) fn integer_mul(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_multiply)
}

#[inline(always)]
pub(crate) fn integer_div(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_divide)
}

#[inline(always)]
pub(crate) fn integer_mod(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_modulo)
}

#[inline(always)]
pub(crate) fn integer_pow(left: u64, right: u64) -> Result<u64, Fault> {
    checked(left, right, int_power)
}

#[inline(always)]
pub(crate) fn integer_neg(source: u64) -> Result<u64, Fault> {
    int_negate(integer_of(source))
        .map(word_of_integer)
        .map_err(arithmetic_fault)
}

#[inline(always)]
pub(crate) fn integer_to_real_word(source: u64) -> Result<u64, Fault> {
    Ok(integer_to_real(integer_of(source)).to_bits())
}

#[inline(always)]
pub(crate) fn integer_eq(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) == integer_of(right)))
}

#[inline(always)]
pub(crate) fn integer_ne(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) != integer_of(right)))
}

#[inline(always)]
pub(crate) fn integer_lt(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) < integer_of(right)))
}

#[inline(always)]
pub(crate) fn integer_le(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) <= integer_of(right)))
}

#[inline(always)]
pub(crate) fn integer_gt(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) > integer_of(right)))
}

#[inline(always)]
pub(crate) fn integer_ge(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(integer_of(left) >= integer_of(right)))
}
