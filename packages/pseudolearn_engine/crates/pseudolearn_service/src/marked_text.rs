use crate::navigation::Position;
use crate::positions::position_at;

pub const CURSOR_MARKER: char = '|';

pub fn split_cursor(marked: &str) -> (String, Position) {
    let offset = marked.find(CURSOR_MARKER).unwrap_or(marked.len());
    let clean = marked.replacen(CURSOR_MARKER, "", 1);
    let position = position_at(&clean, offset);
    (clean, position)
}
