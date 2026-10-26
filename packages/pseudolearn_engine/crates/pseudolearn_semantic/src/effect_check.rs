#![forbid(unsafe_code)]

use crate::hir::{FunctionKind, HirFunction};
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
    let all_effects = propagate_effects(&direct_effects, &call_edges);
    let mut reports = Vec::new();
    for (index, function) in session.module.functions.iter().enumerate() {
        if function.kind != FunctionKind::Function {
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
    body.iter().any(|id| statement_effects(session, *id, calls))
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
    match statement {
        HirStatement::Write { .. } | HirStatement::Read(_) => true,
        HirStatement::Call(expression_id) => {
            collect_calls(session, *expression_id, calls);
            false
        }
        HirStatement::Conditional { affirmative, negative, .. } => {
            block_has_effects(session, affirmative, calls)
                || block_has_effects(session, negative, calls)
        }
        HirStatement::While { body, .. }
        | HirStatement::Repeat { body, .. }
        | HirStatement::For { body, .. }
        | HirStatement::ForEach { body, .. }
        | HirStatement::Defer(body) => block_has_effects(session, body, calls),
        HirStatement::Switch { cases, default, .. } => {
            let cases_effect = cases
                .iter()
                .any(|branch| block_has_effects(session, &branch.body, calls));
            cases_effect || block_has_effects(session, default, calls)
        }
        _ => false,
    }
}

fn collect_calls(
    session: &AnalysisSession<'_>,
    expression_id: ExpressionId,
    calls: &mut BTreeSet<usize>,
) {
    let index = usize::try_from(expression_id.0).unwrap_or(usize::MAX);
    let Some(expression) = session.module.expressions.kinds.get(index) else {
        return;
    };
    if let crate::expression_model::HirExpression::Call { function, .. } = expression {
        let function_index = usize::try_from(function.0).unwrap_or(usize::MAX);
        calls.insert(function_index);
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
        if session.module.types.get(expected.signature.result) == crate::types::Type::Unit {
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
