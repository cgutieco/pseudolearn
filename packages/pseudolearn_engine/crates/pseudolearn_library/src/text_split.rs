#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn split_text(text: &str, separator: &str) -> Result<Vec<String>, MemoryError> {
    if separator.is_empty() {
        return Err(MemoryError::EmptySeparator);
    }
    Ok(text.split(separator).map(str::to_owned).collect())
}

pub fn join_text(parts: &[String], separator: &str) -> String {
    parts.join(separator)
}
