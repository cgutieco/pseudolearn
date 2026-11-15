use crate::block_scopes::BindingTarget;
use crate::identities::{LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn candidate(session: &AnalysisSession<'_>, name_node: usize) -> Option<LocalId> {
    let name = session.name(name_node);
    let Some(BindingTarget::Local(local)) = session.bindings.current(&name) else {
        return None;
    };
    let index = usize::try_from(local.0).ok()?;
    let declaration = session.module.locals.get(index)?;
    let untouched = !session.initialized.get(index).copied().unwrap_or(true)
        && !session.assignment.possibly.contains(&local)
        && !session.reads.contains(&local)
        && !session.writes.contains(&local)
        && !session.invalid.contains(&local);
    let declared = !declaration.parameter
        && declaration.reassignable
        && declaration.scope == session.current
        && session.module.types.get(declaration.type_id) == Type::Integer;
    (untouched && declared).then_some(local)
}

pub(crate) fn bind(
    session: &mut AnalysisSession<'_>,
    integer: TypeId,
    control_node: usize,
    declared: LocalId,
) -> LocalId {
    let name = session.name(control_node);
    let control = crate::variant_bindings::create(session, (name.clone(), control_node), integer);
    session.bindings.insert(name, BindingTarget::Local(control));
    session.assignment.reused_controls.insert(declared);
    control
}
