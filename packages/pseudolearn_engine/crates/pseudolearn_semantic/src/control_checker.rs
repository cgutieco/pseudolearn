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
    let children = session.children(node);
    let condition = condition(session, *children.first()?);
    let before = session.initialized.clone();
    let before_results = session.pending_results.clone();
    let affirmative = crate::statement_checker::body(session, *children.get(1)?);
    let affirmative_state = session.initialized.clone();
    let affirmative_results = std::mem::replace(&mut session.pending_results, before_results);
    session.initialized.clone_from(&before);
    session
        .initialized
        .resize(session.module.locals.len(), false);
    let negative = children
        .get(2)
        .map(|body| crate::statement_checker::body(session, *body))
        .unwrap_or_default();
    for (index, assigned) in session.initialized.iter_mut().enumerate() {
        *assigned &= affirmative_state.get(index).copied().unwrap_or(false);
    }
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
    let before = session.initialized.clone();
    let pending_before = session.pending_results.clone();
    let body = crate::statement_checker::body(session, *children.get(1)?);
    session.pending_results.extend(pending_before);
    session.initialized = before;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    Some(HirStatement::While { condition, body })
}

fn repeat_loop(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let body = crate::statement_checker::body(session, *children.first()?);
    let condition = condition(session, *children.get(1)?);
    Some(HirStatement::Repeat { body, condition })
}
