use super::{causal_chain, is_pure_function};
use crate::expression_model::{HirExpression, HirPlace};
use crate::identities::{ExpressionId, FunctionId, LocalId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;
use std::collections::{BTreeMap, BTreeSet};

pub(super) fn check_pure_function_values(
    session: &mut AnalysisSession<'_>,
    reasons: &BTreeMap<usize, Option<usize>>,
) {
    let mut reports = Vec::new();
    for statement in &session.module.statements.kinds {
        if let HirStatement::Assign {
            destination: HirPlace::Local(local),
            value,
        } = statement
            && local_expects_pure(session, *local)
            && let Some(origin) = impure_function_origin(session, *value, reasons)
        {
            reports.push((expression_span(session, *value), origin));
        }
    }
    for expression in &session.module.expressions.kinds {
        if let HirExpression::Call { function, arguments } = expression {
            collect_impure_call_arguments(session, (*function, arguments), reasons, &mut reports);
        }
    }
    for (span, origin) in reports {
        let mut chain = vec![origin];
        chain.extend(causal_chain(reasons, origin));
        report_span_with_chain(
            session,
            (DiagnosticCode::PureFunctionTransitiveSideEffect, span),
            &chain,
        );
    }
}

fn collect_impure_call_arguments(
    session: &AnalysisSession<'_>,
    (function, arguments): (FunctionId, &[ExpressionId]),
    reasons: &BTreeMap<usize, Option<usize>>,
    reports: &mut Vec<(Span, usize)>,
) {
    if session
        .module
        .functions
        .get(usize::try_from(function.0).unwrap_or(usize::MAX))
        .is_some_and(|callee| is_pure_function(session, callee))
    {
        return;
    }
    let parameters = crate::hierarchy::function(session, function)
        .map(|callee| callee.parameters.clone())
        .unwrap_or_default();
    for (parameter, argument) in parameters.into_iter().zip(arguments) {
        if local_expects_pure(session, parameter)
            && let Some(origin) = impure_function_origin(session, *argument, reasons)
        {
            reports.push((expression_span(session, *argument), origin));
        }
    }
}

fn local_expects_pure(session: &AnalysisSession<'_>, local: LocalId) -> bool {
    let scope = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .map(|binding| binding.scope);
    if scope
        .and_then(|function| usize::try_from(function.0).ok())
        .and_then(|index| session.module.functions.get(index))
        .is_some_and(|owner| is_pure_function(session, owner))
    {
        return false;
    }
    session.module.pure_locals.contains(&local)
}

fn impure_function_origin(
    session: &AnalysisSession<'_>,
    expression: ExpressionId,
    reasons: &BTreeMap<usize, Option<usize>>,
) -> Option<usize> {
    let mut calls = BTreeSet::new();
    crate::effect_calls::collect(session, expression, &mut calls);
    calls
        .into_iter()
        .find(|callee| reasons.contains_key(callee))
}

fn expression_span(session: &AnalysisSession<'_>, expression: ExpressionId) -> Span {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .copied()
        .unwrap_or_default()
}

fn report_span_with_chain(
    session: &mut AnalysisSession<'_>,
    (code, span): (DiagnosticCode, Span),
    chain: &[usize],
) {
    let rigor = if session.options.strict {
        "estricto"
    } else {
        "flexible"
    };
    let mut diagnostic = Diagnostic::new(code, span).with_severity(code.severity(rigor));
    diagnostic.related = chain
        .iter()
        .filter_map(|index| session.module.functions.get(*index))
        .map(|function| session.span(function.syntax))
        .collect();
    session.diagnostics.push(diagnostic);
}
