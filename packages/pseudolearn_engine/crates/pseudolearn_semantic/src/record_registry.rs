use crate::hir::{HirRecord, HirRecordField};
use crate::identities::RecordId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::RecordUnit)
        .map(|(index, _)| index)
        .filter(|node| !crate::generic_registry::is_generic(session, *node))
        .collect();
    let records: Vec<RecordId> = nodes
        .into_iter()
        .filter_map(|node| declare(session, node))
        .collect();
    for record in &records {
        fields(session, *record);
    }
    crate::record_cycles::layout(session, &records);
}

fn declare(session: &mut AnalysisSession<'_>, node: usize) -> Option<RecordId> {
    let name_node = session.child(node, NodeKind::Identifier)?;
    let name = session.name(name_node);
    if crate::enum_registry::name_taken(session, &name) {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return None;
    }
    let identifier = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    session.module.records.push(HirRecord {
        name: session.link_name(&name),
        fields: Vec::new(),
        leaf_types: Vec::new(),
        leaf_names: Vec::new(),
        span: session.span(node),
        syntax: node,
    });
    session.declared.records.insert(name, identifier);
    Some(identifier)
}

pub(crate) fn fields(session: &mut AnalysisSession<'_>, record: RecordId) {
    let Some(syntax) = record_syntax(session, record) else {
        return;
    };
    for child in session.children(syntax) {
        if session.kind(child) == NodeKind::RecordField {
            declaration_fields(session, record, child);
        }
    }
    let empty = session
        .module
        .records
        .get(slot(record))
        .is_some_and(|model| model.fields.is_empty());
    if let (true, Some(name_node)) = (empty, session.child(syntax, NodeKind::Identifier)) {
        let name = session.name(name_node);
        session.named_report(DiagnosticCode::RecordWithoutFields, name_node, &name);
    }
}

fn declaration_fields(session: &mut AnalysisSession<'_>, record: RecordId, field: usize) {
    let Some(declaration) = session.child(field, NodeKind::Declaration) else {
        return;
    };
    let Some(kind) = session.child(declaration, NodeKind::Type) else {
        return;
    };
    let type_id = crate::type_resolution::resolve(session, kind);
    for name_node in session.children(declaration) {
        if session.kind(name_node) != NodeKind::Identifier {
            continue;
        }
        let name = session.name(name_node);
        let duplicate = session
            .module
            .records
            .get(slot(record))
            .is_some_and(|model| model.fields.iter().any(|existing| existing.name == name));
        if duplicate {
            session.named_report(DiagnosticCode::DuplicateMember, name_node, &name);
            continue;
        }
        if let Some(model) = session.module.records.get_mut(slot(record)) {
            model.fields.push(HirRecordField {
                name,
                type_id,
                offset: 0,
                width: 0,
            });
        }
    }
}

pub(crate) fn slot(record: RecordId) -> usize {
    usize::try_from(record.0).unwrap_or(usize::MAX)
}

pub(crate) fn record_syntax(session: &AnalysisSession<'_>, record: RecordId) -> Option<usize> {
    session
        .module
        .records
        .get(slot(record))
        .map(|model| model.syntax)
}

pub(crate) fn field_kind(session: &AnalysisSession<'_>, record: RecordId, field: usize) -> Type {
    session
        .module
        .records
        .get(slot(record))
        .and_then(|model| model.fields.get(field))
        .map(|field| session.module.types.get(field.type_id))
        .unwrap_or(Type::Error)
}
