use crate::block_scopes::BindingTarget;
use crate::identities::LocalId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_source::Span;

pub(crate) fn declare(
    session: &mut AnalysisSession<'_>,
    name: String,
    target: BindingTarget,
    node: usize,
) {
    if let Some(previous) = session.bindings.find(&name)
        && !recovery(session, previous)
    {
        let code = if session.bindings.current(&name).is_some() {
            DiagnosticCode::DuplicateVariableDeclaration
        } else {
            DiagnosticCode::BindingShadowsOuter
        };
        session.named_report(code, node, &name);
        let origin = origin(session, previous);
        if let Some(diagnostic) = session.diagnostics.last_mut() {
            diagnostic.related.push(origin);
        }
    }
    session.bindings.insert(name, target);
}

pub(crate) fn recovery(session: &AnalysisSession<'_>, target: BindingTarget) -> bool {
    let BindingTarget::Local(local) = target else {
        return false;
    };
    session.invalid.contains(&local)
        && usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .is_some_and(|local| {
                session.module.types.get(local.type_id) == crate::types::Type::Error
            })
}

pub(crate) fn leave(session: &mut AnalysisSession<'_>) {
    for target in session.bindings.leave() {
        if let BindingTarget::Local(local) = target {
            finish_result(session, local);
        }
    }
}

pub(crate) fn outside(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> bool {
    let Some(previous) = session.bindings.expired(name) else {
        return false;
    };
    session.named_report(DiagnosticCode::BindingOutsideScope, node, name);
    let origin = origin(session, previous);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.related.push(origin);
    }
    true
}

pub(crate) fn visibility(session: &mut AnalysisSession<'_>, start: usize, node: usize) {
    let span = session.span(node);
    for index in start..session.module.locals.len() {
        if let Ok(identifier) = u32::try_from(index) {
            session
                .module
                .local_visibility
                .entry(LocalId(identifier))
                .or_insert(span);
        }
    }
}

fn origin(session: &AnalysisSession<'_>, target: BindingTarget) -> Span {
    match target {
        BindingTarget::Local(local) => usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .map(|local| local.span),
        BindingTarget::Constant(index) => session
            .constants
            .get(index)
            .map(|entry| session.span(entry.name_node)),
    }
    .unwrap_or_default()
}

fn finish_result(session: &mut AnalysisSession<'_>, local: LocalId) {
    if session.pending_results.remove(&local)
        && let Some(declaration) = usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
    {
        session
            .diagnostics
            .push(pseudolearn_diagnostics::Diagnostic::new(
                DiagnosticCode::ResultNotHandled,
                declaration.span,
            ));
    }
}
