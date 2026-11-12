use crate::hir::{HirClassRecordField, HirField};
use crate::identities::{ClassId, FieldId, RecordId, TypeId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn add(
    session: &mut AnalysisSession<'_>,
    class: ClassId,
    naming: (usize, String),
    attributes: (RecordId, TypeId, bool),
) {
    let (name_node, name) = naming;
    let (record, type_id, private) = attributes;
    if declared(session, class, &name) {
        session.named_report(DiagnosticCode::DuplicateMember, name_node, &name);
        return;
    }
    let span = session.span(name_node);
    let logical = HirField {
        id: crate::class_registry::next_field_id(session),
        name: name.clone(),
        type_id,
        owner: class,
        private,
        span,
    };
    session
        .module
        .class_record_fields
        .push(HirClassRecordField {
            field: logical,
            leaves: Vec::new(),
        });
    let leaves = leaf_fields(session, record, (class, &name, private, span));
    if let Some(entry) = session.module.class_record_fields.last_mut() {
        entry.leaves = leaves.iter().map(|leaf| leaf.id).collect();
    }
    if let Some(model) = usize::try_from(class.0)
        .ok()
        .and_then(|index| session.module.classes.get_mut(index))
    {
        model.fields.extend(leaves);
    }
}

fn declared(session: &AnalysisSession<'_>, class: ClassId, name: &str) -> bool {
    let index = usize::try_from(class.0).unwrap_or(usize::MAX);
    session
        .module
        .classes
        .get(index)
        .is_some_and(|model| model.fields.iter().any(|field| field.name == name))
        || session
            .module
            .class_record_fields
            .iter()
            .any(|entry| entry.field.owner == class && entry.field.name == name)
}

fn leaf_fields(
    session: &AnalysisSession<'_>,
    record: RecordId,
    owner: (ClassId, &str, bool, pseudolearn_source::Span),
) -> Vec<HirField> {
    let (class, name, private, span) = owner;
    let Some(model) = session
        .module
        .records
        .get(crate::record_registry::slot(record))
    else {
        return Vec::new();
    };
    let first = crate::class_registry::next_field_id(session).0;
    model
        .leaf_types
        .iter()
        .zip(&model.leaf_names)
        .enumerate()
        .map(|(position, (leaf_type, leaf_name))| HirField {
            id: FieldId(first.saturating_add(u32::try_from(position).unwrap_or(u32::MAX))),
            name: format!("{name}.{leaf_name}"),
            type_id: *leaf_type,
            owner: class,
            private,
            span,
        })
        .collect()
}
