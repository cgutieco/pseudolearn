use crate::hir::HirFunction;
use crate::identities::FunctionId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn declaration(session: &mut AnalysisSession<'_>, node: usize) {
    let kind = session.kind(node);
    let modifier = session.child(node, NodeKind::SuspendibleModifier);
    let function_literal = kind == NodeKind::FunctionLiteral;
    let unsupported_member = matches!(kind, NodeKind::MethodMember | NodeKind::ConstructorMember);
    if let Some(modifier) = modifier
        && (function_literal || unsupported_member || function_keyword(session, node))
    {
        session.report(DiagnosticCode::SuspendibleModifierNotAllowed, modifier);
    }
}

pub(crate) fn declared(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.kind(node) == NodeKind::Subprogram
        && session.child(node, NodeKind::SuspendibleModifier).is_some()
        && !function_keyword(session, node)
}

fn function_keyword(session: &AnalysisSession<'_>, node: usize) -> bool {
    crate::pure_opening::opens_with_function(session, node)
}

pub(crate) fn value(
    session: &mut AnalysisSession<'_>,
    (function, node): (FunctionId, usize),
) -> bool {
    if function_model(session, function).is_none_or(|function| !function.suspendible) {
        return false;
    }
    session.report(DiagnosticCode::SuspendibleAsValue, node);
    true
}

pub(crate) fn call(session: &mut AnalysisSession<'_>, (function, node): (FunctionId, usize)) {
    let suspendible =
        function_model(session, function).is_some_and(|function| function.suspendible);
    if suspendible && !session.awaited_calls.contains(&node) {
        session.report(DiagnosticCode::SuspendibleCallWithoutAwait, node);
    }
}

fn function_model<'session>(
    session: &'session AnalysisSession<'_>,
    function: FunctionId,
) -> Option<&'session HirFunction> {
    usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
}
