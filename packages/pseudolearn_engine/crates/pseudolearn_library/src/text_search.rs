#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn text_substring(text: &str, from: i64, to: i64) -> Result<String, MemoryError> {
    let start = usize::try_from(from).map_err(|_| MemoryError::StringPositionOutOfRange)?;
    let end = to
        .checked_add(1)
        .and_then(|end| usize::try_from(end).ok())
        .ok_or(MemoryError::StringPositionOutOfRange)?;
    if end < start || end > text.chars().count() {
        return Err(MemoryError::StringPositionOutOfRange);
    }
    Ok(text
        .chars()
        .skip(start)
        .take(end.saturating_sub(start))
        .collect())
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
