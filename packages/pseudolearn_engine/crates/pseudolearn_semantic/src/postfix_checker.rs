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
        Some(TokenKind::Dot) => dotted(session, node, purpose),
        _ => crate::expression_checker::invalid(session, node),
    }
}

fn dotted(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    if let Some(member) = crate::enum_access::expression(session, node) {
        return member;
    }
    if let Some(call) = crate::module_calls::call(session, node, purpose) {
        return call;
    }
    member(session, node, purpose)
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
    if let Some(model) = crate::collection_types::get(session, &session.expression_type(array)) {
        return crate::collection_checker::element(session, node, (array, model), &indices);
    }
    let indices: Vec<_> = indices
        .into_iter()
        .map(|index| crate::expression_checker::check(session, index))
        .collect();
    check_indices(session, &indices, node);
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
    if let Some(value) = crate::effect_checker::check(session, node, Some(receiver), purpose) {
        return value;
    }
    if let Some(value) = crate::collection_checker::member(session, node, receiver, purpose) {
        return value;
    }
    let name_node = children.get(1).copied().unwrap_or(node);
    match session.expression_type(receiver) {
        Type::Record(record) => {
            if let Some(call) = crate::interface_constraints::call(session, node, record, purpose) {
                return call;
            }
            let field = crate::record_access::field(session, node, (receiver, record, name_node));
            if session.child(node, NodeKind::Arguments).is_some() {
                crate::function_calls::call(session, node, (field, purpose))
            } else {
                field
            }
        }
        Type::Object(class) => object_member(
            session,
            node,
            (target, receiver, class),
            (name_node, purpose),
        ),
        _ => crate::expression_checker::invalid(session, node),
    }
}

fn object_member(
    session: &mut AnalysisSession<'_>,
    node: usize,
    parts: (usize, ExpressionId, crate::identities::ClassId),
    member: (usize, ExpressionPurpose),
) -> ExpressionId {
    let (target, receiver, class) = parts;
    let (name_node, purpose) = member;
    let name = session.name(name_node);
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

fn check_indices(session: &mut AnalysisSession<'_>, indices: &[ExpressionId], node: usize) {
    for index in indices {
        if !matches!(
            session.expression_type(*index),
            Type::Integer | Type::Error | Type::Unknown
        ) {
            session.report(DiagnosticCode::NonIntegerArrayIndex, node);
        }
    }
}
