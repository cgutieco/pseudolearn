use crate::expression_checker::{ExpressionPurpose, invalid};
use crate::generic_state::GenericTemplate;
use crate::identities::{ExpressionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_syntax::NodeKind;

pub(crate) fn call(
    session: &mut AnalysisSession<'_>,
    node: usize,
    (template, purpose): (GenericTemplate, ExpressionPurpose),
) -> ExpressionId {
    let (mut arguments, kinds) = checked_arguments(session, node);
    let error = session.module.types.intern(Type::Error);
    if kinds.contains(&error) {
        return invalid(session, node);
    }
    let Some(bound) = crate::generic_inference::infer(session, &template, (&kinds, node)) else {
        return invalid(session, node);
    };
    let Some(function) = crate::generic_functions::instantiate(session, &template, (bound, node))
    else {
        return invalid(session, node);
    };
    crate::argument_checker::check(session, function, &mut arguments, node);
    crate::call_checker::emit_call(session, function, arguments, (node, purpose))
}

fn expression_kind(session: &mut AnalysisSession<'_>, expression: ExpressionId) -> TypeId {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.types.get(index))
        .copied()
        .unwrap_or_else(|| session.module.types.intern(Type::Error))
}

pub(crate) fn construct(
    session: &mut AnalysisSession<'_>,
    node: usize,
    template: GenericTemplate,
) -> ExpressionId {
    let (arguments, kinds) = checked_arguments(session, node);
    let error = session.module.types.intern(Type::Error);
    if kinds.contains(&error) {
        return invalid(session, node);
    }
    let Some(bound) = crate::generic_inference::infer_record(session, &template, (&kinds, node))
    else {
        return invalid(session, node);
    };
    let Some(record) = crate::generic_records::instantiate(session, &template, bound, node) else {
        return invalid(session, node);
    };
    crate::record_access::construct_with(session, node, (record, arguments))
}

fn checked_arguments(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> (Vec<ExpressionId>, Vec<TypeId>) {
    let syntax = session.child(node, NodeKind::Arguments).unwrap_or(node);
    let arguments = crate::call_checker::arguments_for(session, syntax);
    let kinds = arguments
        .iter()
        .map(|argument| expression_kind(session, *argument))
        .collect();
    (arguments, kinds)
}
