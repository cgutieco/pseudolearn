#![forbid(unsafe_code)]

use crate::hir::HirFunction;
use crate::identities::{ClassId, ExpressionId, StatementId};
use crate::interface_model::InterfaceId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn check(session: &mut AnalysisSession<'_>) {
    let mut direct_effects = BTreeSet::new();
    let mut call_edges: BTreeMap<usize, BTreeSet<usize>> = BTreeMap::new();
    for (index, function) in session.module.functions.iter().enumerate() {
        let mut calls = BTreeSet::new();
        if function_has_direct_effects(session, function, &mut calls) {
            direct_effects.insert(index);
        }
        call_edges.insert(index, calls);
    }
    attach_function_arguments(session, &mut call_edges);
    let all_effects = propagate_effects(&direct_effects, &call_edges);
    let mut reports = Vec::new();
    for (index, function) in session.module.functions.iter().enumerate() {
        if !is_pure_function(session, function) {
            continue;
        }
        if direct_effects.contains(&index) {
            reports.push((DiagnosticCode::PureFunctionSideEffect, function.syntax));
        } else if all_effects.contains(&index) {
            reports.push((DiagnosticCode::PureFunctionTransitiveSideEffect, function.syntax));
        }
    }
    for (code, syntax) in reports {
        session.report(code, syntax);
    }
    check_interface_realizations(session, &all_effects);
}

fn attach_function_arguments(
    session: &AnalysisSession<'_>,
    call_edges: &mut BTreeMap<usize, BTreeSet<usize>>,
) {
    for expression in &session.module.expressions.kinds {
        if let crate::expression_model::HirExpression::Call { function, arguments } = expression {
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
        if let (Some(origin), Some(edges)) =
            (argument_function_origin(session, *argument), call_edges.get_mut(&target))
        {
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

fn is_pure_function(session: &AnalysisSession<'_>, function: &HirFunction) -> bool {
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
    body.iter().filter(|id| statement_effects(session, **id, calls)).count() > 0
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
    effects | matches!(statement, HirStatement::Write { .. } | HirStatement::Read(_))
        | compound_effects(session, statement, calls)
}

fn compound_effects(
    session: &AnalysisSession<'_>,
    statement: &HirStatement,
    calls: &mut BTreeSet<usize>,
) -> bool {
    match statement {
        HirStatement::Conditional { affirmative, negative, .. } => {
            block_has_effects(session, affirmative, calls)
                | block_has_effects(session, negative, calls)
        }
        HirStatement::While { body, .. }
        | HirStatement::Repeat { body, .. }
        | HirStatement::For { body, .. }
        | HirStatement::ForEach { body, .. }
        | HirStatement::Defer(body) => block_has_effects(session, body, calls),
        HirStatement::Switch { cases, default, .. } => {
            let cases_effect = cases
                .iter()
                .filter(|branch| block_has_effects(session, &branch.body, calls))
                .count()
                > 0;
            cases_effect | block_has_effects(session, default, calls)
        }
        HirStatement::VariantMatch(branch) => {
            let effects = branch
                .cases
                .iter()
                .filter(|case| block_has_effects(session, &case.body, calls))
                .count()
                > 0;
            effects | block_has_effects(session, &branch.default, calls)
        }
        _ => false,
    }
}

fn propagate_effects(
    direct: &BTreeSet<usize>,
    edges: &BTreeMap<usize, BTreeSet<usize>>,
) -> BTreeSet<usize> {
    let mut effects = direct.clone();
    let mut changed = true;
    while changed {
        changed = false;
        for (caller, callees) in edges {
            if !effects.contains(caller) && callees.iter().any(|callee| effects.contains(callee)) {
                effects.insert(*caller);
                changed = true;
            }
        }
    }
    effects
}

fn check_interface_realizations(
    session: &mut AnalysisSession<'_>,
    all_effects: &BTreeSet<usize>,
) {
    let mut reports = Vec::new();
    for class_index in 0..session.module.classes.len() {
        let class = ClassId(u32::try_from(class_index).unwrap_or(u32::MAX));
        session.enter_class_id(class);
        for interface_index in 0..session.module.interfaces.len() {
            let interface = InterfaceId(u32::try_from(interface_index).unwrap_or(u32::MAX));
            if crate::interface_realizations::satisfies(session, class, interface) {
                check_class_methods(session, (class, interface), all_effects, &mut reports);
            }
        }
    }
    for syntax in reports {
        session.report(DiagnosticCode::PureFunctionInterfaceImpurity, syntax);
    }
}

fn check_class_methods(
    session: &AnalysisSession<'_>,
    (class, interface): (ClassId, InterfaceId),
    all_effects: &BTreeSet<usize>,
    reports: &mut Vec<usize>,
) {
    let Some(model) = session
        .module
        .interfaces
        .get(usize::try_from(interface.0).unwrap_or(usize::MAX))
        .cloned()
    else {
        return;
    };
    for expected in model.methods {
        if !expected.pure {
            continue;
        }
        let Some(found) = crate::hierarchy::find_method(session, class, &expected.name) else {
            continue;
        };
        let index = usize::try_from(found.0).unwrap_or(usize::MAX);
        if all_effects.contains(&index) {
            let syntax =
                crate::hierarchy::function(session, found).map_or(0, |declaration| declaration.syntax);
            reports.push(syntax);
        }
    }
}
