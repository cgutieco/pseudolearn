use crate::expression_checker::{ExpressionPurpose, check_expected_for};
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_abi::{EffectOperation, find_effect_operation};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    receiver: Option<ExpressionId>,
    purpose: ExpressionPurpose,
) -> Option<ExpressionId> {
    let children = session.children(node);
    let name = session.name(*children.get(usize::from(receiver.is_some()))?);
    let spanish = session.options.profile == pseudolearn_lexicon::Profile::Spanish;
    let kind = receiver.and_then(|receiver| {
        crate::effect_types::receiver(session, &session.expression_type(receiver))
    });
    if receiver.is_some() && kind.is_none() {
        return None;
    }
    let operation = find_effect_operation(&name, spanish, kind)?;
    let arguments = arguments(session, node, operation);
    let value = crate::effect_types::value_type(session, node, operation.result);
    let result = result_type(session, node, operation, value);
    crate::call_checker::check_result(session, result, (node, purpose));
    Some(session.emit(
        crate::HirExpression::Effect {
            operation: operation.id,
            receiver,
            arguments,
            source_node_id: u32::try_from(node).unwrap_or(u32::MAX),
        },
        result,
        session.span(node),
    ))
}

fn result_type(
    session: &mut AnalysisSession<'_>,
    node: usize,
    operation: &EffectOperation,
    value: crate::identities::TypeId,
) -> crate::identities::TypeId {
    if !operation.fallible {
        return value;
    }
    let error = crate::effect_types::error_type(session, node);
    let error = session.module.types.intern(error);
    crate::variant_types::register(
        session,
        crate::variant_model::VariantFamily::Result,
        vec![Some(value), Some(error)],
        node,
    )
}

fn arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
    operation: &EffectOperation,
) -> Vec<ExpressionId> {
    let nodes = session
        .child(node, NodeKind::Arguments)
        .map(|node| session.children(node))
        .unwrap_or_default();
    if nodes.len() != operation.parameters.len() {
        crate::argument_checker::arity(session, (operation.parameters.len(), nodes.len()), node);
    }
    nodes
        .into_iter()
        .zip(operation.parameters)
        .map(|(argument, kind)| check_argument(session, (argument, *kind), operation))
        .collect()
}

fn check_argument(
    session: &mut AnalysisSession<'_>,
    (argument, kind): (usize, pseudolearn_abi::EffectValueKind),
    operation: &EffectOperation,
) -> ExpressionId {
    let expected = crate::effect_types::value_type(session, argument, kind);
    let mut value = check_expected_for(session, argument, expected, ExpressionPurpose::Argument);
    if kind == pseudolearn_abi::EffectValueKind::Text
        && session.expression_type(value) == Type::Character
    {
        value = crate::builtin_checker::check(
            session,
            pseudolearn_lexicon::BuiltinKind::ToText,
            vec![value],
            argument,
        );
    }
    let actual = session.expression_type(value);
    let expected = session.module.types.get(expected);
    if actual != Type::Error && !crate::type_resolution::assignable(session, &expected, &actual) {
        session.named_report(
            DiagnosticCode::IncompatibleArgumentType,
            argument,
            operation.identity,
        );
    }
    value
}
