use crate::hir::{HirRecord, HirRecordField};
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::VariantFamily;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn task_error(session: &AnalysisSession<'_>, kind: &Type) -> Option<TypeId> {
    let variant = crate::variant_types::get(session, kind)?;
    (variant.family == VariantFamily::Result).then_some(())?;
    variant.payloads.get(1).copied().flatten()
}

pub(crate) fn spawned(session: &mut AnalysisSession<'_>, kind: &Type, node: usize) {
    let Some(error) = task_error(session, kind) else {
        return;
    };
    if !transferable(session, error) {
        session.report(DiagnosticCode::TaskErrorNotTransferable, node);
    }
    let Some(errors) = session.control.task_errors.last_mut() else {
        return;
    };
    if errors.first().is_some_and(|previous| *previous != error) {
        session.report(DiagnosticCode::TaskScopeErrorTypeMismatch, node);
    } else if let Some(errors) = session.control.task_errors.last_mut() {
        errors.push(error);
    }
}

pub(crate) fn transferable(session: &AnalysisSession<'_>, kind: TypeId) -> bool {
    match session.module.types.get(kind) {
        Type::Integer
        | Type::Real
        | Type::Boolean
        | Type::Character
        | Type::String
        | Type::Enum(_) => true,
        Type::Record(record) => record_transferable(session, record),
        Type::Object(class) => session.module.opaque_types.contains_key(&class),
        Type::Error => true,
        _ => false,
    }
}

fn record_transferable(session: &AnalysisSession<'_>, record: RecordId) -> bool {
    if session.module.function_types.contains_key(&record) {
        return false;
    }
    if let Some(variant) = session.module.variants.get(&record) {
        return variant
            .payloads
            .iter()
            .flatten()
            .all(|kind| transferable(session, *kind));
    }
    if let Some(error) = session.module.task_failures.get(&record) {
        return transferable(session, *error);
    }
    session
        .module
        .records
        .get(usize::try_from(record.0).unwrap_or(usize::MAX))
        .is_some_and(|model| {
            model
                .leaf_types
                .iter()
                .all(|kind| transferable(session, *kind))
        })
}

pub(crate) fn optional(session: &mut AnalysisSession<'_>, error: TypeId, node: usize) -> TypeId {
    let failure = register(session, error, node);
    crate::variant_types::register(
        session,
        VariantFamily::Optional,
        vec![None, Some(failure)],
        node,
    )
}

fn register(session: &mut AnalysisSession<'_>, error: TypeId, node: usize) -> TypeId {
    if let Some(record) = session
        .module
        .task_failures
        .iter()
        .find_map(|(record, found)| (*found == error).then_some(*record))
    {
        return session.module.types.intern(Type::Record(record));
    }
    let collection = crate::collection_types::register(session, node, (None, error));
    let associated = session.module.types.intern(Type::Object(collection));
    let integer = session.module.types.intern(Type::Integer);
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let spanish = session.options.profile == pseudolearn_lexicon::Profile::Spanish;
    let names = if spanish {
        ["Primero", "Asociados", "Canceladas"]
    } else {
        ["first", "associated", "cancelled"]
    };
    let mut leaf_types = Vec::new();
    let mut fields = Vec::new();
    for (name, kind) in names.into_iter().zip([error, associated, integer]) {
        let leaves = crate::variant_types::leaves(session, kind);
        fields.push(HirRecordField {
            name: name.to_owned(),
            type_id: kind,
            offset: u32::try_from(leaf_types.len()).unwrap_or(u32::MAX),
            width: u32::try_from(leaves.len()).unwrap_or(u32::MAX),
        });
        leaf_types.extend(leaves);
    }
    insert(session, (record, error), (fields, leaf_types), node)
}

fn insert(
    session: &mut AnalysisSession<'_>,
    identity: (RecordId, TypeId),
    fields: (Vec<HirRecordField>, Vec<TypeId>),
    node: usize,
) -> TypeId {
    session.module.records.push(HirRecord {
        name: format!("$taskFailure:{}", identity.1.0),
        leaf_names: (0..fields.1.len())
            .map(|index| format!("slot{index}"))
            .collect(),
        fields: fields.0,
        leaf_types: fields.1,
        span: session.span(node),
        syntax: node,
    });
    session.module.task_failures.insert(identity.0, identity.1);
    session.module.types.intern(Type::Record(identity.0))
}

pub(crate) fn is_failure(session: &AnalysisSession<'_>, kind: &Type) -> bool {
    crate::variant_types::get(session, kind)
        .filter(|variant| variant.family == VariantFamily::Optional)
        .and_then(|variant| variant.payloads.get(1).copied().flatten())
        .is_some_and(|payload| matches!(session.module.types.get(payload), Type::Record(record) if session.module.task_failures.contains_key(&record)))
}

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    if crate::collection_types::identity(session, name) != Some("taskFailureType") {
        return None;
    }
    let arguments = session
        .child(node, pseudolearn_syntax::NodeKind::TypeArguments)
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if arguments.len() != 1 {
        crate::generic_names::count_mismatch(session, node, (name, 1, arguments.len()));
        return Some(Type::Error);
    }
    let error = crate::type_resolution::resolve(session, *arguments.first()?);
    if !transferable(session, error) {
        session.report(DiagnosticCode::TaskErrorNotTransferable, node);
    }
    let kind = register(session, error, node);
    Some(session.module.types.get(kind))
}
