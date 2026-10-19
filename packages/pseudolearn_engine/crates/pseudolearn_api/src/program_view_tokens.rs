use crate::program_view::ViewNode;
use crate::program_view_annotations::{AnnotationContext, Attributes, first_token};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;
use serde_json::json;

pub(crate) fn binary_identity(kind: TokenKind) -> Option<&'static str> {
    Some(match kind {
        TokenKind::Plus => "add",
        TokenKind::Minus => "subtract",
        TokenKind::Star => "multiply",
        TokenKind::Slash => "divide",
        TokenKind::IntegerDivision => "integer_divide",
        TokenKind::Modulo => "modulo",
        TokenKind::Power => "power",
        TokenKind::Equal => "equal",
        TokenKind::NotEqual => "not_equal",
        TokenKind::Less => "less_than",
        TokenKind::LessEqual => "less_than_or_equal",
        TokenKind::Greater => "greater_than",
        TokenKind::GreaterEqual => "greater_than_or_equal",
        TokenKind::LogicalAnd => "and",
        TokenKind::LogicalOr => "or",
        TokenKind::Keyword(KeywordKind::Modulo) => "modulo",
        TokenKind::Keyword(KeywordKind::IntegerDivide) => "integer_divide",
        TokenKind::Keyword(KeywordKind::And) => "and",
        TokenKind::Keyword(KeywordKind::Or) => "or",
        _ => return None,
    })
}

pub(crate) fn unary_identity(kind: TokenKind) -> Option<&'static str> {
    Some(match kind {
        TokenKind::Minus => "negate",
        TokenKind::Plus => "positive",
        TokenKind::LogicalNot | TokenKind::Keyword(KeywordKind::Not) => "not",
        _ => return None,
    })
}

pub(crate) fn literal_attribute(
    node: &ViewNode,
    context: &AnnotationContext<'_>,
) -> Option<Attributes> {
    let token = first_token(context.tree, node.syntax_index)?;
    let kind = context.tree.tokens.kind(token)?;
    let text = context.tree.tokens.text(context.source.as_str(), token)?;
    let (literal_type, value) = match kind {
        TokenKind::IntegerLiteral => ("integer", text.to_owned()),
        TokenKind::RealLiteral => ("real", text.to_owned()),
        TokenKind::StringLiteral => ("string", unquoted(text)),
        TokenKind::CharacterLiteral => ("character", unquoted(text)),
        TokenKind::BooleanLiteral(flag) => ("boolean", flag.to_string()),
        _ => return None,
    };
    Some(vec![(
        "literal",
        json!({"type": literal_type, "value": value}),
    )])
}

fn unquoted(text: &str) -> String {
    let mut characters = text.chars();
    characters.next();
    characters.next_back();
    characters.as_str().to_owned()
}
