use crate::identities::LocalId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
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
    let body = session
        .child(node, NodeKind::Body)
        .map(|body| crate::statement_checker::scoped_body(session, body))
        .unwrap_or_default();
    session.control.task_scopes = session.control.task_scopes.saturating_sub(1);
    let failure = failure_binding(session, node);
    Some(HirStatement::TaskScope { failure, body })
}

fn failure_binding(session: &mut AnalysisSession<'_>, node: usize) -> Option<LocalId> {
    let name_node = session
        .children(node)
        .into_iter()
        .find(|child| session.kind(*child) == NodeKind::Identifier)?;
    let name = session.name(name_node);
    let type_id = session.module.types.intern(Type::Unknown);
    let local = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    crate::scope_bindings::declare(
        session,
        name.clone(),
        crate::block_scopes::BindingTarget::Local(local),
        name_node,
    );
    session.module.locals.push(crate::hir::HirLocal {
        name,
        type_id,
        passing: crate::hir::Passing::Value,
        span: session.span(name_node),
        scope: session.current,
        parameter: false,
        mutable: false,
    });
    session.initialized.push(true);
    session
        .module
        .local_visibility
        .insert(local, session.span(node));
    Some(local)
}
