#![forbid(unsafe_code)]

pub(crate) fn end_of_text(text: &str) -> (usize, usize) {
    let line = text.matches('\n').count().saturating_add(1);
    let last_line = text.rsplit('\n').next().unwrap_or_default();
    (line, last_line.chars().count().saturating_add(1))
}

pub(crate) fn code_point_position(text: &str, line: usize, byte_column: usize) -> (usize, usize) {
    let line = line.max(1);
    let line_text = text
        .split('\n')
        .nth(line.saturating_sub(1))
        .unwrap_or_default();
    let byte_offset = byte_column.saturating_sub(1).min(line_text.len());
    let preceding = line_text
        .char_indices()
        .take_while(|(index, character)| index.saturating_add(character.len_utf8()) <= byte_offset)
        .count();
    (line, preceding.saturating_add(1))
}
