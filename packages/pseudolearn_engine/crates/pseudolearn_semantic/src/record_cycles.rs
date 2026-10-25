use crate::hir::HirRecordField;
use crate::identities::RecordId;
use crate::record_registry::{field_kind, record_syntax, slot};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

const UNVISITED: u8 = 0;
const ACTIVE: u8 = 1;
const DONE: u8 = 2;

pub(crate) fn layout(session: &mut AnalysisSession<'_>, records: &[RecordId]) {
    let mut states = vec![UNVISITED; session.module.records.len()];
    for root in records {
        if states.get(slot(*root)).copied() != Some(UNVISITED) {
            continue;
        }
        walk(session, *root, &mut states);
    }
}

fn walk(session: &mut AnalysisSession<'_>, root: RecordId, states: &mut [u8]) {
    let mut stack = vec![(root, 0_usize)];
    set(states, root, ACTIVE);
    while let Some(&(record, cursor)) = stack.last() {
        let count = session
            .module
            .records
            .get(slot(record))
            .map_or(0, |model| model.fields.len());
        if cursor >= count {
            stack.pop();
            set(states, record, DONE);
            compute(session, record);
            continue;
        }
        if let Some(top) = stack.last_mut() {
            top.1 = cursor.saturating_add(1);
        }
        if let Type::Record(next) = field_kind(session, record, cursor) {
            descend(session, (record, cursor), next, (&mut stack, states));
        }
    }
}

fn descend(
    session: &mut AnalysisSession<'_>,
    origin: (RecordId, usize),
    next: RecordId,
    (stack, states): (&mut Vec<(RecordId, usize)>, &mut [u8]),
) {
    match states.get(slot(next)).copied() {
        Some(UNVISITED) => {
            set(states, next, ACTIVE);
            stack.push((next, 0));
        }
        Some(ACTIVE) => break_cycle(session, origin),
        _ => {}
    }
}

fn break_cycle(session: &mut AnalysisSession<'_>, origin: (RecordId, usize)) {
    let (record, cursor) = origin;
    let error = session.module.types.intern(Type::Error);
    if let Some(syntax) = record_syntax(session, record)
        && let Some(name_node) = session.child(syntax, NodeKind::Identifier)
    {
        let name = session.name(name_node);
        session.named_report(DiagnosticCode::RecursiveRecordContainment, name_node, &name);
    }
    if let Some(field) = session
        .module
        .records
        .get_mut(slot(record))
        .and_then(|model| model.fields.get_mut(cursor))
    {
        field.type_id = error;
    }
}

fn set(states: &mut [u8], record: RecordId, state: u8) {
    if let Some(entry) = states.get_mut(slot(record)) {
        *entry = state;
    }
}

fn leaves_of(
    session: &AnalysisSession<'_>,
    field: &HirRecordField,
) -> (Vec<crate::identities::TypeId>, Vec<String>) {
    let nested = match session.module.types.get(field.type_id) {
        Type::Record(inner) => session.module.records.get(slot(inner)),
        _ => None,
    };
    match nested {
        Some(inner) => (
            inner.leaf_types.clone(),
            inner
                .leaf_names
                .iter()
                .map(|leaf| format!("{}.{leaf}", field.name))
                .collect(),
        ),
        None => (vec![field.type_id], vec![field.name.clone()]),
    }
}

fn compute(session: &mut AnalysisSession<'_>, record: RecordId) {
    let Some(model) = session.module.records.get(slot(record)).cloned() else {
        return;
    };
    let mut fields: Vec<HirRecordField> = Vec::new();
    let mut leaf_types = Vec::new();
    let mut leaf_names = Vec::new();
    let mut offset = 0_u32;
    for field in model.fields {
        let (types, names) = leaves_of(session, &field);
        let width = u32::try_from(types.len()).unwrap_or(u32::MAX);
        leaf_types.extend(types);
        leaf_names.extend(names);
        fields.push(HirRecordField {
            offset,
            width,
            ..field
        });
        offset = offset.saturating_add(width);
    }
    if let Some(target) = session.module.records.get_mut(slot(record)) {
        target.fields = fields;
        target.leaf_types = leaf_types;
        target.leaf_names = leaf_names;
    }
}
