use crate::session::AnalysisSession;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    crate::enum_registry::register(session);
    crate::record_registry::register(session);
    crate::constant_registry::collect_module(session);
}
