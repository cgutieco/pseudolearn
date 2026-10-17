use crate::identities::StatementId;
use crate::session::AnalysisSession;
use crate::statement_model::{HirDimension, HirStatement};
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<StatementId> {
    let locals = session.declarations.get(&node).cloned().unwrap_or_default();
    let dimensioned: Vec<_> = session
        .children(node)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::Dimensioned)
        .collect();
    let mut declarations = Vec::new();
    for (local, dimensioned) in locals.into_iter().zip(dimensioned) {
        let dimensions: Vec<_> = session
            .children(dimensioned)
            .into_iter()
            .skip(1)
            .map(|child| crate::expression_checker::check(session, child))
            .collect();
        for dimension in &dimensions {
            if !matches!(
                session.expression_type(*dimension),
                Type::Integer | Type::Error | Type::Unknown
            ) {
                session.report(DiagnosticCode::NonIntegerArrayIndex, dimensioned);
            }
        }
        if let Some(initialized) = usize::try_from(local.0)
            .ok()
            .and_then(|index| session.initialized.get_mut(index))
        {
            *initialized = true;
        }
        declarations.push(HirDimension { local, dimensions });
    }
    Some(session.statement(HirStatement::Dimension(declarations), session.span(node)))
}
