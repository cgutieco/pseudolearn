#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn split_text(text: &str, separator: &str) -> Result<Vec<String>, MemoryError> {
    if separator.is_empty() {
        return Err(MemoryError::EmptySeparator);
    }
    Ok(text.split(separator).map(str::to_owned).collect())
}

pub fn join_text(
    parts: &[String],
    separator: &str,
    maximum_points: u64,
) -> Result<String, MemoryError> {
    let separators =
        u64::try_from(parts.len().saturating_sub(1)).map_err(|_| MemoryError::Resource)?;
    let separator_points =
        u64::try_from(separator.chars().count()).map_err(|_| MemoryError::Resource)?;
    let mut total = separators
        .checked_mul(separator_points)
        .ok_or(MemoryError::CellLimit)?;
    for part in parts {
        let points = u64::try_from(part.chars().count()).map_err(|_| MemoryError::Resource)?;
        total = total.checked_add(points).ok_or(MemoryError::CellLimit)?;
        if total > maximum_points {
            return Err(MemoryError::CellLimit);
        }
    }
    if total > maximum_points {
        return Err(MemoryError::CellLimit);
    }
    Ok(parts.join(separator))
}
