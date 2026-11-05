use crate::hir::HirLocal;
use crate::identities::{LocalId, RecordId};
use crate::record_registry::slot;
use crate::session::AnalysisSession;

pub(crate) fn leaf_count(session: &AnalysisSession<'_>, record: RecordId) -> usize {
    session
        .module
        .records
        .get(slot(record))
        .map_or(0, |model| model.leaf_types.len())
}

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
            passing: parent.passing,
            span: parent.span,
            scope: parent.scope,
            parameter: parent.parameter,
            reassignable: parent.reassignable,
        });
        session.initialized.push(parent.parameter);
        identifiers.push(identifier);
    }
    session.module.record_locals.insert(local, identifiers);
}

pub(crate) fn array_components(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    (record, rank): (RecordId, u32),
) {
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
        let array = session.module.types.intern(crate::types::Type::Array {
            element: *leaf_type,
            rank,
        });
        session.module.locals.push(HirLocal {
            name: format!("{}.{leaf_name}", parent.name),
            type_id: array,
            passing: parent.passing,
            span: parent.span,
            scope: parent.scope,
            parameter: parent.parameter,
            reassignable: parent.reassignable,
        });
        session.initialized.push(parent.parameter);
        identifiers.push(identifier);
    }
    session.module.record_locals.insert(local, identifiers);
}
