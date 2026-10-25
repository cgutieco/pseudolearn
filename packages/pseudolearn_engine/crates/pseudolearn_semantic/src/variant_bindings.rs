use crate::hir::{HirLocal, Passing};
use crate::identities::{LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn temporary(session: &mut AnalysisSession<'_>, kind: TypeId, node: usize) -> LocalId {
    create(
        session,
        (format!("$match{}", session.module.locals.len()), node),
        kind,
    )
}

pub(crate) fn pattern(session: &mut AnalysisSession<'_>, kind: TypeId, node: usize) -> LocalId {
    let name = session.name(node);
    let local = create(session, (name.clone(), node), kind);
    crate::scope_bindings::declare(
        session,
        name,
        crate::block_scopes::BindingTarget::Local(local),
        node,
    );
    local
}

fn create(session: &mut AnalysisSession<'_>, naming: (String, usize), kind: TypeId) -> LocalId {
    let local = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    session.module.locals.push(HirLocal {
        name: naming.0,
        type_id: kind,
        passing: Passing::Value,
        span: session.span(naming.1),
        scope: session.current,
        parameter: false,
        mutable: false,
    });
    session.initialized.push(true);
    if let Type::Record(record) = session.module.types.get(kind) {
        crate::record_locals::components(session, local, record);
        crate::binding_checker::mark_initialized(session, local);
    }
    local
}
