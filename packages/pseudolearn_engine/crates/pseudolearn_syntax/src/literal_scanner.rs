#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ScannedLiteral {
    pub bytes: usize,
    pub content: String,
    pub closed: bool,
    pub invalid_escape: Option<(usize, String)>,
}

pub fn scan_literal(slice: &str) -> ScannedLiteral {
    let mut result = ScannedLiteral {
        bytes: 1,
        content: String::new(),
        closed: false,
        invalid_escape: None,
    };
    let mut characters = slice.char_indices();
    let Some((_, delimiter)) = characters.next() else {
        result.bytes = 0;
        return result;
    };
    while let Some((offset, character)) = characters.next() {
        if character == '\n' || character == '\r' {
            result.bytes = offset;
            break;
        }
        result.bytes = offset.saturating_add(character.len_utf8());
        if character == delimiter {
            result.closed = true;
            break;
        }
        if character != '\\' {
            result.content.push(character);
            continue;
        }
        decode_escape(&mut characters, &mut result, offset);
    }
    result
}

fn decode_escape(
    characters: &mut std::str::CharIndices<'_>,
    result: &mut ScannedLiteral,
    offset: usize,
) {
    let Some((position, escaped)) = characters.next() else {
        return;
    };
    result.bytes = position.saturating_add(escaped.len_utf8());
    let decoded = match escaped {
        'n' => '\n',
        'r' => '\r',
        't' => '\t',
        '\\' => '\\',
        '\'' => '\'',
        '"' => '"',
        other => {
            result
                .invalid_escape
                .get_or_insert_with(|| (offset, format!("\\{other}")));
            other
        }
    };
    result.content.push(decoded);
}

pub fn scan_line_comment(slice: &str) -> usize {
    slice.find(['\n', '\r']).unwrap_or(slice.len())
}

pub fn scan_block_comment(slice: &str) -> (usize, bool) {
    slice
        .get(2..)
        .and_then(|suffix| suffix.find("*/"))
        .map_or((slice.len(), false), |position| {
            (position.saturating_add(4), true)
        })
}

pub fn scan_numeric_literal(slice: &str) -> (usize, bool) {
    let mut bytes = slice.bytes().take_while(u8::is_ascii_digit).count();
    let suffix = slice.get(bytes..).unwrap_or("");
    if suffix.starts_with('.') && suffix.as_bytes().get(1).is_some_and(u8::is_ascii_digit) {
        bytes = bytes.saturating_add(1).saturating_add(
            suffix
                .bytes()
                .skip(1)
                .take_while(u8::is_ascii_digit)
                .count(),
        );
        return (bytes, true);
    }
    (bytes, false)
}
