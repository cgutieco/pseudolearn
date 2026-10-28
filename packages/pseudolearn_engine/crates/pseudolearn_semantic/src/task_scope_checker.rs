use crate::identities::LocalId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    if session.control.cleaning {
        session.report(DiagnosticCode::TaskScopeInsideDefer, node);
        return Some(HirStatement::TaskScope {
            failure: None,
            body: Vec::new(),
        });
    }
    session.control.task_scopes = session.control.task_scopes.saturating_add(1);
    session.control.task_errors.push(Vec::new());
    let body = session
        .child(node, NodeKind::Body)
        .map(|body| crate::statement_checker::scoped_body(session, body))
        .unwrap_or_default();
    session.control.task_scopes = session.control.task_scopes.saturating_sub(1);
    let errors = session.control.task_errors.pop().unwrap_or_default();
    let failure = failure_binding(session, node, errors.first().copied());
    Some(HirStatement::TaskScope { failure, body })
}

fn failure_binding(
    session: &mut AnalysisSession<'_>,
    node: usize,
    error: Option<crate::identities::TypeId>,
) -> Option<LocalId> {
    let name_node = session
        .children(node)
        .into_iter()
        .find(|child| session.kind(*child) == NodeKind::Identifier);
    let Some(name_node) = name_node else {
        if error.is_some() {
            session.report(DiagnosticCode::TaskScopeFailureUnbound, node);
        }
        return None;
    };
    let Some(error) = error else {
        session.report(DiagnosticCode::TaskScopeFailureUnused, node);
        return None;
    };
    let type_id = crate::task_failure_types::optional(session, error, node);
    let local = crate::task_bindings::declare(session, name_node, type_id, session.name(name_node));
    session.pending_results.insert(local);
    Some(local)
}
