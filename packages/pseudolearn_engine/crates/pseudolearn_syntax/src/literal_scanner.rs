pub fn scan_line_comment(slice: &str) -> usize {
    let mut consumed_bytes: usize = 2;
    let after_prefix = slice.get(2..).unwrap_or("");
    for character in after_prefix.chars() {
        if character == '\n' || character == '\r' {
            break;
        }
        consumed_bytes = consumed_bytes.saturating_add(character.len_utf8());
    }
    consumed_bytes
}

pub fn scan_block_comment(slice: &str) -> (usize, bool) {
    let mut consumed_bytes: usize = 2;
    let mut closed = false;
    let mut remainder = slice.get(2..).unwrap_or("");
    while !remainder.is_empty() {
        if remainder.starts_with("*/") {
            consumed_bytes = consumed_bytes.saturating_add(2);
            closed = true;
            break;
        }
        let character = match remainder.chars().next() {
            Some(character) => character,
            None => break,
        };
        let advance: usize = character.len_utf8();
        consumed_bytes = consumed_bytes.saturating_add(advance);
        remainder = remainder.get(advance..).unwrap_or("");
    }
    (consumed_bytes, closed)
}

pub fn scan_string_literal(slice: &str) -> (usize, bool) {
    let mut consumed_bytes: usize = 1;
    let mut closed = false;
    let mut remainder = slice.get(1..).unwrap_or("");
    while let Some(character) = remainder.chars().next() {
        if character == '\\' {
            let advance: usize = character.len_utf8();
            consumed_bytes = consumed_bytes.saturating_add(advance);
            remainder = remainder.get(advance..).unwrap_or("");
            if let Some(escaped) = remainder.chars().next() {
                let escaped_advance: usize = escaped.len_utf8();
                consumed_bytes = consumed_bytes.saturating_add(escaped_advance);
                remainder = remainder.get(escaped_advance..).unwrap_or("");
            }
            continue;
        }
        if character == '"' {
            consumed_bytes = consumed_bytes.saturating_add(1);
            closed = true;
            break;
        }
        if character == '\n' || character == '\r' {
            break;
        }
        let advance: usize = character.len_utf8();
        consumed_bytes = consumed_bytes.saturating_add(advance);
        remainder = remainder.get(advance..).unwrap_or("");
    }
    (consumed_bytes, closed)
}

pub fn scan_character_literal(slice: &str) -> (usize, bool) {
    let mut consumed_bytes: usize = 1;
    let mut closed = false;
    let mut remainder = slice.get(1..).unwrap_or("");
    while let Some(character) = remainder.chars().next() {
        if character == '\'' {
            consumed_bytes = consumed_bytes.saturating_add(1);
            closed = true;
            break;
        }
        if character == '\n' || character == '\r' {
            break;
        }
        let advance: usize = character.len_utf8();
        consumed_bytes = consumed_bytes.saturating_add(advance);
        remainder = remainder.get(advance..).unwrap_or("");
    }
    (consumed_bytes, closed)
}

pub fn scan_numeric_literal(slice: &str) -> (usize, bool) {
    let mut consumed_bytes: usize = count_digits(slice);
    let mut is_real = false;
    let mut remainder = slice.get(consumed_bytes..).unwrap_or("");
    if remainder.starts_with('.') {
        let after_dot = remainder.get(1..).unwrap_or("");
        if after_dot
            .chars()
            .next()
            .is_some_and(|digit_char| digit_char.is_ascii_digit())
        {
            is_real = true;
            consumed_bytes = consumed_bytes.saturating_add(1);
            let fractional_bytes: usize = count_digits(after_dot);
            consumed_bytes = consumed_bytes.saturating_add(fractional_bytes);
            remainder = slice.get(consumed_bytes..).unwrap_or("");
        }
    }
    if remainder.starts_with('e') || remainder.starts_with('E') {
        is_real = true;
        let mut exponent_bytes: usize = 1;
        let after_exponent = remainder.get(1..).unwrap_or("");
        let first_sign = after_exponent.chars().next();
        let digits_start = if first_sign == Some('+') || first_sign == Some('-') {
            exponent_bytes = exponent_bytes.saturating_add(1);
            after_exponent.get(1..).unwrap_or("")
        } else {
            after_exponent
        };
        let exponent_digit_bytes: usize = count_digits(digits_start);
        exponent_bytes = exponent_bytes.saturating_add(exponent_digit_bytes);
        consumed_bytes = consumed_bytes.saturating_add(exponent_bytes);
    }
    (consumed_bytes, is_real)
}

fn count_digits(slice: &str) -> usize {
    let mut digit_bytes: usize = 0;
    for character in slice.chars() {
        if character.is_ascii_digit() {
            digit_bytes = digit_bytes.saturating_add(character.len_utf8());
        } else {
            break;
        }
    }
    digit_bytes
}
