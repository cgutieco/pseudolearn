use crate::expression_model::{HirExpression, HirPlace, Literal};
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_syntax::{NodeKind, TokenKind};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum ExpressionPurpose {
    Value,
    Destination,
    Argument,
    Statement,
}

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    check_for(session, node, ExpressionPurpose::Value)
}

pub(crate) fn check_for(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    match session.kind(node) {
        NodeKind::FunctionLiteral => crate::closure_checker::check(session, node),
        NodeKind::VariantConstruction => crate::variant_checker::check(session, node, None),
        NodeKind::Propagation => crate::variant_checker::propagation(session, node),
        NodeKind::AwaitExpression => crate::await_checker::check(session, node, purpose),
        NodeKind::SpawnExpression => crate::task_handles::spawn(session, node, purpose),
        NodeKind::Identifier => crate::name_resolution::local(session, node, purpose),
        NodeKind::Literal => literal(session, node),
        NodeKind::Unary => crate::operators::unary(session, node),
        NodeKind::Addition
        | NodeKind::Multiplication
        | NodeKind::PowerExpression
        | NodeKind::Equality
        | NodeKind::Ordering
        | NodeKind::Conjunction
        | NodeKind::Disjunction => crate::operators::binary(session, node),
        NodeKind::Primary => session
            .tree
            .child_indices(node)
            .first()
            .copied()
            .map(|child| check_for(session, child, purpose))
            .unwrap_or_else(|| invalid(session, node)),
        NodeKind::Instantiation => crate::call_checker::instantiate(session, node),
        NodeKind::Postfix => crate::postfix_checker::check(session, node, purpose),
        NodeKind::ThisObject | NodeKind::SuperClass => receiver(session, node),
        _ => invalid(session, node),
    }
}

pub(crate) fn invalid(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let kind = session.module.types.intern(Type::Error);
    session.emit(HirExpression::Invalid, kind, session.span(node))
}

fn literal(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let text = session.lexeme(node).to_owned();
    let (literal, kind) = match session.token_kind(node) {
        Some(TokenKind::IntegerLiteral) => {
            (Literal::Integer(text.parse().unwrap_or(0)), Type::Integer)
        }
        Some(TokenKind::RealLiteral) => (Literal::Real(text.parse().unwrap_or(0.0)), Type::Real),
        Some(TokenKind::BooleanLiteral(value)) => (Literal::Boolean(value), Type::Boolean),
        Some(TokenKind::CharacterLiteral) => {
            let decoded = pseudolearn_syntax::scan_literal(&text).content;
            (
                Literal::Character(decoded.chars().next().unwrap_or('\0')),
                Type::Character,
            )
        }
        _ => (
            Literal::String(pseudolearn_syntax::scan_literal(&text).content),
            Type::String,
        ),
    };
    let kind = session.module.types.intern(kind);
    session.emit(HirExpression::Literal(literal), kind, session.span(node))
}

fn receiver(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let Some(class) = session.owner() else {
        return invalid(session, node);
    };
    let class = if session.kind(node) == NodeKind::SuperClass {
        crate::hierarchy::class_model(session, class)
            .and_then(|class| class.superclass)
            .unwrap_or(class)
    } else {
        class
    };
    let kind = session.module.types.intern(Type::Object(class));
    session.emit(HirExpression::This(class), kind, session.span(node))
}

pub(crate) fn place(session: &AnalysisSession<'_>, expression: ExpressionId) -> Option<HirPlace> {
    let kind = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index))?;
    match kind {
        HirExpression::Local(local)
            if matches!(session.expression_type(expression), Type::Array { .. }) =>
        {
            Some(HirPlace::WholeArray(*local))
        }
        HirExpression::Local(local) => Some(HirPlace::Local(*local)),
        HirExpression::Field { receiver, field } => Some(HirPlace::Field {
            receiver: *receiver,
            field: *field,
        }),
        HirExpression::Element { array, indices } => Some(HirPlace::Element {
            array: *array,
            indices: indices.clone(),
        }),
        HirExpression::RecordField { .. } => crate::record_access::place(session, expression),
        _ => None,
    }
}

pub(crate) fn widen(
    session: &mut AnalysisSession<'_>,
    expression: ExpressionId,
    target: &Type,
) -> ExpressionId {
    if *target != Type::Real || session.expression_type(expression) != Type::Integer {
        return expression;
    }
    let kind = session.module.types.intern(Type::Real);
    let span = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .copied()
        .unwrap_or_default();
    session.emit(HirExpression::Widen(expression), kind, span)
}

pub(crate) fn check_expected(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: crate::identities::TypeId,
) -> ExpressionId {
    check_expected_for(session, node, expected, ExpressionPurpose::Value)
}

pub(crate) fn check_expected_for(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: crate::identities::TypeId,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    if let Some(value) = crate::collection_checker::construct(session, node, expected) {
        return value;
    }
    if crate::variant_checker::is_construction(session, node) {
        crate::variant_checker::check(session, node, Some(expected))
    } else if session.kind(node) == NodeKind::Primary {
        session
            .children(node)
            .first()
            .copied()
            .map(|child| check_expected_for(session, child, expected, purpose))
            .unwrap_or_else(|| invalid(session, node))
    } else {
        check_for(session, node, purpose)
    }
}
