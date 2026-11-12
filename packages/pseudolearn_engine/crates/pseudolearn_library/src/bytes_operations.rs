#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn bytes_from_text(text: &str) -> Vec<u8> {
    text.as_bytes().to_vec()
}

pub fn bytes_segment(bytes: &[u8], start: i64, count: i64) -> Result<Vec<u8>, MemoryError> {
    let start = usize::try_from(start).map_err(|_| MemoryError::BytesRangeOutOfBounds)?;
    let count = usize::try_from(count).map_err(|_| MemoryError::BytesRangeOutOfBounds)?;
    let end = start
        .checked_add(count)
        .ok_or(MemoryError::BytesRangeOutOfBounds)?;
    bytes
        .get(start..end)
        .map(<[u8]>::to_vec)
        .ok_or(MemoryError::BytesRangeOutOfBounds)
}

pub fn bytes_join(left: &[u8], right: &[u8]) -> Vec<u8> {
    left.iter().chain(right).copied().collect()
}
