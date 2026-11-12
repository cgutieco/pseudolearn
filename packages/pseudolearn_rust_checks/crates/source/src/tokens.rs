pub fn comment_lines(text: &str) -> Vec<usize> {
    let mut offset = 0usize;
    let mut lines = Vec::new();
    for token in ra_ap_rustc_lexer::tokenize(text, ra_ap_rustc_lexer::FrontmatterAllowed::No) {
        if matches!(
            token.kind,
            ra_ap_rustc_lexer::TokenKind::LineComment { .. }
                | ra_ap_rustc_lexer::TokenKind::BlockComment { .. }
        ) {
            let prefix = text.get(..offset).unwrap_or_default();
            lines.push(
                prefix
                    .bytes()
                    .filter(|byte| *byte == b'\n')
                    .count()
                    .saturating_add(1),
            );
        }
        offset = offset.saturating_add(usize::try_from(token.len).unwrap_or_default());
    }
    lines
}

pub fn word_lines(text: &str, word: &str) -> Vec<usize> {
    let mut offset = 0usize;
    let mut lines = Vec::new();
    for token in ra_ap_rustc_lexer::tokenize(text, ra_ap_rustc_lexer::FrontmatterAllowed::No) {
        let end = offset.saturating_add(usize::try_from(token.len).unwrap_or_default());
        if matches!(token.kind, ra_ap_rustc_lexer::TokenKind::Ident)
            && text.get(offset..end) == Some(word)
        {
            let prefix = text.get(..offset).unwrap_or_default();
            lines.push(
                prefix
                    .bytes()
                    .filter(|byte| *byte == b'\n')
                    .count()
                    .saturating_add(1),
            );
        }
        offset = end;
    }
    lines
}
