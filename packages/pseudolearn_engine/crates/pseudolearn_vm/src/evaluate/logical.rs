#![forbid(unsafe_code)]

use super::{INVALID_BYTECODE, word_of_truth};
use crate::Fault;

#[inline(always)]
fn truth_of(word: u64) -> Result<bool, Fault> {
    match word {
        0 => Ok(false),
        1 => Ok(true),
        _ => Err(INVALID_BYTECODE),
    }
}

#[inline(always)]
pub(crate) fn boolean_not(source: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(!truth_of(source)?))
}

#[inline(always)]
pub(crate) fn boolean_eq(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(truth_of(left)? == truth_of(right)?))
}

#[inline(always)]
pub(crate) fn boolean_ne(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(truth_of(left)? != truth_of(right)?))
}

#[inline(always)]
pub(crate) fn branch_truth(word: u64) -> Result<bool, Fault> {
    truth_of(word)
}
