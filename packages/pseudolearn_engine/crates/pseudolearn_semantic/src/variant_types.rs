use crate::hir::HirRecord;
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::{Type, ValueClass};
use crate::variant_model::{HirVariant, VariantFamily};
use pseudolearn_abi::{RecordBank, RecordLayout, VariantLayout};
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn get(session: &AnalysisSession<'_>, kind: &Type) -> Option<HirVariant> {
    let kind = crate::snapshot_types::underlying(session, kind);
    let Type::Record(record) = kind else {
        return None;
    };
    session.module.variants.get(&record).cloned()
}

pub(crate) fn leaves(session: &AnalysisSession<'_>, kind: TypeId) -> Vec<TypeId> {
    match session.module.types.representation(kind) {
        Type::Record(record) => usize::try_from(record.0)
            .ok()
            .and_then(|index| session.module.records.get(index))
            .map(|record| record.leaf_types.clone())
            .unwrap_or_default(),
        _ => vec![kind],
    }
}

pub(crate) fn register(
    session: &mut AnalysisSession<'_>,
    family: VariantFamily,
    payloads: Vec<Option<TypeId>>,
    node: usize,
) -> TypeId {
    if let Some(record) = session
        .module
        .variants
        .iter()
        .find_map(|(record, variant)| {
            (variant.family == family && variant.payloads == payloads).then_some(*record)
        })
    {
        return session.module.types.intern(Type::Record(record));
    }
    let Some(layout) = layout(session, family, &payloads) else {
        session.report(DiagnosticCode::VariantLayoutLimit, node);
        return session.module.types.intern(Type::Error);
    };
    let offsets = offsets(&layout, &payloads);
    insert(session, (family, payloads), (layout, offsets), node)
}

fn insert(
    session: &mut AnalysisSession<'_>,
    identity: (VariantFamily, Vec<Option<TypeId>>),
    storage: (VariantLayout, Vec<Vec<u32>>),
    node: usize,
) -> TypeId {
    let (family, payloads) = identity;
    let (layout, offsets) = storage;
    let integer = session.module.types.intern(Type::Integer);
    let reference = session.module.types.intern(Type::String);
    let mut leaf_types = vec![integer; usize::try_from(layout.scalar_words()).unwrap_or(0)];
    leaf_types.extend(vec![
        reference;
        usize::try_from(layout.reference_words()).unwrap_or(0)
    ]);
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    session.module.records.push(HirRecord {
        name: format!("{family:?}{payloads:?}"),
        fields: Vec::new(),
        leaf_names: (0..leaf_types.len())
            .map(|index| format!("slot{index}"))
            .collect(),
        leaf_types,
        span: session.span(node),
        syntax: node,
    });
    session.module.variants.insert(
        record,
        HirVariant {
            family,
            payloads,
            offsets,
            layout,
        },
    );
    session.module.types.intern(Type::Record(record))
}

fn layout(
    session: &AnalysisSession<'_>,
    family: VariantFamily,
    payloads: &[Option<TypeId>],
) -> Option<VariantLayout> {
    let mut alternatives = Vec::new();
    for payload in payloads {
        let banks: Vec<_> = payload
            .map(|payload| leaves(session, payload))
            .unwrap_or_default()
            .iter()
            .map(|kind| match session.module.types.value_class(*kind) {
                ValueClass::Reference => RecordBank::Reference,
                _ => RecordBank::Scalar,
            })
            .collect();
        alternatives.push(RecordLayout::from_banks(&banks).ok()?);
    }
    let niche =
        family == VariantFamily::Optional
            && payloads.get(1).copied().flatten().is_some_and(|kind| {
                session.module.types.value_class(kind) == ValueClass::Reference
            });
    if niche {
        VariantLayout::optional(alternatives.get(1)?.clone()).ok()
    } else {
        VariantLayout::tagged(&alternatives).ok()
    }
}

fn offsets(layout: &VariantLayout, payloads: &[Option<TypeId>]) -> Vec<Vec<u32>> {
    payloads
        .iter()
        .enumerate()
        .map(|(index, _)| {
            let Some(payload) = layout.payload(index) else {
                return Vec::new();
            };
            (0..payload.leaf_count())
                .filter_map(|position| payload.leaf(position))
                .map(|leaf| match leaf.bank {
                    RecordBank::Scalar => leaf
                        .offset
                        .saturating_add(u32::from(!layout.uses_reference_niche())),
                    RecordBank::Reference => layout.scalar_words().saturating_add(leaf.offset),
                })
                .collect()
        })
        .collect()
}
