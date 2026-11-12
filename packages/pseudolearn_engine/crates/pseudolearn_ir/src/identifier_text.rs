pub(crate) fn canonical(name: &str) -> String {
    if !name.is_empty()
        && name
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'.' | b'_'))
    {
        name.to_owned()
    } else {
        format!("{name:?}")
    }
}

pub(crate) fn parse(name: &str) -> Option<String> {
    if !name.starts_with('"') {
        return Some(name.to_owned());
    }
    let tokens = crate::lexer::Lexer::new(name).tokenize().ok()?;
    let crate::lexer::TokenKind::StringLiteral(name) = &tokens.first()?.kind else {
        return None;
    };
    Some(name.clone())
}
