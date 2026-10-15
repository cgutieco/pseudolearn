use crate::expression_checker::{ExpressionPurpose, check_for};
use crate::expression_model::HirExpression;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let operator = session
        .tree
        .operator_tokens
        .get(node)
        .copied()
        .flatten()
        .and_then(|token| usize::try_from(token).ok())
        .and_then(|token| session.tree.tokens.kind(token));
    match operator {
        Some(TokenKind::LeftParenthesis) => crate::call_checker::call(session, node, purpose),
        Some(TokenKind::LeftBracket) => element(session, node),
        Some(TokenKind::Dot) => member(session, node, purpose),
        _ => crate::expression_checker::invalid(session, node),
    }
}

fn element(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let children = session.children(node);
    let target = children.first().copied().unwrap_or(node);
    let array = check_for(session, target, ExpressionPurpose::Argument);
    let indices = children
        .get(1)
        .copied()
        .map(|indices| session.children(indices))
        .unwrap_or_default();
    let indices: Vec<_> = indices
        .into_iter()
        .map(|index| crate::expression_checker::check(session, index))
        .collect();
    for index in &indices {
        if !matches!(
            session.expression_type(*index),
            Type::Integer | Type::Error | Type::Unknown
        ) {
            session.report(DiagnosticCode::NonIntegerArrayIndex, node);
        }
    }
    let kind = match session.expression_type(array) {
        Type::Array { element, rank } => {
            if usize::try_from(rank).ok() != Some(indices.len()) {
                session.report(DiagnosticCode::ArrayDimensionCountMismatch, node);
            }
            element
        }
        Type::Error => session.module.types.intern(Type::Error),
        _ => {
            session.report(DiagnosticCode::ArrayCannotBeUsedAsValue, node);
            session.module.types.intern(Type::Error)
        }
    };
    session.emit(
        HirExpression::Element { array, indices },
        kind,
        session.span(node),
    )
}

fn member(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let children = session.children(node);
    let target = children.first().copied().unwrap_or(node);
    let receiver = crate::expression_checker::check(session, target);
    let name_node = children.get(1).copied().unwrap_or(node);
    let name = session.name(name_node);
    let Type::Object(class) = session.expression_type(receiver) else {
        return crate::expression_checker::invalid(session, node);
    };
    if let Some(arguments) = session.child(node, NodeKind::Arguments) {
        return crate::call_checker::method(
            session,
            crate::call_checker::MethodCall {
                node,
                target,
                receiver,
                class,
                name,
                arguments,
                purpose,
            },
        );
    }
    let Some(field) = resolve_field(session, class, (name_node, &name)) else {
        return crate::expression_checker::invalid(session, node);
    };
    session.emit(
        HirExpression::Field {
            receiver,
            field: field.id,
        },
        field.type_id,
        session.span(node),
    )
}

fn resolve_field(
    session: &mut AnalysisSession<'_>,
    class: crate::identities::ClassId,
    member: (usize, &str),
) -> Option<crate::hir::HirField> {
    let (node, name) = member;
    let Some(field) = crate::hierarchy::find_field(session, class, name) else {
        session.named_report(DiagnosticCode::UndefinedMember, node, name);
        return None;
    };
    if field.private && session.owner() != Some(field.owner) {
        session.named_report(DiagnosticCode::PrivateMemberAccess, node, name);
        crate::diagnostic_arguments::class_name(session, field.owner);
    }
    Some(field)
}
