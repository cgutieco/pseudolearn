use crate::hir::{HirRecord, HirRecordField};
use crate::identities::RecordId;
use crate::record_registry::slot;
use crate::session::AnalysisSession;
use crate::types::Type;
use crate::variant_model::{HirUserAlternative, HirUserVariant};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn declare_all(session: &mut AnalysisSession<'_>) -> Vec<RecordId> {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::VariantUnit)
        .map(|(index, _)| index)
        .filter(|node| !crate::generic_registry::is_generic(session, *node))
        .collect();
    nodes
        .into_iter()
        .filter_map(|node| declare(session, node))
        .collect()
}

fn declare(session: &mut AnalysisSession<'_>, node: usize) -> Option<RecordId> {
    let name_node = session.child(node, NodeKind::Identifier)?;
    let name = session.name(name_node);
    if crate::enum_registry::name_taken(session, &name) {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return None;
    }
    let label = session.link_name(&name);
    let identifier = placeholder(session, label, node);
    session.declared.variants.insert(name, identifier);
    Some(identifier)
}

pub(crate) fn placeholder(
    session: &mut AnalysisSession<'_>,
    name: String,
    node: usize,
) -> RecordId {
    let identifier = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    session.module.records.push(HirRecord {
        name,
        fields: Vec::new(),
        leaf_types: Vec::new(),
        leaf_names: Vec::new(),
        span: session.span(node),
        syntax: node,
    });
    identifier
}

pub(crate) fn alternatives(session: &mut AnalysisSession<'_>, variant: RecordId) {
    let Some(model) = session.module.records.get(slot(variant)).cloned() else {
        return;
    };
    let alternatives = collect(session, &model);
    if alternatives.is_empty()
        && let Some(name_node) = session.child(model.syntax, NodeKind::Identifier)
    {
        let name = session.name(name_node);
        session.named_report(DiagnosticCode::VariantWithoutAlternatives, name_node, &name);
    }
    let fields = payload_fields(session, &alternatives);
    if let Some(record) = session.module.records.get_mut(slot(variant)) {
        record.fields = fields;
    }
    session.module.user_variants.insert(
        variant,
        HirUserVariant {
            name: model.name,
            alternatives,
            syntax: model.syntax,
        },
    );
}

fn collect(session: &mut AnalysisSession<'_>, model: &HirRecord) -> Vec<HirUserAlternative> {
    let mut alternatives: Vec<HirUserAlternative> = Vec::new();
    for node in session.children(model.syntax) {
        if session.kind(node) != NodeKind::VariantAlternative {
            continue;
        }
        let Some(name_node) = session.child(node, NodeKind::Identifier) else {
            continue;
        };
        let name = session.name(name_node);
        if alternatives.iter().any(|existing| existing.name == name) {
            session.named_report(DiagnosticCode::DuplicateMember, name_node, &name);
            continue;
        }
        let spelling = session.lexeme(name_node).to_owned();
        let payload = payload(session, (&model.name, &spelling), node);
        alternatives.push(HirUserAlternative {
            name,
            spelling,
            payload,
        });
    }
    alternatives
}

fn payload_fields(
    session: &mut AnalysisSession<'_>,
    alternatives: &[HirUserAlternative],
) -> Vec<HirRecordField> {
    alternatives
        .iter()
        .filter_map(|alternative| {
            let payload = alternative.payload?;
            Some(HirRecordField {
                name: alternative.name.clone(),
                type_id: session.module.types.intern(Type::Record(payload)),
                offset: 0,
                width: 0,
            })
        })
        .collect()
}

fn payload(
    session: &mut AnalysisSession<'_>,
    (variant, alternative): (&str, &str),
    node: usize,
) -> Option<RecordId> {
    let fields: Vec<usize> = session
        .children(node)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::AlternativeField)
        .collect();
    if fields.is_empty() {
        return None;
    }
    let record = placeholder(session, format!("{variant}.{alternative}"), node);
    for field in fields {
        let (Some(name_node), Some(kind)) = (
            session.child(field, NodeKind::Identifier),
            session.child(field, NodeKind::Type),
        ) else {
            continue;
        };
        let type_id = crate::type_resolution::resolve(session, kind);
        let name = session.name(name_node);
        let Some(model) = session.module.records.get_mut(slot(record)) else {
            continue;
        };
        if model.fields.iter().any(|existing| existing.name == name) {
            session.named_report(DiagnosticCode::DuplicateMember, name_node, &name);
            continue;
        }
        model.fields.push(HirRecordField {
            name,
            type_id,
            offset: 0,
            width: 0,
        });
    }
    Some(record)
}
