use crate::hir::{HirLocal, Passing};
use crate::identities::{LocalId, RecordId};
use crate::record_registry::slot;
use crate::session::AnalysisSession;

pub(crate) fn components(session: &mut AnalysisSession<'_>, local: LocalId, record: RecordId) {
    let Some(parent) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
    else {
        return;
    };
    let Some(model) = session.module.records.get(slot(record)).cloned() else {
        return;
    };
    let mut identifiers = Vec::new();
    for (leaf_type, leaf_name) in model.leaf_types.iter().zip(&model.leaf_names) {
        let identifier = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
        session.module.locals.push(HirLocal {
            name: format!("{}.{leaf_name}", parent.name),
            type_id: *leaf_type,
            passing: Passing::Value,
            span: parent.span,
            scope: parent.scope,
            parameter: parent.parameter,
        });
        session.initialized.push(parent.parameter);
        identifiers.push(identifier);
    }
    session.module.record_locals.insert(local, identifiers);
}
