use crate::cursor_context::CodeToken;
use pseudolearn_syntax::SyntaxTree;

pub fn line_start(text: &str, offset: usize) -> usize {
    text.get(..offset.min(text.len()))
        .and_then(|head| head.rfind('\n'))
        .map_or(0, |index| index.saturating_add(1))
}

pub fn line_end(text: &str, offset: usize) -> usize {
    let from = offset.min(text.len());
    text.get(from..)
        .and_then(|tail| tail.find('\n'))
        .map_or(text.len(), |index| from.saturating_add(index))
}

pub fn previous_line_start(text: &str, start: usize) -> Option<usize> {
    let before = start.checked_sub(1)?;
    Some(line_start(text, before))
}

pub fn indent_width(text: &str, start: usize) -> usize {
    let end = line_end(text, start);
    text.get(start..end)
        .unwrap_or("")
        .chars()
        .take_while(|glyph| *glyph == ' ' || *glyph == '\t')
        .count()
}

pub fn indent_of(text: &str, start: usize) -> &str {
    let width = indent_width(text, start);
    text.get(start..start.saturating_add(width)).unwrap_or("")
}

pub fn is_blank(text: &str, start: usize) -> bool {
    let end = line_end(text, start);
    text.get(start..end)
        .is_some_and(|line| line.trim().is_empty())
}

pub fn line_code_tokens(tree: &SyntaxTree, start: usize, end: usize) -> Vec<CodeToken> {
    let mut found = Vec::new();
    for index in 0..tree.tokens.token_count() {
        let (Some(kind), Some(span)) = (tree.tokens.kind(index), tree.tokens.span(index)) else {
            continue;
        };
        let first = usize::try_from(span.start).unwrap_or(usize::MAX);
        if kind.is_trivia() || kind == pseudolearn_syntax::TokenKind::EndOfFile {
            continue;
        }
        if first >= start && first < end {
            found.push(CodeToken {
                index,
                kind,
                start: first,
            });
        }
    }
    found
}

pub fn token_end(tree: &SyntaxTree, index: usize) -> usize {
    tree.tokens
        .span(index)
        .and_then(|span| usize::try_from(span.ending).ok())
        .unwrap_or(0)
}
