use crate::expression_model::HirExpression;
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::VariantFamily;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity};

pub(crate) fn is_result(session: &AnalysisSession<'_>, kind: &Type) -> bool {
    crate::variant_types::get(session, kind)
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
    for local in &session.pending_results {
        if let Some(declaration) = usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
        {
            session.diagnostics.push(Diagnostic::new(
                DiagnosticCode::ResultNotHandled,
                declaration.span,
            ));
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
