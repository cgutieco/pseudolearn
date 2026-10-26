use crate::control_context::DeferredEffects;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn defer(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    if session.control.cleaning {
        session.report(DiagnosticCode::ControlTransferInsideCleanup, node);
    }
    let initialized = session.initialized.clone();
    let pending = session.pending_results.clone();
    let returned = session.returned;
    let cleaning = std::mem::replace(&mut session.control.cleaning, true);
    let body = session.child(node, NodeKind::Body)?;
    let body = crate::statement_checker::scoped_body(session, body);
    let effects = DeferredEffects {
        consumed: pending
            .difference(&session.pending_results)
            .copied()
            .collect(),
        produced: session
            .pending_results
            .difference(&pending)
            .copied()
            .collect(),
    };
    session.initialized = initialized;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    session.pending_results = pending;
    session.returned = returned;
    session.control.cleaning = cleaning;
    if let Some(scope) = session.control.deferred.last_mut() {
        scope.push(effects);
    }
    Some(HirStatement::Defer(body))
}

pub(crate) fn break_statement(session: &mut AnalysisSession<'_>, node: usize) -> HirStatement {
    if session.control.cleaning {
        session.report(DiagnosticCode::ControlTransferInsideCleanup, node);
    } else if session.control.loops == 0 {
        session.report(DiagnosticCode::BreakOutsideLoop, node);
    }
    HirStatement::Break
}

pub(crate) fn finish_scope(session: &mut AnalysisSession<'_>) {
    let effects = session.control.deferred.pop().unwrap_or_default();
    apply(session, effects.into_iter().rev());
}

pub(crate) fn exit(session: &mut AnalysisSession<'_>) {
    let effects: Vec<_> = session
        .control
        .deferred
        .iter()
        .rev()
        .flat_map(|scope| scope.iter().rev().cloned())
        .collect();
    apply(session, effects);
}

fn apply(session: &mut AnalysisSession<'_>, effects: impl IntoIterator<Item = DeferredEffects>) {
    for effects in effects {
        for local in effects.consumed {
            session.pending_results.remove(&local);
        }
        session.pending_results.extend(effects.produced);
    }
}

pub(crate) fn statement(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    Some(match session.kind(node) {
        NodeKind::DeferStatement => crate::cleanup_checker::defer(session, node)?,
        NodeKind::BreakStatement => crate::cleanup_checker::break_statement(session, node),
        NodeKind::ForEachLoop => crate::for_each_checker::check(session, node)?,
        _ => return None,
    })
}
