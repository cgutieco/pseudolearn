use crate::identities::{ExpressionId, FunctionId, LocalId};
use crate::session::AnalysisSession;
use pseudolearn_source::Span;
use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum AssignmentCause {
    NoAssignment,
    BranchWithoutElse,
    BranchWithoutAssignment,
    LoopMayNotRun,
    SwitchWithoutDefault,
}

impl AssignmentCause {
    pub(crate) fn term(self) -> &'static str {
        match self {
            Self::NoAssignment => "noAssignment",
            Self::BranchWithoutElse => "branchWithoutElse",
            Self::BranchWithoutAssignment => "branchWithoutAssignment",
            Self::LoopMayNotRun => "loopMayNotRun",
            Self::SwitchWithoutDefault => "switchWithoutDefault",
        }
    }
}

#[derive(Clone, Debug)]
pub(crate) struct PendingArgument {
    pub expression: ExpressionId,
    pub local: LocalId,
    pub span: Span,
    pub cause: Option<(AssignmentCause, Span)>,
}

#[derive(Clone, Debug)]
pub(crate) struct OutputObligation {
    pub local: LocalId,
    pub parameter: LocalId,
    pub span: Span,
    pub cause: Option<(AssignmentCause, Span)>,
}

#[derive(Clone, Debug, Default)]
pub(crate) struct AssignmentState {
    pub possibly: BTreeSet<LocalId>,
    pub dropped: BTreeMap<LocalId, (AssignmentCause, Span)>,
    pub reassigned: BTreeMap<LocalId, Span>,
    pub loop_depths: BTreeMap<LocalId, u32>,
    pub captures: Vec<(LocalId, Span)>,
    pub pending_arguments: Vec<PendingArgument>,
    pub candidates: BTreeSet<LocalId>,
    pub reused_controls: BTreeSet<LocalId>,
    pub not_output: BTreeSet<LocalId>,
    pub dependencies: BTreeMap<LocalId, BTreeSet<LocalId>>,
    pub obligations: Vec<OutputObligation>,
    pub call_edges: BTreeSet<(FunctionId, FunctionId)>,
    pub exits: Vec<Vec<(FlowPoint, Span)>>,
    pub locals: crate::local_indexes::LocalIndexes,
}

#[derive(Clone, Debug)]
pub(crate) struct FlowPoint {
    assigned: Vec<bool>,
    possibly: BTreeSet<LocalId>,
}

#[derive(Clone, Debug)]
pub(crate) struct FlowPath {
    pub point: FlowPoint,
    pub cause: AssignmentCause,
    pub origin: Span,
}

pub(crate) fn capture(session: &AnalysisSession<'_>) -> FlowPoint {
    FlowPoint {
        assigned: session.initialized.clone(),
        possibly: session.assignment.possibly.clone(),
    }
}

pub(crate) fn restore(session: &mut AnalysisSession<'_>, point: &FlowPoint) {
    session.initialized.clone_from(&point.assigned);
    session
        .initialized
        .resize(session.module.locals.len(), false);
    session.assignment.possibly.clone_from(&point.possibly);
}

pub(crate) fn path(point: FlowPoint, cause: AssignmentCause, origin: Span) -> FlowPath {
    FlowPath {
        point,
        cause,
        origin,
    }
}

pub(crate) fn merge(session: &mut AnalysisSession<'_>, paths: &[FlowPath]) {
    let length = session.module.locals.len();
    let mut assigned = vec![true; length];
    let mut possibly = BTreeSet::new();
    for path in paths {
        possibly.extend(path.point.possibly.iter().copied());
        for (index, value) in assigned.iter_mut().enumerate() {
            *value &= path.point.assigned.get(index).copied().unwrap_or(false);
        }
    }
    for (index, value) in assigned.iter().enumerate() {
        if *value {
            continue;
        }
        let local = LocalId(u32::try_from(index).unwrap_or(u32::MAX));
        let somewhere = paths
            .iter()
            .any(|path| path.point.assigned.get(index).copied().unwrap_or(false));
        if let Some(lacking) = paths
            .iter()
            .find(|path| !path.point.assigned.get(index).copied().unwrap_or(false))
            .filter(|_| somewhere)
        {
            session
                .assignment
                .dropped
                .insert(local, (lacking.cause, lacking.origin));
        }
    }
    session.initialized = assigned;
    session.assignment.possibly = possibly;
}

pub(crate) fn after_loop(session: &mut AnalysisSession<'_>, before: FlowPoint, origin: Span) {
    let current = capture(session);
    merge(
        session,
        &[
            path(before, AssignmentCause::LoopMayNotRun, origin),
            path(current, AssignmentCause::LoopMayNotRun, origin),
        ],
    );
}

pub(crate) fn terminate(session: &mut AnalysisSession<'_>) {
    let current = session.current;
    let owned = session
        .assignment
        .locals
        .scopes
        .owned_by(&session.module.locals, current)
        .to_vec();
    for index in owned {
        if let Some(assigned) = session.initialized.get_mut(index) {
            *assigned = true;
        }
    }
}

pub(crate) fn assign(session: &mut AnalysisSession<'_>, local: LocalId, span: Span) {
    let depth = session
        .assignment
        .loop_depths
        .get(&local)
        .copied()
        .unwrap_or(0);
    let repeated = session.assignment.possibly.contains(&local) || session.control.loops > depth;
    if repeated {
        let owners: Vec<LocalId> = session
            .module
            .record_locals
            .iter()
            .filter(|(_, leaves)| leaves.contains(&local))
            .map(|(owner, _)| *owner)
            .collect();
        for target in std::iter::once(local).chain(owners) {
            session.assignment.reassigned.entry(target).or_insert(span);
        }
    }
    initialize(session, local);
}

pub(crate) fn declare(session: &mut AnalysisSession<'_>, local: LocalId) {
    let depth = session.control.loops;
    session.assignment.loop_depths.insert(local, depth);
}

pub(crate) fn initialize(session: &mut AnalysisSession<'_>, local: LocalId) {
    let leaves = session
        .module
        .record_locals
        .get(&local)
        .cloned()
        .unwrap_or_default();
    for target in std::iter::once(local).chain(leaves) {
        session.assignment.possibly.insert(target);
        session.assignment.dropped.remove(&target);
    }
}

pub(crate) fn enter_loop(session: &mut AnalysisSession<'_>) {
    session.assignment.exits.push(Vec::new());
}

pub(crate) fn leave_loop(session: &mut AnalysisSession<'_>) -> Vec<(FlowPoint, Span)> {
    session.assignment.exits.pop().unwrap_or_default()
}

pub(crate) fn exit_loop(session: &mut AnalysisSession<'_>, origin: Span) {
    let point = capture(session);
    if let Some(exits) = session.assignment.exits.last_mut() {
        exits.push((point, origin));
    }
    terminate(session);
}

pub(crate) fn after_repeat(
    session: &mut AnalysisSession<'_>,
    exits: Vec<(FlowPoint, Span)>,
    origin: Span,
) {
    if exits.is_empty() {
        return;
    }
    let mut paths = vec![path(
        capture(session),
        AssignmentCause::BranchWithoutAssignment,
        origin,
    )];
    paths.extend(
        exits
            .into_iter()
            .map(|(point, exit)| path(point, AssignmentCause::BranchWithoutAssignment, exit)),
    );
    merge(session, &paths);
}

pub(crate) fn join_branches(
    session: &mut AnalysisSession<'_>,
    initial: &FlowPoint,
    paths: &[FlowPath],
) {
    if paths.is_empty() {
        restore(session, initial);
    } else {
        merge(session, paths);
    }
}
