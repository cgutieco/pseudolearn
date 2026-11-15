use crate::definite_assignment_state::OutputObligation;
use crate::expression_model::HirPlace;
use crate::hir::Passing;
use crate::identities::{ExpressionId, FunctionId, LocalId};
use crate::session::AnalysisSession;
use crate::types::Type;
use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Dispatch {
    Direct,
    Dynamic,
}

pub(crate) fn prepare(session: &mut AnalysisSession<'_>, parameters: &[LocalId]) {
    for parameter in parameters {
        let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
        else {
            continue;
        };
        let kind = session.module.types.representation(local.type_id);
        if local.passing != Passing::Reference
            || matches!(kind, Type::Array { .. } | Type::Record(_))
            || session.invalid.contains(parameter)
        {
            continue;
        }
        session.assignment.candidates.insert(*parameter);
        if let Some(assigned) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.initialized.get_mut(index))
        {
            *assigned = false;
        }
        session.assignment.possibly.remove(parameter);
    }
}

pub(crate) fn reference_argument(
    session: &mut AnalysisSession<'_>,
    argument: ExpressionId,
    target: (Option<LocalId>, Dispatch),
) {
    let pending = crate::definite_assignment_report::take_argument(session, argument);
    let Some(HirPlace::Local(local)) = crate::expression_checker::place(session, argument) else {
        if let Some(pending) = pending {
            crate::definite_assignment_report::report(
                session,
                pending.local,
                pending.span,
                pending.cause,
            );
        }
        return;
    };
    let span = usize::try_from(argument.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .copied()
        .unwrap_or_default();
    if let Some(pending) = pending {
        unassigned_argument(session, pending, target);
    }
    crate::definite_assignment_state::assign(session, local, span);
    crate::binding_checker::mark_initialized(session, local);
}

fn unassigned_argument(
    session: &mut AnalysisSession<'_>,
    pending: crate::definite_assignment_state::PendingArgument,
    target: (Option<LocalId>, Dispatch),
) {
    let candidate = session.assignment.candidates.contains(&pending.local);
    match target {
        (Some(parameter), Dispatch::Direct) if candidate => {
            session
                .assignment
                .dependencies
                .entry(pending.local)
                .or_default()
                .insert(parameter);
        }
        (Some(parameter), Dispatch::Direct) => {
            session.assignment.obligations.push(OutputObligation {
                local: pending.local,
                parameter,
                span: pending.span,
                cause: pending.cause,
            });
        }
        _ if candidate => {
            session.assignment.not_output.insert(pending.local);
        }
        _ => crate::definite_assignment_report::report(
            session,
            pending.local,
            pending.span,
            pending.cause,
        ),
    }
}

pub(crate) fn leave(session: &mut AnalysisSession<'_>) {
    let current = session.current;
    let unassigned: Vec<LocalId> = session
        .assignment
        .candidates
        .iter()
        .copied()
        .filter(|candidate| {
            usize::try_from(candidate.0).is_ok_and(|index| {
                session
                    .module
                    .locals
                    .get(index)
                    .is_some_and(|local| local.scope == current)
                    && !session.initialized.get(index).copied().unwrap_or(false)
            })
        })
        .collect();
    session.assignment.not_output.extend(unassigned);
}

pub(crate) fn call(session: &mut AnalysisSession<'_>, callee: FunctionId) {
    let caller = session.current;
    session.assignment.call_edges.insert((caller, callee));
}

pub(crate) fn finish(session: &mut AnalysisSession<'_>) {
    let recursive = recursive_functions(&session.assignment.call_edges);
    let mut decided = BTreeMap::new();
    let candidates: Vec<LocalId> = session.assignment.candidates.iter().copied().collect();
    for candidate in candidates {
        resolve(session, candidate, (&recursive, &mut decided));
    }
    let obligations = std::mem::take(&mut session.assignment.obligations);
    for obligation in obligations {
        if decided.get(&obligation.parameter).copied().unwrap_or(false) {
            continue;
        }
        crate::definite_assignment_report::report(
            session,
            obligation.local,
            obligation.span,
            obligation.cause,
        );
    }
}

fn resolve(
    session: &AnalysisSession<'_>,
    parameter: LocalId,
    (recursive, decided): (&BTreeSet<FunctionId>, &mut BTreeMap<LocalId, bool>),
) -> bool {
    let mut visiting = BTreeSet::new();
    decide(session, parameter, (recursive, decided, &mut visiting))
}

fn decide(
    session: &AnalysisSession<'_>,
    parameter: LocalId,
    (recursive, decided, visiting): (
        &BTreeSet<FunctionId>,
        &mut BTreeMap<LocalId, bool>,
        &mut BTreeSet<LocalId>,
    ),
) -> bool {
    if let Some(known) = decided.get(&parameter) {
        return *known;
    }
    if !visiting.insert(parameter) {
        return false;
    }
    let mut output = locally_output(session, parameter, recursive);
    let targets: Vec<LocalId> = session
        .assignment
        .dependencies
        .get(&parameter)
        .map(|next| next.iter().copied().collect())
        .unwrap_or_default();
    for target in targets {
        output &= decide(session, target, (recursive, decided, visiting));
    }
    visiting.remove(&parameter);
    decided.insert(parameter, output);
    output
}

fn locally_output(
    session: &AnalysisSession<'_>,
    parameter: LocalId,
    recursive: &BTreeSet<FunctionId>,
) -> bool {
    session.assignment.candidates.contains(&parameter)
        && !session.assignment.not_output.contains(&parameter)
        && usize::try_from(parameter.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .is_some_and(|local| !recursive.contains(&local.scope))
}

fn recursive_functions(edges: &BTreeSet<(FunctionId, FunctionId)>) -> BTreeSet<FunctionId> {
    let mut adjacency: BTreeMap<FunctionId, Vec<FunctionId>> = BTreeMap::new();
    for (caller, callee) in edges {
        adjacency.entry(*caller).or_default().push(*callee);
    }
    adjacency
        .keys()
        .copied()
        .filter(|start| reaches(&adjacency, *start))
        .collect()
}

fn reaches(adjacency: &BTreeMap<FunctionId, Vec<FunctionId>>, start: FunctionId) -> bool {
    let mut seen = BTreeSet::new();
    let mut stack: Vec<FunctionId> = adjacency.get(&start).cloned().unwrap_or_default();
    while let Some(current) = stack.pop() {
        if current == start {
            return true;
        }
        if seen.insert(current)
            && let Some(next) = adjacency.get(&current)
        {
            stack.extend(next.iter().copied());
        }
    }
    false
}
