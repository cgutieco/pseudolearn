#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub const MAXIMUM_PADDING_WIDTH: usize = 1 << 24;

pub fn pad_left(text: &str, width: i64, fill: &str) -> Result<String, MemoryError> {
    let padding = padding_for(text, width, fill)?;
    Ok(format!("{padding}{text}"))
}

pub fn pad_right(text: &str, width: i64, fill: &str) -> Result<String, MemoryError> {
    let padding = padding_for(text, width, fill)?;
    Ok(format!("{text}{padding}"))
}

fn padding_for(text: &str, width: i64, fill: &str) -> Result<String, MemoryError> {
    let mut points = fill.chars();
    let (Some(fill), None) = (points.next(), points.next()) else {
        return Err(MemoryError::InvalidPaddingText);
    };
    let width = usize::try_from(width).map_err(|_| MemoryError::PaddingWidthOutOfRange)?;
    if width > MAXIMUM_PADDING_WIDTH {
        return Err(MemoryError::CellLimit);
    }
    let missing = width.saturating_sub(text.chars().count());
    Ok(std::iter::repeat_n(fill, missing).collect())
}
