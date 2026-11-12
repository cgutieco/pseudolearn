use crate::constant_arithmetic::{binary, invert, keep_sign, negate};
use crate::constant_evaluator::{Failure, Value, ensure};
use crate::constant_registry::find_in;
use crate::expression_model::{BinaryOperator, Literal};
use crate::identities::FunctionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) struct Budget {
    pub steps: u32,
    pub text_bytes: usize,
}

#[derive(Clone, Copy)]
pub(crate) struct Context {
    pub scope: Option<FunctionId>,
    pub depth: usize,
}

pub(crate) fn evaluate(
    session: &mut AnalysisSession<'_>,
    node: usize,
    context: Context,
    budget: &mut Budget,
) -> Result<Value, Failure> {
    budget.steps = budget.steps.checked_sub(1).ok_or(Failure::Budget)?;
    match session.kind(node) {
        NodeKind::Primary => match session.children(node).first().copied() {
            Some(child) => evaluate(session, child, context, budget),
            None => Err(Failure::NotEvaluable),
        },
        NodeKind::Literal => literal(session, node, budget),
        NodeKind::Unary => unary(session, node, context, budget),
        NodeKind::Conjunction | NodeKind::Disjunction => logical(session, node, context, budget),
        NodeKind::Addition
        | NodeKind::Multiplication
        | NodeKind::PowerExpression
        | NodeKind::Equality
        | NodeKind::Ordering => operation(session, node, context, budget),
        NodeKind::Identifier => reference(session, node, context),
        NodeKind::Postfix => member(session, node),
        _ => Err(Failure::NotEvaluable),
    }
}

fn literal(session: &AnalysisSession<'_>, node: usize, budget: &Budget) -> Result<Value, Failure> {
    let text = session.lexeme(node);
    match session.token_kind(node) {
        Some(TokenKind::IntegerLiteral) => text
            .parse::<i64>()
            .map(|integer| (Literal::Integer(integer), Type::Integer))
            .map_err(|_| Failure::Overflow),
        Some(TokenKind::RealLiteral) => text
            .parse::<f64>()
            .ok()
            .filter(|real| real.is_finite())
            .map(|real| (Literal::Real(real), Type::Real))
            .ok_or(Failure::Overflow),
        Some(TokenKind::BooleanLiteral(flag)) => Ok((Literal::Boolean(flag), Type::Boolean)),
        Some(TokenKind::CharacterLiteral) => {
            let decoded = pseudolearn_syntax::scan_literal(text).content;
            Ok((
                Literal::Character(decoded.chars().next().unwrap_or('\0')),
                Type::Character,
            ))
        }
        _ => {
            let decoded = pseudolearn_syntax::scan_literal(text).content;
            if decoded.len() > budget.text_bytes {
                return Err(Failure::Budget);
            }
            Ok((Literal::String(decoded), Type::String))
        }
    }
}

fn unary(
    session: &mut AnalysisSession<'_>,
    node: usize,
    context: Context,
    budget: &mut Budget,
) -> Result<Value, Failure> {
    let child = session
        .children(node)
        .first()
        .copied()
        .ok_or(Failure::NotEvaluable)?;
    let operand = evaluate(session, child, context, budget)?;
    match session.token_kind(node) {
        Some(TokenKind::Minus) => negate(operand),
        Some(TokenKind::LogicalNot | TokenKind::Keyword(KeywordKind::Not)) => invert(operand),
        _ => keep_sign(operand),
    }
}

fn operation(
    session: &mut AnalysisSession<'_>,
    node: usize,
    context: Context,
    budget: &mut Budget,
) -> Result<Value, Failure> {
    let children = session.children(node);
    let (Some(left), Some(right)) = (children.first().copied(), children.get(1).copied()) else {
        return Err(Failure::NotEvaluable);
    };
    let operator = crate::operator_tokens::operator(session.operator_kind(node));
    let first = evaluate(session, left, context, budget)?;
    let second = evaluate(session, right, context, budget)?;
    binary(operator, (first, second), budget.text_bytes)
}

fn logical(
    session: &mut AnalysisSession<'_>,
    node: usize,
    context: Context,
    budget: &mut Budget,
) -> Result<Value, Failure> {
    let children = session.children(node);
    let (Some(left), Some(right)) = (children.first().copied(), children.get(1).copied()) else {
        return Err(Failure::NotEvaluable);
    };
    let conjunction =
        crate::operator_tokens::operator(session.operator_kind(node)) == BinaryOperator::LogicalAnd;
    let (Literal::Boolean(first), Type::Boolean) = evaluate(session, left, context, budget)? else {
        return Err(Failure::NotEvaluable);
    };
    if first != conjunction {
        return Ok((Literal::Boolean(first), Type::Boolean));
    }
    match evaluate(session, right, context, budget)? {
        (Literal::Boolean(second), Type::Boolean) => Ok((Literal::Boolean(second), Type::Boolean)),
        _ => Err(Failure::NotEvaluable),
    }
}

fn reference(
    session: &mut AnalysisSession<'_>,
    node: usize,
    context: Context,
) -> Result<Value, Failure> {
    let name = session.name(node);
    let index = find_in(session, context.scope, &name).ok_or(Failure::NotEvaluable)?;
    ensure(session, index, context.depth.saturating_add(1))
}

fn member(session: &mut AnalysisSession<'_>, node: usize) -> Result<Value, Failure> {
    let children = session.children(node);
    let (Some(target), Some(name_node)) = (children.first().copied(), children.get(1).copied())
    else {
        return Err(Failure::NotEvaluable);
    };
    if session.operator_kind(node) != Some(TokenKind::Dot)
        || session.child(node, NodeKind::Arguments).is_some()
    {
        return Err(Failure::NotEvaluable);
    }
    match crate::enum_access::lookup(session, target, name_node) {
        Some(Ok((enumeration, ordinal))) => Ok((
            Literal::Integer(i64::from(ordinal)),
            Type::Enum(enumeration),
        )),
        Some(Err(())) => Err(Failure::Silent),
        None => Err(Failure::NotEvaluable),
    }
}
