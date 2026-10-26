use crate::generic_state::GenericTemplate;
use crate::hir::HirRecord;
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn arguments(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
) -> Vec<TypeId> {
    (0..template.parameters.len())
        .map(|index| parameter(session, template, index))
        .collect()
}

fn parameter(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    index: usize,
) -> TypeId {
    let key = (session.unit, template.node, index);
    if let Some(existing) = session.generic.opaque.get(&key) {
        return *existing;
    }
    let identifier = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let name = template.parameters.get(index).cloned().unwrap_or_default();
    session.module.records.push(HirRecord {
        name,
        fields: Vec::new(),
        leaf_types: Vec::new(),
        leaf_names: Vec::new(),
        span: session.span(template.node),
        syntax: template.node,
    });
    session.generic.opaque_records.insert(identifier);
    if let Some(Some(name)) = template.constraints.get(index) {
        if let Some(interface) = crate::interface_registry::find(session, name) {
            session.generic.constraints.insert(identifier, interface);
            crate::interface_constraints::record(session, template, index, interface);
        } else {
            session.named_report(
                pseudolearn_diagnostics::DiagnosticCode::UnknownInterface,
                template.node,
                name,
            );
        }
    }
    let kind = session.module.types.intern(Type::Record(identifier));
    session.generic.opaque.insert(key, kind);
    kind
}
