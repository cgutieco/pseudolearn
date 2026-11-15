#![forbid(unsafe_code)]

use super::{INVALID_BYTECODE, integer_of, word_of_integer, word_of_truth};
use crate::Fault;

#[inline(always)]
pub(crate) fn character_eq(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left == right))
}

#[inline(always)]
pub(crate) fn character_ne(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left != right))
}

#[inline(always)]
pub(crate) fn character_lt(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left < right))
}

#[inline(always)]
pub(crate) fn character_le(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left <= right))
}

#[inline(always)]
pub(crate) fn character_gt(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left > right))
}

#[inline(always)]
pub(crate) fn character_ge(left: u64, right: u64) -> Result<u64, Fault> {
    Ok(word_of_truth(left >= right))
}

#[inline(always)]
pub(crate) fn character_code(source: u64) -> Result<u64, Fault> {
    let scalar = u32::try_from(source).map_err(|_| INVALID_BYTECODE)?;
    Ok(word_of_integer(i64::from(scalar)))
}

#[inline(always)]
pub(crate) fn character_from_code(source: u64) -> Result<u64, Fault> {
    let character = u32::try_from(integer_of(source))
        .ok()
        .and_then(char::from_u32)
        .ok_or("invalidCharacterCode")?;
    Ok(u64::from(u32::from(character)))
}
