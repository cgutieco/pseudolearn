use crate::expression_model::HirExpression;
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::VariantFamily;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity};

pub(crate) fn is_result(session: &AnalysisSession<'_>, kind: &Type) -> bool {
    crate::task_failure_types::is_failure(session, kind)
        || crate::variant_types::get(session, kind)
            .is_some_and(|variant| variant.family == VariantFamily::Result)
}

pub(crate) fn consume(session: &mut AnalysisSession<'_>, expression: ExpressionId) {
    if let Some(HirExpression::Local(local)) = usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index))
    {
        session.pending_results.remove(local);
    }
}

pub(crate) fn assign(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    expression: ExpressionId,
    node: usize,
) {
    if !is_result(session, &session.expression_type(expression)) {
        return;
    }
    consume(session, expression);
    if !session.pending_results.insert(local) {
        session.report(DiagnosticCode::ResultNotHandled, node);
        let type_id = usize::try_from(expression.0)
            .ok()
            .and_then(|index| session.module.expressions.types.get(index).copied());
        if let Some(type_id) = type_id {
            crate::diagnostic_arguments::last_type(session, type_id);
        }
    }
}

pub(crate) fn finish(session: &mut AnalysisSession<'_>) {
    if session
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
    {
        return;
    }
    let pending: Vec<LocalId> = session.pending_results.iter().copied().collect();
    for local in pending {
        let declaration = usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .map(|declaration| (declaration.span, declaration.type_id));
        if let Some((span, type_id)) = declaration {
            session.diagnostics.push(Diagnostic::new(
                if crate::task_failure_types::is_failure(
                    session,
                    &session.module.types.get(type_id),
                ) {
                    DiagnosticCode::TaskScopeFailureUnused
                } else {
                    DiagnosticCode::ResultNotHandled
                },
                span,
            ));
            crate::diagnostic_arguments::last_type(session, type_id);
        }
    }
}

pub(crate) fn parameters(session: &mut AnalysisSession<'_>, parameters: &[LocalId]) {
    for parameter in parameters {
        if let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            && is_result(session, &session.module.types.get(local.type_id))
        {
            session.pending_results.insert(*parameter);
        }
    }
}
