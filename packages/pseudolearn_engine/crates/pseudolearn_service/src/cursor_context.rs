use crate::block_layout::{is_closer, is_opener};
use crate::expected_slot::{ExpectedSlot, expected_slot};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind};

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum CursorKind {
    Inert,
    Member { receiver: Receiver },
    TypeSlot,
    StatementStart,
    Expression,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Receiver {
    Named(String),
    CurrentObject,
    Unknown,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct CursorContext {
    pub kind: CursorKind,
    pub prefix: String,
    pub prefix_start: usize,
    pub open_blocks: Vec<KeywordKind>,
    pub line_tokens: Vec<TokenKind>,
    pub previous: Option<TokenKind>,
    pub expected: ExpectedSlot,
}

pub fn analyze_cursor(tree: &SyntaxTree, source: &SourceText, offset: usize) -> CursorContext {
    let text = source.as_str();
    let (prefix, prefix_start, inert) = locate_prefix(tree, text, offset);
    let code = code_tokens_before(tree, prefix_start);
    let previous = code.last().map(|entry| entry.kind);
    let line_start = text
        .get(..prefix_start)
        .and_then(|head| head.rfind('\n'))
        .map_or(0, |index| index.saturating_add(1));
    let line_code: Vec<&CodeToken> = code
        .iter()
        .filter(|entry| entry.start >= line_start)
        .collect();
    let line_tokens: Vec<TokenKind> = line_code.iter().map(|entry| entry.kind).collect();
    let kind = if inert {
        CursorKind::Inert
    } else {
        classify(
            (tree, text),
            &code,
            Situation {
                previous,
                at_line_start: line_tokens.is_empty(),
            },
        )
    };
    CursorContext {
        kind,
        prefix,
        prefix_start,
        open_blocks: open_blocks(&code),
        expected: expected_slot(tree, text, &line_code),
        line_tokens,
        previous,
    }
}

pub struct CodeToken {
    pub index: usize,
    pub kind: TokenKind,
    pub start: usize,
}

fn code_tokens_before(tree: &SyntaxTree, limit: usize) -> Vec<CodeToken> {
    let mut found = Vec::new();
    for index in 0..tree.tokens.token_count() {
        let (Some(kind), Some(span)) = (tree.tokens.kind(index), tree.tokens.span(index)) else {
            continue;
        };
        let start = usize::try_from(span.start).unwrap_or(usize::MAX);
        let ending = usize::try_from(span.ending).unwrap_or(usize::MAX);
        if kind.is_trivia() {
            continue;
        }
        if kind == TokenKind::EndOfFile || ending > limit {
            continue;
        }
        found.push(CodeToken { index, kind, start });
    }
    found
}

fn locate_prefix(tree: &SyntaxTree, text: &str, offset: usize) -> (String, usize, bool) {
    for index in 0..tree.tokens.token_count() {
        let (Some(kind), Some(span)) = (tree.tokens.kind(index), tree.tokens.span(index)) else {
            continue;
        };
        let start = usize::try_from(span.start).unwrap_or(usize::MAX);
        let ending = usize::try_from(span.ending).unwrap_or(usize::MAX);
        if start >= offset || offset > ending {
            continue;
        }
        let token_text = text.get(start..ending).unwrap_or("");
        match kind {
            TokenKind::Comment => return (String::new(), offset, true),
            TokenKind::StringLiteral | TokenKind::CharacterLiteral if offset < ending => {
                return (String::new(), offset, true);
            }
            TokenKind::InvalidCharacter
                if token_text.starts_with('"') || token_text.starts_with('\'') =>
            {
                return (String::new(), offset, true);
            }
            TokenKind::Identifier | TokenKind::Keyword(_) | TokenKind::BooleanLiteral(_) => {
                let typed = text.get(start..offset).unwrap_or("").to_owned();
                return (typed, start, false);
            }
            _ => {}
        }
    }
    (String::new(), offset, false)
}

struct Situation {
    previous: Option<TokenKind>,
    at_line_start: bool,
}

fn classify(document: (&SyntaxTree, &str), code: &[CodeToken], situation: Situation) -> CursorKind {
    let (tree, text) = document;
    if situation.at_line_start && !matches!(situation.previous, Some(TokenKind::Dot)) {
        return CursorKind::StatementStart;
    }
    match situation.previous {
        Some(TokenKind::Dot) => CursorKind::Member {
            receiver: receiver_before_dot(tree, text, code),
        },
        Some(TokenKind::Keyword(KeywordKind::TypeConnector)) => CursorKind::TypeSlot,
        None => CursorKind::StatementStart,
        Some(
            TokenKind::Semicolon
            | TokenKind::Colon
            | TokenKind::Keyword(
                KeywordKind::Then
                | KeywordKind::DoKeyword
                | KeywordKind::ElseKeyword
                | KeywordKind::Repeat,
            ),
        ) => CursorKind::StatementStart,
        Some(_) => CursorKind::Expression,
    }
}

fn receiver_before_dot(tree: &SyntaxTree, text: &str, code: &[CodeToken]) -> Receiver {
    let Some(before) = code.len().checked_sub(2).and_then(|slot| code.get(slot)) else {
        return Receiver::Unknown;
    };
    match before.kind {
        TokenKind::Identifier => tree
            .tokens
            .text(text, before.index)
            .map_or(Receiver::Unknown, |name| Receiver::Named(name.to_owned())),
        TokenKind::Keyword(KeywordKind::ThisObject) => Receiver::CurrentObject,
        _ => Receiver::Unknown,
    }
}

fn open_blocks(code: &[CodeToken]) -> Vec<KeywordKind> {
    let mut stack = Vec::new();
    for entry in code {
        let TokenKind::Keyword(kind) = entry.kind else {
            continue;
        };
        if is_opener(kind) {
            stack.push(kind);
        } else if is_closer(kind) {
            stack.pop();
        }
    }
    stack
}
