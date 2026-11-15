use crate::collection_model::{CollectionAction, CollectionExpression, HirCollection};
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::{HirExpression, Passing, Type};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (model, action): (&HirCollection, CollectionAction),
    receiver: ExpressionId,
) -> Option<ExpressionId> {
    if !matches!(
        action,
        CollectionAction::Sort
            | CollectionAction::Reverse
            | CollectionAction::IndexOf
            | CollectionAction::Contains
            | CollectionAction::Keys
    ) {
        return None;
    }
    let nodes = session
        .child(node, NodeKind::Arguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    let arguments = arguments(session, (node, &nodes), (model, action));
    let result = result_type(session, node, (model, action), receiver);
    Some(session.emit(
        HirExpression::Collection(CollectionExpression {
            class: model.class,
            action,
            receiver: Some(receiver),
            arguments,
        }),
        result,
        session.span(node),
    ))
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    (node, nodes): (usize, &[usize]),
    (model, action): (&HirCollection, CollectionAction),
) -> Vec<ExpressionId> {
    let search = matches!(
        action,
        CollectionAction::IndexOf | CollectionAction::Contains
    );
    let expected = usize::from(search || action == CollectionAction::Sort && !nodes.is_empty());
    if nodes.len() != expected {
        crate::argument_checker::arity(session, (expected, nodes.len()), node);
    }
    let primitive = matches!(
        session.module.types.get(model.value),
        Type::Integer | Type::Real | Type::Character | Type::String | Type::Boolean
    );
    if !primitive && (search || action == CollectionAction::Sort && nodes.is_empty()) {
        session.report(
            if search {
                DiagnosticCode::ElementTypeNotComparable
            } else {
                DiagnosticCode::ElementTypeNotOrderable
            },
            node,
        );
    }
    let mut arguments = Vec::new();
    if let Some(argument) = nodes.first().filter(|_| expected == 1) {
        let expected = argument_type(session, node, (model, search));
        arguments.push(check_argument(session, *argument, expected));
    }
    arguments
}

pub(crate) fn action(identity: Option<&str>, dictionary: bool) -> Option<CollectionAction> {
    Some(match identity? {
        "vectorSort" if !dictionary => CollectionAction::Sort,
        "vectorReverse" if !dictionary => CollectionAction::Reverse,
        "vectorIndexOf" if !dictionary => CollectionAction::IndexOf,
        "vectorContains" if !dictionary => CollectionAction::Contains,
        "dictionaryKeys" if dictionary => CollectionAction::Keys,
        "collectionLength" => CollectionAction::Length,
        "vectorAppend" if !dictionary => CollectionAction::Append,
        "vectorInsert" if !dictionary => CollectionAction::Insert,
        "collectionRemove" => CollectionAction::Remove,
        "dictionaryFind" if dictionary => CollectionAction::Find,
        _ => return None,
    })
}

fn result_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (model, action): (&HirCollection, CollectionAction),
    receiver: ExpressionId,
) -> crate::identities::TypeId {
    match action {
        CollectionAction::Contains => session.module.types.intern(Type::Boolean),
        CollectionAction::IndexOf => {
            let integer = session.module.types.intern(Type::Integer);
            crate::variant_types::register(
                session,
                crate::variant_model::VariantFamily::Optional,
                vec![None, Some(integer)],
                node,
            )
        }
        CollectionAction::Keys => {
            let key = model.key.unwrap_or(model.value);
            let class = session
                .module
                .collections
                .values()
                .find(|model| model.key.is_none() && model.value == key)
                .map(|model| model.class)
                .unwrap_or_else(|| crate::collection_types::register(session, node, (None, key)));
            let kind = session.module.types.intern(Type::Object(class));
            crate::snapshot_types::read_type(session, receiver, kind)
        }
        _ => session.module.types.intern(Type::Unit),
    }
}

fn argument_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (model, search): (&HirCollection, bool),
) -> crate::identities::TypeId {
    if search {
        model.value
    } else {
        let integer = session.module.types.intern(Type::Integer);
        crate::function_types::intern(
            session,
            crate::function_model::FunctionSignature {
                parameters: vec![(model.value, Passing::Value), (model.value, Passing::Value)],
                result: integer,
                pure: false,
            },
            node,
        )
    }
}

fn check_argument(
    session: &mut AnalysisSession<'_>,
    argument: usize,
    expected: crate::identities::TypeId,
) -> ExpressionId {
    let value = crate::expression_checker::check_expected_for(
        session,
        argument,
        expected,
        crate::expression_checker::ExpressionPurpose::Argument,
    );
    if !crate::type_resolution::assignable(
        session,
        &session.module.types.get(expected),
        &session.expression_type(value),
    ) {
        session.report(DiagnosticCode::IncompatibleArgumentType, argument);
    }
    crate::expression_checker::widen(session, value, &session.module.types.get(expected))
}
