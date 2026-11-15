use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn discard(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let child = session.children(node).first().copied()?;
    let value = crate::expression_checker::check(session, child);
    let kind = session.expression_type(value);
    if kind != Type::Error && !crate::result_obligations::is_result(session, &kind) {
        session.report(DiagnosticCode::DiscardRequiresResult, node);
    }
    crate::result_obligations::consume(session, value);
    Some(HirStatement::Call(value))
}

pub(crate) fn returned_value(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> Option<ExpressionId> {
    let child = session.children(node).first().copied()?;
    let kind = crate::hierarchy::function(session, session.current)?.result;
    let value = crate::expression_checker::check_expected(session, child, kind);
    crate::result_obligations::consume(session, value);
    Some(value)
}

pub(crate) fn output_error(session: &mut AnalysisSession<'_>, value: ExpressionId, node: usize) {
    let kind = session.expression_type(value);
    if let Some(collection) = crate::collection_types::get(session, &kind) {
        if !crate::collection_types::printable(session, collection.value) {
            session.report(DiagnosticCode::CollectionCannotBeWritten, node);
        }
        return;
    }
    if crate::function_types::get(session, &kind).is_some() {
        return;
    }
    let code = if crate::variant_types::get(session, &kind).is_some() {
        Some(DiagnosticCode::VariantRequiresPattern)
    } else {
        match kind {
            Type::Object(_) => Some(DiagnosticCode::ObjectCannotBeWritten),
            Type::Record(_) => Some(DiagnosticCode::RecordCannotBeWritten),
            _ => None,
        }
    };
    if let Some(code) = code {
        session.report(code, node);
    }
}
