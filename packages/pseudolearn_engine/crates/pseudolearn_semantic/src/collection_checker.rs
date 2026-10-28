use crate::collection_model::{CollectionAction, CollectionExpression, HirCollection};
use crate::expression_checker::{ExpressionPurpose, check_expected_for};
use crate::identities::{ExpressionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn construct(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: TypeId,
) -> Option<ExpressionId> {
    if session.kind(node) != NodeKind::Postfix {
        return None;
    }
    let children = session.children(node);
    let target = children.first().copied()?;
    if session.kind(target) != NodeKind::Identifier {
        return None;
    }
    let identity = crate::collection_types::identity(session, &session.name(target))?;
    if !matches!(identity, "vectorType" | "dictionaryType") {
        return None;
    }
    if session.module.types.get(expected) == Type::Error {
        return Some(crate::expression_checker::invalid(session, node));
    }
    let model = crate::collection_types::get(session, &session.module.types.get(expected))?;
    if model.key.is_some() != (identity == "dictionaryType") {
        return None;
    }
    let arguments = session
        .child(node, NodeKind::Arguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    if !arguments.is_empty() {
        crate::argument_checker::arity(session, (0, arguments.len()), node);
    }
    Some(emit(
        session,
        node,
        (model.class, expected),
        (CollectionAction::New, None, Vec::new()),
    ))
}

pub(crate) fn member(
    session: &mut AnalysisSession<'_>,
    node: usize,
    receiver: ExpressionId,
    purpose: ExpressionPurpose,
) -> Option<ExpressionId> {
    let model = crate::collection_types::get(session, &session.expression_type(receiver))?;
    let name_node = session.children(node).get(1).copied().unwrap_or(node);
    let identity = crate::collection_types::identity(session, &session.name(name_node));
    let action = match identity {
        Some("collectionLength") => CollectionAction::Length,
        Some("vectorAppend") if model.key.is_none() => CollectionAction::Append,
        Some("vectorInsert") if model.key.is_none() => CollectionAction::Insert,
        Some("collectionRemove") => CollectionAction::Remove,
        Some("dictionaryFind") if model.key.is_some() => CollectionAction::Find,
        _ => {
            session.named_report(
                DiagnosticCode::UndefinedMember,
                name_node,
                &session.name(name_node),
            );
            return Some(crate::expression_checker::invalid(session, node));
        }
    };
    if matches!(session.expression_type(receiver), Type::Immutable(_))
        && !matches!(action, CollectionAction::Length | CollectionAction::Find)
    {
        session.report(DiagnosticCode::ImmutableValueWrite, node);
    }
    let parameters = parameters(session, &model, action);
    let arguments = arguments(session, node, &parameters);
    let result = result(session, node, &model, (action, receiver));
    crate::call_checker::check_result(session, result, (node, purpose));
    Some(emit(
        session,
        node,
        (model.class, result),
        (action, Some(receiver), arguments),
    ))
}

fn parameters(
    session: &mut AnalysisSession<'_>,
    model: &HirCollection,
    action: CollectionAction,
) -> Vec<TypeId> {
    let integer = session.module.types.intern(Type::Integer);
    match action {
        CollectionAction::New | CollectionAction::Length => Vec::new(),
        CollectionAction::Append => vec![model.value],
        CollectionAction::Insert => vec![integer, model.value],
        CollectionAction::Remove | CollectionAction::Find => vec![model.key.unwrap_or(integer)],
    }
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: &[TypeId],
) -> Vec<ExpressionId> {
    let nodes = session
        .child(node, NodeKind::Arguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    if nodes.len() != expected.len() {
        crate::argument_checker::arity(session, (expected.len(), nodes.len()), node);
    }
    nodes
        .into_iter()
        .zip(expected)
        .map(|(node, expected)| {
            let value = check_expected_for(session, node, *expected, ExpressionPurpose::Argument);
            let kind = session.module.types.get(*expected);
            if !crate::type_resolution::assignable(session, &kind, &session.expression_type(value))
            {
                session.named_report(DiagnosticCode::IncompatibleArgumentType, node, "collection");
            }
            crate::expression_checker::widen(session, value, &kind)
        })
        .collect()
}

fn result(
    session: &mut AnalysisSession<'_>,
    node: usize,
    model: &HirCollection,
    operation: (CollectionAction, ExpressionId),
) -> TypeId {
    let (action, receiver) = operation;
    if model.key.is_some() && matches!(action, CollectionAction::Remove | CollectionAction::Find) {
        let value = crate::snapshot_types::read_type(session, receiver, model.value);
        return crate::variant_types::register(
            session,
            crate::variant_model::VariantFamily::Optional,
            vec![None, Some(value)],
            node,
        );
    }
    session
        .module
        .types
        .intern(if action == CollectionAction::Length {
            Type::Integer
        } else {
            Type::Unit
        })
}

pub(crate) fn element(
    session: &mut AnalysisSession<'_>,
    node: usize,
    source: (ExpressionId, HirCollection),
    indices: &[usize],
) -> ExpressionId {
    let (array, model) = source;
    if indices.len() != 1 {
        crate::argument_checker::arity(session, (1, indices.len()), node);
    }
    let key = model
        .key
        .unwrap_or_else(|| session.module.types.intern(Type::Integer));
    let indices: Vec<_> = indices
        .iter()
        .map(|node| {
            let value = check_expected_for(session, *node, key, ExpressionPurpose::Argument);
            let kind = session.module.types.get(key);
            let actual = session.expression_type(value);
            if actual != Type::Error && !crate::type_resolution::assignable(session, &kind, &actual)
            {
                session.named_report(DiagnosticCode::IncompatibleArgumentType, *node, "index");
            }
            crate::expression_checker::widen(session, value, &kind)
        })
        .collect();
    let result = crate::snapshot_types::read_type(session, array, model.value);
    session.emit(
        crate::HirExpression::Element { array, indices },
        result,
        session.span(node),
    )
}

fn emit(
    session: &mut AnalysisSession<'_>,
    node: usize,
    identity: (crate::identities::ClassId, TypeId),
    parts: (CollectionAction, Option<ExpressionId>, Vec<ExpressionId>),
) -> ExpressionId {
    let (action, receiver, arguments) = parts;
    let (class, result) = identity;
    session.emit(
        crate::HirExpression::Collection(CollectionExpression {
            class,
            action,
            receiver,
            arguments,
        }),
        result,
        session.span(node),
    )
}
