#![forbid(unsafe_code)]

mod character;
mod integer;
mod logical;
mod mathematics;
mod real;

use pseudolearn_runtime::ArithmeticError;

use crate::Fault;

pub(crate) use character::*;
pub(crate) use integer::*;
pub(crate) use logical::*;
pub(crate) use mathematics::*;
pub(crate) use real::*;

pub(crate) const INVALID_BYTECODE: Fault = "invalidBytecode";

#[inline(always)]
pub(crate) fn integer_of(word: u64) -> i64 {
    i64::from_ne_bytes(word.to_ne_bytes())
}

#[inline(always)]
pub(crate) fn word_of_integer(value: i64) -> u64 {
    u64::from_ne_bytes(value.to_ne_bytes())
}

#[inline(always)]
pub(crate) fn word_of_truth(value: bool) -> u64 {
    u64::from(value)
}

#[cold]
#[inline(never)]
pub(crate) fn arithmetic_fault(error: ArithmeticError) -> Fault {
    match error {
        ArithmeticError::DivisionByZero => "divisionByZero",
        ArithmeticError::IntegerOverflow => "integerOverflow",
        ArithmeticError::NegativeExponent => "negativeIntegerExponent",
        ArithmeticError::NonFiniteRealResult => "nonFiniteRealResult",
    }
}
