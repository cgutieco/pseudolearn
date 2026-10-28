#![forbid(unsafe_code)]

use crate::hir::HirFunction;
use crate::identities::{ExpressionId, StatementId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::{BTreeMap, BTreeSet};

#[path = "effect_interface_realizations.rs"]
mod effect_interface_realizations;
#[path = "effect_pure_values.rs"]
mod effect_pure_values;

pub(crate) fn check(session: &mut AnalysisSession<'_>) {
    let mut direct_effects = BTreeSet::new();
    let mut call_edges: BTreeMap<usize, BTreeSet<usize>> = BTreeMap::new();
    for (index, function) in session.module.functions.iter().enumerate() {
        let mut calls = BTreeSet::new();
        if function.suspendible || function_has_direct_effects(session, function, &mut calls) {
            direct_effects.insert(index);
        }
        call_edges.insert(index, calls);
    }
    attach_function_arguments(session, &mut call_edges);
    let reasons = propagate_effects(&direct_effects, &call_edges);
    let mut reports = Vec::new();
    for (index, function) in session.module.functions.iter().enumerate() {
        if !is_pure_function(session, function) || specific_task_error(session, function) {
            continue;
        }
        if direct_effects.contains(&index) {
            reports.push((
                DiagnosticCode::PureFunctionSideEffect,
                function.syntax,
                index,
            ));
        } else if reasons.contains_key(&index) {
            reports.push((
                DiagnosticCode::PureFunctionTransitiveSideEffect,
                function.syntax,
                index,
            ));
        }
    }
    for (code, syntax, index) in reports {
        report_with_chain(session, (code, syntax), &causal_chain(&reasons, index));
    }
    effect_pure_values::check_pure_function_values(session, &reasons);
    effect_interface_realizations::check(session, &reasons);
}

pub(crate) fn report_with_chain(
    session: &mut AnalysisSession<'_>,
    (code, syntax): (DiagnosticCode, usize),
    chain: &[usize],
) {
    session.report(code, syntax);
    let spans: Vec<_> = chain
        .iter()
        .filter_map(|index| session.module.functions.get(*index))
        .map(|function| session.span(function.syntax))
        .collect();
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.related.extend(spans);
    }
}

pub(crate) fn causal_chain(reasons: &BTreeMap<usize, Option<usize>>, start: usize) -> Vec<usize> {
    let mut chain = Vec::new();
    let mut current = start;
    while let Some(Some(next)) = reasons.get(&current) {
        if chain.contains(next) || *next == start {
            break;
        }
        chain.push(*next);
        current = *next;
    }
    chain
}

fn attach_function_arguments(
    session: &AnalysisSession<'_>,
    call_edges: &mut BTreeMap<usize, BTreeSet<usize>>,
) {
    for expression in &session.module.expressions.kinds {
        if let crate::expression_model::HirExpression::Call {
            function,
            arguments,
        } = expression
        {
            attach_call_arguments(session, call_edges, *function, arguments);
        }
    }
}

fn attach_call_arguments(
    session: &AnalysisSession<'_>,
    call_edges: &mut BTreeMap<usize, BTreeSet<usize>>,
    function: crate::identities::FunctionId,
    arguments: &[ExpressionId],
) {
    let target = usize::try_from(function.0).unwrap_or(usize::MAX);
    for argument in arguments {
        if let (Some(origin), Some(edges)) = (
            argument_function_origin(session, *argument),
            call_edges.get_mut(&target),
        ) {
            edges.insert(origin);
        }
    }
}

fn argument_function_origin(
    session: &AnalysisSession<'_>,
    argument: ExpressionId,
) -> Option<usize> {
    let index = usize::try_from(argument.0).unwrap_or(usize::MAX);
    match session.module.expressions.kinds.get(index) {
        Some(crate::expression_model::HirExpression::FunctionValue(callee)) => {
            Some(unwrap_function_value(session, *callee))
        }
        _ => None,
    }
}

pub(crate) fn unwrap_function_value(
    session: &AnalysisSession<'_>,
    function: crate::identities::FunctionId,
) -> usize {
    for (original, wrapper) in &session.module.function_values {
        if *wrapper == function {
            return usize::try_from(original.0).unwrap_or(usize::MAX);
        }
    }
    usize::try_from(function.0).unwrap_or(usize::MAX)
}

