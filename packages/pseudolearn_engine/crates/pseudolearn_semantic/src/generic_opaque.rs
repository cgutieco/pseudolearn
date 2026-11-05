use crate::generic_interfaces::InterfaceLookup;
use crate::generic_state::GenericTemplate;
use crate::hir::HirRecord;
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn arguments(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
) -> Vec<TypeId> {
    let fresh: Vec<(TypeId, bool)> = (0..template.parameters.len())
        .map(|index| parameter(session, template, index))
        .collect();
    let kinds: Vec<TypeId> = fresh.iter().map(|(kind, _)| *kind).collect();
    for (index, (kind, created)) in fresh.into_iter().enumerate() {
        if created {
            constrain(session, template, (index, kind), &kinds);
        }
    }
    kinds
}

fn parameter(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    index: usize,
) -> (TypeId, bool) {
    let key = (session.unit, template.node, index);
    if let Some(existing) = session.generic.opaque.get(&key) {
        return (*existing, false);
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
    let kind = session.module.types.intern(Type::Record(identifier));
    session.generic.opaque.insert(key, kind);
    (kind, true)
}

fn constrain(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (index, kind): (usize, TypeId),
    kinds: &[TypeId],
) {
    let Some(Some(name)) = template.constraints.get(index).cloned() else {
        return;
    };
    let Type::Record(identifier) = session.module.types.get(kind) else {
        return;
    };
    match crate::generic_interfaces::constraint(session, template, index, kinds) {
        InterfaceLookup::Found(interface) => {
            session.generic.constraints.insert(identifier, interface);
            crate::interface_constraints::record(session, template, index, interface);
        }
        InterfaceLookup::Reported => {}
        InterfaceLookup::Missing => {
            session.named_report(
                pseudolearn_diagnostics::DiagnosticCode::UnknownInterface,
                template.node,
                &name,
            );
        }
    }
}
