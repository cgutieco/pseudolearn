use crate::session::AnalysisSession;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    crate::enum_registry::register(session);
    crate::record_registry::register(session);
    crate::constant_registry::collect_module(session);
}

pub(crate) fn declare(session: &mut AnalysisSession<'_>) -> Vec<crate::identities::RecordId> {
    crate::enum_registry::register(session);
    let records = crate::record_registry::declare_all(session);
    crate::constant_registry::collect_module(session);
    records
}
