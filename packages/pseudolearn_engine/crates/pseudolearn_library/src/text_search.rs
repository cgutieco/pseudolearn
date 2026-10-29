#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn text_substring(text: &str, start: i64, count: i64) -> Result<String, MemoryError> {
    let start = usize::try_from(start).map_err(|_| MemoryError::StringPositionOutOfRange)?;
    let count = usize::try_from(count).map_err(|_| MemoryError::StringPositionOutOfRange)?;
    let end = start
        .checked_add(count)
        .ok_or(MemoryError::StringPositionOutOfRange)?;
    let length = text.chars().count();
    if end > length {
        return Err(MemoryError::StringPositionOutOfRange);
    }
    Ok(text.chars().skip(start).take(count).collect())
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
