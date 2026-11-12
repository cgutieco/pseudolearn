use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    match session.kind(node) {
        NodeKind::ForLoop => crate::for_checker::check(session, node),
        NodeKind::Switch => crate::switch_checker::check(session, node),
        NodeKind::Conditional => conditional(session, node),
        NodeKind::WhileLoop => while_loop(session, node),
        NodeKind::RepeatLoop => repeat_loop(session, node),
        _ => None,
    }
}

pub(crate) fn condition(session: &mut AnalysisSession<'_>, node: usize) -> ExpressionId {
    let expression = crate::expression_checker::check(session, node);
    if !matches!(
        session.expression_type(expression),
        Type::Boolean | Type::Error | Type::Unknown
    ) {
        session.report(DiagnosticCode::NonBooleanCondition, node);
    }
    expression
}

fn conditional(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    use crate::definite_assignment_state::{AssignmentCause, capture, merge, path, restore};
    let children = session.children(node);
    let condition = condition(session, *children.first()?);
    let before = capture(session);
    let before_results = session.pending_results.clone();
    let affirmative_node = *children.get(1)?;
    let affirmative = crate::statement_checker::scoped_body(session, affirmative_node);
    let affirmative_state = capture(session);
    let affirmative_results = std::mem::replace(&mut session.pending_results, before_results);
    restore(session, &before);
    let negative = children
        .get(2)
        .map(|body| crate::statement_checker::scoped_body(session, *body))
        .unwrap_or_default();
    let negative_state = capture(session);
    let (cause, origins) = match children.get(2) {
        Some(negative_node) => (
            AssignmentCause::BranchWithoutAssignment,
            (session.span(affirmative_node), session.span(*negative_node)),
        ),
        None => (
            AssignmentCause::BranchWithoutElse,
            (session.span(node), session.span(node)),
        ),
    };
    let paths = [
        path(affirmative_state, cause, origins.0),
        path(negative_state, cause, origins.1),
    ];
    merge(session, &paths);
    session.pending_results.extend(affirmative_results);
    Some(HirStatement::Conditional {
        condition,
        affirmative,
        negative,
    })
}

fn while_loop(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let condition = condition(session, *children.first()?);
    let before = crate::definite_assignment_state::capture(session);
    let pending_before = session.pending_results.clone();
    session.control.loops = session.control.loops.saturating_add(1);
    crate::definite_assignment_state::enter_loop(session);
    let body = crate::statement_checker::scoped_body(session, *children.get(1)?);
    crate::definite_assignment_state::leave_loop(session);
    session.control.loops = session.control.loops.saturating_sub(1);
    session.pending_results.extend(pending_before);
    let span = session.span(node);
    crate::definite_assignment_state::after_loop(session, before, span);
    Some(HirStatement::While { condition, body })
}

fn repeat_loop(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    session.bindings.enter();
    let start = session.module.locals.len();
    session.control.loops = session.control.loops.saturating_add(1);
    crate::definite_assignment_state::enter_loop(session);
    let body = crate::statement_checker::open_body(session, *children.first()?);
    let exits = crate::definite_assignment_state::leave_loop(session);
    session.control.loops = session.control.loops.saturating_sub(1);
    let condition = condition(session, *children.get(1)?);
    let span = session.span(node);
    crate::definite_assignment_state::after_repeat(session, exits, span);
    crate::cleanup_checker::finish_scope(session);
    crate::scope_bindings::visibility(session, start, node);
    for index in start..session.module.locals.len() {
        let local = crate::identities::LocalId(u32::try_from(index).unwrap_or(u32::MAX));
        if session
            .bindings
            .find(&session.module.locals.get(index)?.name)
            == Some(crate::block_scopes::BindingTarget::Local(local))
        {
            session
                .module
                .local_visibility
                .insert(local, session.span(node));
        }
    }
    crate::scope_bindings::leave(session);
    Some(HirStatement::Repeat { body, condition })
}
