use crate::expression_model::Literal;
use crate::identities::{FunctionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) const DEFAULT_STEP_LIMIT: u32 = 10_000;
pub(crate) const DEFAULT_TEXT_LIMIT: usize = 65_536;

#[derive(Clone, Copy, Debug)]
pub(crate) struct ConstantLimits {
    pub steps: u32,
    pub text_bytes: usize,
}

impl Default for ConstantLimits {
    fn default() -> Self {
        Self {
            steps: DEFAULT_STEP_LIMIT,
            text_bytes: DEFAULT_TEXT_LIMIT,
        }
    }
}

#[derive(Clone, Debug)]
pub(crate) enum ConstantState {
    Pending,
    Evaluating,
    Value(Literal, Type),
    Failed,
}

#[derive(Clone, Debug)]
pub(crate) struct ConstantEntry {
    pub unit: usize,
    pub scope: Option<FunctionId>,
    pub node: usize,
    pub name_node: usize,
    pub name: String,
    pub declared: TypeId,
    pub state: ConstantState,
}

pub(crate) fn collect_module(session: &mut AnalysisSession<'_>) {
    let Some(root) = session.tree.nodes.len().checked_sub(1) else {
        return;
    };
    for child in session.children(root) {
        if session.kind(child) == NodeKind::ConstantDeclaration {
            add(session, child, None);
        }
    }
}

pub(crate) fn collect_local(session: &mut AnalysisSession<'_>, node: usize) {
    add(session, node, Some(session.current));
}

fn add(session: &mut AnalysisSession<'_>, node: usize, scope: Option<FunctionId>) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let name = session.name(name_node);
    let duplicate = match scope {
        None => session.declared.constants.contains_key(&name),
        Some(_) => session.local(&name).is_some() || local_constant(session, &name).is_some(),
    };
    if duplicate {
        session.named_report(
            DiagnosticCode::DuplicateVariableDeclaration,
            name_node,
            &name,
        );
        return;
    }
    let declared = session
        .child(node, NodeKind::Type)
        .map(|kind| crate::type_resolution::resolve(session, kind))
        .unwrap_or_else(|| session.module.types.intern(Type::Error));
    let index = session.constants.len();
    session.constants.push(ConstantEntry {
        unit: session.unit,
        scope,
        node,
        name_node,
        name: name.clone(),
        declared,
        state: ConstantState::Pending,
    });
    insert_name(session, scope, (name, index));
}

fn insert_name(
    session: &mut AnalysisSession<'_>,
    scope: Option<FunctionId>,
    entry: (String, usize),
) {
    let names = match scope {
        None => Some(&mut session.declared.constants),
        Some(function) => usize::try_from(function.0)
            .ok()
            .and_then(|slot| session.local_constants.get_mut(slot)),
    };
    if let Some(names) = names {
        names.insert(entry.0, entry.1);
    }
}

pub(crate) fn local_constant(session: &AnalysisSession<'_>, name: &str) -> Option<usize> {
    usize::try_from(session.current.0)
        .ok()
        .and_then(|slot| session.local_constants.get(slot))
        .and_then(|names| names.get(name))
        .copied()
}

pub(crate) fn find_in(
    session: &AnalysisSession<'_>,
    scope: Option<FunctionId>,
    name: &str,
) -> Option<usize> {
    let local = scope
        .and_then(|function| usize::try_from(function.0).ok())
        .and_then(|slot| session.local_constants.get(slot))
        .and_then(|names| names.get(name))
        .copied();
    local.or_else(|| session.declared.constants.get(name).copied())
}

pub(crate) fn evaluate_all(session: &mut AnalysisSession<'_>) {
    for index in 0..session.constants.len() {
        let _ = crate::constant_evaluator::ensure(session, index, 0);
    }
}
