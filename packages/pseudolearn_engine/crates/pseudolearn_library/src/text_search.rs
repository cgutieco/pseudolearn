#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn text_substring(text: &str, first: i64, last: i64) -> Result<String, MemoryError> {
    let start = usize::try_from(first).map_err(|_| MemoryError::StringPositionOutOfRange)?;
    let end = last
        .checked_add(1)
        .and_then(|end| usize::try_from(end).ok())
        .ok_or(MemoryError::StringPositionOutOfRange)?;
    let width = end
        .checked_sub(start)
        .ok_or(MemoryError::StringPositionOutOfRange)?;
    let mut boundaries = text
        .char_indices()
        .map(|(offset, _)| offset)
        .chain(std::iter::once(text.len()));
    let start_byte = boundaries
        .nth(start)
        .ok_or(MemoryError::StringPositionOutOfRange)?;
    let end_byte = match width.checked_sub(1) {
        Some(remaining) => boundaries
            .nth(remaining)
            .ok_or(MemoryError::StringPositionOutOfRange)?,
        None => start_byte,
    };
    text.get(start_byte..end_byte)
        .map(str::to_owned)
        .ok_or(MemoryError::StringPositionOutOfRange)
}

pub fn substring_fault_position(length: u64, first: i64, last: Option<i64>) -> i64 {
    let first_in_range = u64::try_from(first).is_ok_and(|first| first <= length);
    match last {
        Some(last) if first_in_range => last,
        _ => first,
    }
}

pub fn text_contains(text: &str, part: &str) -> bool {
    text.contains(part)
}

pub fn text_position(text: &str, part: &str) -> Option<i64> {
    let byte_position = text.find(part)?;
    let prefix = text.get(..byte_position)?;
    i64::try_from(prefix.chars().count()).ok()
}

pub fn text_starts_with(text: &str, part: &str) -> bool {
    text.starts_with(part)
}

pub fn text_ends_with(text: &str, part: &str) -> bool {
    text.ends_with(part)
}
