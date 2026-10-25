use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let control_node = *children.first()?;
    let bounds: Vec<_> = children
        .iter()
        .copied()
        .skip(1)
        .filter(|child| session.kind(*child) != NodeKind::Body)
        .collect();
    let initial = crate::expression_checker::check(session, *bounds.first()?);
    let ending = crate::expression_checker::check(session, *bounds.get(1)?);
    let step = bounds
        .get(2)
        .map(|bound| crate::expression_checker::check(session, *bound));
    validate_bounds(session, &[Some(initial), Some(ending), step], node);
    session.bindings.enter();
    let integer = session.module.types.intern(Type::Integer);
    let control = crate::variant_bindings::pattern(session, integer, control_node);
    let body_node = session.child(node, NodeKind::Body)?;
    session
        .module
        .local_visibility
        .insert(control, session.span(body_node));
    activate_control(session, control);
    let body = check_body(session, node, control)?;
    crate::scope_bindings::leave(session);
    Some(HirStatement::For {
        control,
        initial,
        ending,
        step,
        body,
    })
}

fn validate_bounds(
    session: &mut AnalysisSession<'_>,
    bounds: &[Option<crate::identities::ExpressionId>],
    node: usize,
) {
    if bounds.get(2).copied().flatten().is_none() && session.options.strict {
        session.report(DiagnosticCode::MissingStepClause, node);
    }
    for expression in bounds.iter().copied().flatten() {
        if !matches!(
            session.expression_type(expression),
            Type::Integer | Type::Error | Type::Unknown
        ) {
            session.report(DiagnosticCode::NonIntegerForBound, node);
        }
    }
}

fn activate_control(session: &mut AnalysisSession<'_>, control: crate::identities::LocalId) {
    session.reads.insert(control);
    session.writes.insert(control);
    if let Some(initialized) = usize::try_from(control.0)
        .ok()
        .and_then(|index| session.initialized.get_mut(index))
    {
        *initialized = true;
    }
}

fn check_body(
    session: &mut AnalysisSession<'_>,
    node: usize,
    control: crate::identities::LocalId,
) -> Option<Vec<crate::identities::StatementId>> {
    session.controls.push(control);
    let body_node = session.child(node, NodeKind::Body)?;
    let initialized_before = session.initialized.clone();
    let pending_before = session.pending_results.clone();
    let body = crate::statement_checker::body(session, body_node);
    session.pending_results.extend(pending_before);
    session.initialized = initialized_before;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    session.controls.pop();
    Some(body)
}
