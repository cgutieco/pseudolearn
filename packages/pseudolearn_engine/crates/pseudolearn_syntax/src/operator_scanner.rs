use crate::tokens::TokenKind;

pub fn scan_operator_or_punctuation(slice: &str) -> (TokenKind, usize) {
    if slice.starts_with("<-") || slice.starts_with(":=") {
        return (TokenKind::Assignment, 2);
    }
    if slice.starts_with("<>") || slice.starts_with("!=") {
        return (TokenKind::NotEqual, 2);
    }
    if slice.starts_with("<=") {
        return (TokenKind::LessEqual, 2);
    }
    if slice.starts_with(">=") {
        return (TokenKind::GreaterEqual, 2);
    }
    if slice.starts_with("**") {
        return (TokenKind::Power, 2);
    }
    scan_single_character_punctuation(slice)
}

fn scan_single_character_punctuation(slice: &str) -> (TokenKind, usize) {
    let character = slice.chars().next().unwrap_or('\0');
    let matched = match character {
        '+' => TokenKind::Plus,
        '-' => TokenKind::Minus,
        '*' => TokenKind::Star,
        '/' => TokenKind::Slash,
        '^' => TokenKind::Power,
        '%' => TokenKind::Modulo,
        '=' => TokenKind::Equal,
        '<' => TokenKind::Less,
        '>' => TokenKind::Greater,
        '&' => TokenKind::LogicalAnd,
        '|' => TokenKind::LogicalOr,
        '~' | '!' => TokenKind::LogicalNot,
        '(' => TokenKind::LeftParenthesis,
        ')' => TokenKind::RightParenthesis,
        '[' => TokenKind::LeftBracket,
        ']' => TokenKind::RightBracket,
        ',' => TokenKind::Comma,
        ':' => TokenKind::Colon,
        ';' => TokenKind::Semicolon,
        '.' => TokenKind::Dot,
        _ => TokenKind::InvalidCharacter,
    };
    (matched, character.len_utf8())
}
