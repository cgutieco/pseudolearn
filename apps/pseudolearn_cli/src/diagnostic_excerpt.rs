#![forbid(unsafe_code)]

const WINDOW_WIDTH: usize = 80;
const HALF_WINDOW: usize = 40;
const TAB_WIDTH: usize = 4;
const ELLIPSIS: char = '…';
const GUTTER_PADDING: usize = 5;

pub fn excerpt(source: &str, line: u32, column: u32) -> String {
    let Some(text) = line_text(source, line) else {
        return String::new();
    };
    let (cells, caret) = expand_tabs(text, column);
    let (visible, caret) = window(cells, caret);
    let number = line.to_string();
    let blank = " ".repeat(GUTTER_PADDING.saturating_add(number.len()));
    format!(
        "    {number} | {visible}\n{blank}| {}^\n",
        " ".repeat(caret)
    )
}

fn line_text(source: &str, line: u32) -> Option<&str> {
    let index = usize::try_from(line.checked_sub(1)?).ok()?;
    source
        .split('\n')
        .nth(index)
        .map(|text| text.strip_suffix('\r').unwrap_or(text))
}

fn expand_tabs(text: &str, column: u32) -> (Vec<char>, usize) {
    let target = usize::try_from(column.saturating_sub(1)).unwrap_or(0);
    let mut cells = Vec::new();
    let mut caret = None;
    for (index, character) in text.chars().enumerate() {
        if index == target {
            caret = Some(cells.len());
        }
        if character == '\t' {
            cells.extend(std::iter::repeat_n(' ', TAB_WIDTH));
        } else {
            cells.push(character);
        }
    }
    let caret = caret.unwrap_or(cells.len());
    (cells, caret)
}

fn window(cells: Vec<char>, caret: usize) -> (String, usize) {
    let total = cells.len();
    if total <= WINDOW_WIDTH {
        return (cells.into_iter().collect(), caret);
    }
    let start = caret
        .saturating_sub(HALF_WINDOW)
        .min(total.saturating_sub(WINDOW_WIDTH));
    let end = start.saturating_add(WINDOW_WIDTH);
    let mut shown: Vec<char> = cells.get(start..end).unwrap_or(&[]).to_vec();
    if start > 0
        && let Some(first) = shown.first_mut()
    {
        *first = ELLIPSIS;
    }
    if end < total
        && let Some(last) = shown.last_mut()
    {
        *last = ELLIPSIS;
    }
    (shown.into_iter().collect(), caret.saturating_sub(start))
}

#[cfg(test)]
#[path = "diagnostic_excerpt_tests.rs"]
mod diagnostic_excerpt_tests;
