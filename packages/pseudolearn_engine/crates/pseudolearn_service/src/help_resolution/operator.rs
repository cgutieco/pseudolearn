use super::context::smallest_node;
use crate::query_context::QueryContext;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(super) fn operator_context(
    context: &QueryContext<'_>,
    slot: usize,
    id: &str,
) -> (&'static str, Option<Span>) {
    let matching = smallest_node(context, slot, |kind| operator_node(kind, id));
    let Some((node, span)) = matching else {
        return ("operator", None);
    };
    let role = match node {
        NodeKind::AssignmentStatement => "assignment",
        NodeKind::Unary | NodeKind::SignedInteger => "unary",
        _ => "binary",
    };
    (role, Some(span))
}

pub(super) fn operator_identity(kind: TokenKind) -> Option<&'static str> {
    match kind {
        TokenKind::Plus | TokenKind::Keyword(KeywordKind::Plus) => Some("plus"),
        TokenKind::Minus | TokenKind::Keyword(KeywordKind::Minus) => Some("minus"),
        TokenKind::Star | TokenKind::Keyword(KeywordKind::Multiply) => Some("multiply"),
        TokenKind::Slash | TokenKind::Keyword(KeywordKind::Divide) => Some("divide"),
        TokenKind::Power | TokenKind::Keyword(KeywordKind::Power) => Some("power"),
        TokenKind::Modulo | TokenKind::Keyword(KeywordKind::Modulo) => Some("modulo"),
        TokenKind::IntegerDivision | TokenKind::Keyword(KeywordKind::IntegerDivide) => {
            Some("integerDivide")
        }
        TokenKind::Equal | TokenKind::Keyword(KeywordKind::Equal) => Some("equal"),
        TokenKind::NotEqual | TokenKind::Keyword(KeywordKind::NotEqual) => Some("notEqual"),
        TokenKind::Less | TokenKind::Keyword(KeywordKind::LessThan) => Some("lessThan"),
        TokenKind::LessEqual | TokenKind::Keyword(KeywordKind::LessThanOrEqual) => {
            Some("lessThanOrEqual")
        }
        TokenKind::Greater | TokenKind::Keyword(KeywordKind::GreaterThan) => Some("greaterThan"),
        TokenKind::GreaterEqual | TokenKind::Keyword(KeywordKind::GreaterThanOrEqual) => {
            Some("greaterThanOrEqual")
        }
        TokenKind::Keyword(KeywordKind::And) => Some("and"),
        TokenKind::Keyword(KeywordKind::Or) => Some("or"),
        TokenKind::Keyword(KeywordKind::Not) => Some("not"),
        TokenKind::Assignment | TokenKind::Keyword(KeywordKind::Assignment) => Some("assignment"),
        _ => None,
    }
}

pub(super) fn keyword_operator_identity(keyword: KeywordKind) -> Option<&'static str> {
    operator_identity(TokenKind::Keyword(keyword))
}

fn operator_node(kind: NodeKind, id: &str) -> bool {
    match id {
        "assignment" => kind == NodeKind::AssignmentStatement,
        "plus" | "minus" => matches!(
            kind,
            NodeKind::Unary | NodeKind::SignedInteger | NodeKind::Addition
        ),
        "multiply" | "divide" | "integerDivide" | "modulo" => kind == NodeKind::Multiplication,
        "power" => kind == NodeKind::PowerExpression,
        "equal" | "notEqual" => kind == NodeKind::Equality,
        "lessThan" | "lessThanOrEqual" | "greaterThan" | "greaterThanOrEqual" => {
            kind == NodeKind::Ordering
        }
        "and" => kind == NodeKind::Conjunction,
        "or" => kind == NodeKind::Disjunction,
        "not" => kind == NodeKind::Unary,
        _ => false,
    }
}