pub(crate) fn is_pure_function(session: &AnalysisSession<'_>, function: &HirFunction) -> bool {
    let lexeme = session.lexeme(function.syntax);
    let folded = session.options.profile.fold_word(lexeme);
    folded == "funcion" || folded == "function"
}

fn function_has_direct_effects(
    session: &AnalysisSession<'_>,
    function: &HirFunction,
    calls: &mut BTreeSet<usize>,
) -> bool {
    let mut has_effects = false;
    for statement_id in &function.body {
        if statement_effects(session, *statement_id, calls) {
            has_effects = true;
        }
    }
    has_effects
}

fn block_has_effects(
    session: &AnalysisSession<'_>,
    body: &[StatementId],
    calls: &mut BTreeSet<usize>,
) -> bool {
    body.iter()
        .filter(|id| statement_effects(session, **id, calls))
        .count()
        > 0
}

fn statement_effects(
    session: &AnalysisSession<'_>,
    statement_id: StatementId,
    calls: &mut BTreeSet<usize>,
) -> bool {
    let index = usize::try_from(statement_id.0).unwrap_or(usize::MAX);
    let Some(statement) = session.module.statements.kinds.get(index) else {
        return false;
    };
    let mut effects = false;
    for expression in crate::effect_operands::statement(statement) {
        effects |= crate::effect_calls::collect(session, expression, calls);
    }
    effects
        | matches!(
            statement,
            HirStatement::Write { .. } | HirStatement::Read(_)
        )
        | compound_effects(session, statement, calls)
}

fn compound_effects(
    session: &AnalysisSession<'_>,
    statement: &HirStatement,
    calls: &mut BTreeSet<usize>,
) -> bool {
    match statement {
        HirStatement::Conditional {
            affirmative,
            negative,
            ..
        } => {
            block_has_effects(session, affirmative, calls)
                | block_has_effects(session, negative, calls)
        }
        HirStatement::While { body, .. }
        | HirStatement::Repeat { body, .. }
        | HirStatement::For { body, .. }
        | HirStatement::ForEach { body, .. }
        | HirStatement::TaskScope { body, .. }
        | HirStatement::Defer(body) => block_has_effects(session, body, calls),
        HirStatement::Select(selection) => {
            selection.cases.iter().for_each(|branch| {
                block_has_effects(session, &branch.body, calls);
            });
            true
        }
        HirStatement::Switch { cases, default, .. } => {
            case_effects(session, cases, calls) | block_has_effects(session, default, calls)
        }
        HirStatement::VariantMatch(branch) => {
            case_effects(session, &branch.cases, calls)
                | block_has_effects(session, &branch.default, calls)
        }
        _ => false,
    }
}

fn propagate_effects(
    direct: &BTreeSet<usize>,
    edges: &BTreeMap<usize, BTreeSet<usize>>,
) -> BTreeMap<usize, Option<usize>> {
    let mut reasons: BTreeMap<usize, Option<usize>> =
        direct.iter().map(|index| (*index, None)).collect();
    let mut changed = true;
    while changed {
        changed = false;
        for (caller, callees) in edges {
            if reasons.contains_key(caller) {
                continue;
            }
            if let Some(callee) = callees.iter().find(|callee| reasons.contains_key(callee)) {
                reasons.insert(*caller, Some(*callee));
                changed = true;
            }
        }
    }
    reasons
}

fn specific_task_error(session: &AnalysisSession<'_>, function: &HirFunction) -> bool {
    session.diagnostics.iter().any(|diagnostic| {
        diagnostic.code == DiagnosticCode::PureFunctionTaskOperation
            && diagnostic.span.source_id == function.span.source_id
            && diagnostic.span.start >= function.span.start
            && diagnostic.span.ending <= function.span.ending
    })
}

fn case_effects(
    session: &AnalysisSession<'_>,
    cases: &[crate::statement_model::HirCase],
    calls: &mut BTreeSet<usize>,
) -> bool {
    cases
        .iter()
        .filter(|branch| block_has_effects(session, &branch.body, calls))
        .count()
        > 0
}
