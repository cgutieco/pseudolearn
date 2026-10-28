use crate::identities::{LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn declare(
    session: &mut AnalysisSession<'_>,
    node: usize,
    type_id: TypeId,
    name: String,
) -> LocalId {
    let local = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    if !name.starts_with('$') {
        crate::scope_bindings::declare(
            session,
            name.clone(),
            crate::block_scopes::BindingTarget::Local(local),
            node,
        );
    }
    session.module.locals.push(crate::hir::HirLocal {
        name,
        type_id,
        passing: crate::hir::Passing::Value,
        span: session.span(node),
        scope: session.current,
        parameter: false,
        mutable: false,
    });
    session.initialized.push(true);
    initialize_components(session, local, type_id);
    local
}

fn initialize_components(session: &mut AnalysisSession<'_>, local: LocalId, type_id: TypeId) {
    let Type::Record(record) = session.module.types.get(type_id) else {
        return;
    };
    crate::record_locals::components(session, local, record);
    let components = session
        .module
        .record_locals
        .get(&local)
        .cloned()
        .unwrap_or_default();
    for component in components {
        if let Some(initialized) = session
            .initialized
            .get_mut(usize::try_from(component.0).unwrap_or(usize::MAX))
        {
            *initialized = true;
        }
    }
}
