use crate::identities::{RecordId, TypeId};
use crate::record_registry::slot;
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::{HirVariant, VariantFamily};
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn compute(session: &mut AnalysisSession<'_>, record: RecordId) {
    let Some(model) = session.module.user_variants.get(&record).cloned() else {
        return;
    };
    let first = session
        .module
        .records
        .get(slot(record))
        .is_some_and(|stored| !stored.fields.is_empty());
    if let Some(stored) = session.module.records.get_mut(slot(record)) {
        stored.fields.clear();
    }
    if model.alternatives.is_empty() {
        return;
    }
    let payloads: Vec<Option<TypeId>> = model
        .alternatives
        .iter()
        .map(|alternative| {
            alternative
                .payload
                .map(|payload| session.module.types.intern(Type::Record(payload)))
        })
        .collect();
    let Some(layout) = crate::variant_types::layout(session, VariantFamily::User, &payloads) else {
        if first {
            session.report(DiagnosticCode::VariantLayoutLimit, model.syntax);
        }
        return;
    };
    store(session, record, (payloads, layout));
}

fn store(
    session: &mut AnalysisSession<'_>,
    record: RecordId,
    (payloads, layout): (Vec<Option<TypeId>>, pseudolearn_abi::VariantLayout),
) {
    let offsets = crate::variant_types::offsets(&layout, &payloads);
    let (leaf_types, leaf_names) = crate::variant_types::slots(session, &layout);
    if let Some(stored) = session.module.records.get_mut(slot(record)) {
        stored.leaf_types = leaf_types;
        stored.leaf_names = leaf_names;
    }
    session.module.variants.insert(
        record,
        HirVariant {
            family: VariantFamily::User,
            payloads,
            offsets,
            layout,
        },
    );
}
