use crate::navigation::Position;
use pseudolearn_source::LineIndex;

pub fn offset_at(text: &str, position: Position) -> usize {
    let index = LineIndex::build(text);
    let line_slot = usize::try_from(position.line.saturating_sub(1)).unwrap_or(0);
    let Some(line_start) = index.line_start(line_slot) else {
        return text.len();
    };
    let start = usize::try_from(line_start).unwrap_or(text.len());
    let columns = usize::try_from(position.column.saturating_sub(1)).unwrap_or(0);
    advance_characters(text, start, columns)
}

pub fn position_at(text: &str, offset: usize) -> Position {
    let index = LineIndex::build(text);
    let clamped = u32::try_from(offset.min(text.len())).unwrap_or(u32::MAX);
    let (line, column) = index.line_and_column(text, clamped);
    Position { line, column }
}

pub fn offset_from_lsp(text: &str, line: u32, character: u32) -> usize {
    let index = LineIndex::build(text);
    let slot = usize::try_from(line).unwrap_or(0);
    let Some(line_start) = index.line_start(slot) else {
        return text.len();
    };
    let start = usize::try_from(line_start).unwrap_or(text.len());
    let mut remaining = character;
    let mut offset = start;
    for glyph in text.get(start..).unwrap_or("").chars() {
        if glyph == '\n' || glyph == '\r' || remaining == 0 {
            break;
        }
        let units = u32::try_from(glyph.len_utf16()).unwrap_or(1);
        if units > remaining {
            break;
        }
        remaining = remaining.saturating_sub(units);
        offset = offset.saturating_add(glyph.len_utf8());
    }
    offset
}

pub fn lsp_position_at(text: &str, offset: usize) -> (u32, u32) {
    let position = position_at(text, offset);
    let index = LineIndex::build(text);
    let slot = usize::try_from(position.line.saturating_sub(1)).unwrap_or(0);
    let start = index
        .line_start(slot)
        .and_then(|value| usize::try_from(value).ok())
        .unwrap_or(0);
    let bound = offset.min(text.len());
    let units: usize = text
        .get(start..bound)
        .unwrap_or("")
        .chars()
        .map(char::len_utf16)
        .sum();
    (
        position.line.saturating_sub(1),
        u32::try_from(units).unwrap_or(u32::MAX),
    )
}

fn advance_characters(text: &str, start: usize, count: usize) -> usize {
    let mut offset = start;
    let mut moved = 0usize;
    for glyph in text.get(start..).unwrap_or("").chars() {
        if moved == count || glyph == '\n' || glyph == '\r' {
            break;
        }
        offset = offset.saturating_add(glyph.len_utf8());
        moved = moved.saturating_add(1);
    }
    offset
}
