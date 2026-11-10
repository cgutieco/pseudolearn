#![forbid(unsafe_code)]

use crate::text_search::{
    text_contains, text_ends_with, text_position, text_starts_with, text_substring,
};
use pseudolearn_runtime::{EffectOperation, Handle, Heap, HostValue, MemoryError, text_content};

type PairQuery = fn(&str, &str) -> HostValue;

pub fn local_text_query(
    heap: &Heap,
    operation: &EffectOperation,
    arguments: &[u64],
) -> Result<Option<HostValue>, MemoryError> {
    if operation.family != "text" || operation.receiver.is_some() || operation.effect {
        return Ok(None);
    }
    let query: PairQuery = match operation.identity {
        "substring" => return substring_query(heap, arguments),
        "contains" => |text, part| HostValue::Boolean(text_contains(text, part)),
        "positionOf" => |text, part| HostValue::OptionalInteger(text_position(text, part)),
        "startsWith" => |text, part| HostValue::Boolean(text_starts_with(text, part)),
        "endsWith" => |text, part| HostValue::Boolean(text_ends_with(text, part)),
        _ => return Ok(None),
    };
    pair_query(heap, arguments, query)
}

fn pair_query(
    heap: &Heap,
    arguments: &[u64],
    query: PairQuery,
) -> Result<Option<HostValue>, MemoryError> {
    let [text, part] = arguments else {
        return Err(MemoryError::Internal);
    };
    let text = text_content(heap, text_handle(*text)?)?;
    let part = text_content(heap, text_handle(*part)?)?;
    Ok(Some(query(text, part)))
}

fn substring_query(heap: &Heap, arguments: &[u64]) -> Result<Option<HostValue>, MemoryError> {
    let [text, first, last] = arguments else {
        return Err(MemoryError::Internal);
    };
    let text = text_content(heap, text_handle(*text)?)?;
    let first = i64::from_ne_bytes(first.to_ne_bytes());
    let last = i64::from_ne_bytes(last.to_ne_bytes());
    match text_substring(text, first, last) {
        Ok(slice) => Ok(Some(HostValue::Text(slice))),
        Err(MemoryError::StringPositionOutOfRange) => Ok(None),
        Err(error) => Err(error),
    }
}

fn text_handle(word: u64) -> Result<Handle, MemoryError> {
    u32::try_from(word)
        .map(Handle)
        .map_err(|_| MemoryError::Internal)
}
