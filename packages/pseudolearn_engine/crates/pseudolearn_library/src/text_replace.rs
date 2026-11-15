#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub fn replace_all(
    text: &str,
    searched: &str,
    replacement: &str,
    maximum_points: u64,
) -> Result<String, MemoryError> {
    if searched.is_empty() {
        return Ok(text.to_owned());
    }
    let result_points = replaced_points(text, searched, replacement)?;
    if result_points > maximum_points {
        return Err(MemoryError::CellLimit);
    }
    Ok(text.replace(searched, replacement))
}

fn replaced_points(text: &str, searched: &str, replacement: &str) -> Result<u64, MemoryError> {
    let matches = count(text.matches(searched).count())?;
    let kept = count(text.chars().count())?
        .checked_sub(
            matches
                .checked_mul(count(searched.chars().count())?)
                .ok_or(MemoryError::CellLimit)?,
        )
        .ok_or(MemoryError::Internal)?;
    matches
        .checked_mul(count(replacement.chars().count())?)
        .and_then(|inserted| kept.checked_add(inserted))
        .ok_or(MemoryError::CellLimit)
}

fn count(value: usize) -> Result<u64, MemoryError> {
    u64::try_from(value).map_err(|_| MemoryError::Resource)
}

pub fn trim_text(text: &str) -> String {
    text.trim_matches(|character| matches!(character, ' ' | '\t' | '\n' | '\r'))
        .to_owned()
}
