use crate::model::{ApiPosition, ApiSpan, ApiToken};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{SyntaxTree, TokenKind};

pub(crate) fn convert(tree: &SyntaxTree, source: &SourceText) -> Vec<ApiToken> {
    (0..tree.tokens.token_count())
        .filter_map(|index| {
            let kind = tree.tokens.kind(index)?;
            let span = tree.tokens.span(index)?;
            Some(ApiToken {
                kind: token_name(kind).to_owned(),
                keyword: keyword_name(kind).map(str::to_owned),
                span: convert_span(span, source),
            })
        })
        .collect()
}

fn token_name(kind: TokenKind) -> &'static str {
    match kind {
        TokenKind::Whitespace => "whitespace",
        TokenKind::Comment => "comment",
        TokenKind::Newline => "newline",
        TokenKind::InvalidCharacter => "invalid_character",
        TokenKind::EndOfFile => "end_of_file",
        TokenKind::Identifier => "identifier",
        TokenKind::IntegerLiteral => "integer_literal",
        TokenKind::RealLiteral => "real_literal",
        TokenKind::StringLiteral => "string_literal",
        TokenKind::CharacterLiteral => "character_literal",
        TokenKind::BooleanLiteral(_) => "boolean_literal",
        TokenKind::Keyword(_) => "keyword",
        TokenKind::Plus | TokenKind::Minus | TokenKind::Star | TokenKind::Slash => "operator",
        TokenKind::Power
        | TokenKind::Modulo
        | TokenKind::IntegerDivision
        | TokenKind::Equal
        | TokenKind::NotEqual
        | TokenKind::Less
        | TokenKind::LessEqual
        | TokenKind::Greater
        | TokenKind::GreaterEqual
        | TokenKind::LogicalAnd
        | TokenKind::LogicalOr
        | TokenKind::LogicalNot
        | TokenKind::Assignment => "operator",
        TokenKind::LeftParenthesis
        | TokenKind::RightParenthesis
        | TokenKind::LeftBracket
        | TokenKind::RightBracket
        | TokenKind::Comma
        | TokenKind::Colon
        | TokenKind::Semicolon
        | TokenKind::Dot => "punctuation",
    }
}

fn keyword_name(kind: TokenKind) -> Option<&'static str> {
    match kind {
        TokenKind::Keyword(keyword) => Some(keyword.as_str()),
        _ => None,
    }
}

fn convert_span(span: Span, source: &SourceText) -> ApiSpan {
    let start = source.line_and_column(span.start);
    let end = source.line_and_column(span.ending);
    ApiSpan {
        start: ApiPosition {
            line: start.0,
            column: start.1,
        },
        end: ApiPosition {
            line: end.0,
            column: end.1,
        },
    }
}
