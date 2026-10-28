use crate::hir::{HirLocal, Passing};
use crate::identities::{LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn create(
    session: &mut AnalysisSession<'_>,
    name: String,
    kind: TypeId,
    parameter: bool,
) -> LocalId {
    let local = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    let span = usize::try_from(session.current.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
        .map(|function| function.span)
        .unwrap_or_default();
    session.module.locals.push(HirLocal {
        name,
        type_id: kind,
        passing: Passing::Value,
        span,
        scope: session.current,
        parameter,
        mutable: false,
    });
    session
        .initialized
        .resize(session.module.locals.len(), false);
    crate::binding_checker::mark_initialized(session, local);
    session.module.local_visibility.insert(local, span);
    if let Type::Record(record) = session.module.types.representation(kind) {
        crate::record_locals::components(session, local, record);
        crate::binding_checker::mark_initialized(session, local);
    }
    local
}

pub(crate) fn get(session: &AnalysisSession<'_>, local: LocalId) -> Option<HirLocal> {
    usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
}
