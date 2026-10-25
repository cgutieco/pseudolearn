use crate::generic_state::{GenericTemplate, INSTANCE_LIMIT};
use crate::hir::HirRecord;
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::{DiagnosticArgument, DiagnosticCode};

pub(crate) fn instantiate(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: Vec<TypeId>,
    origin: usize,
) -> Option<RecordId> {
    let key = (session.unit, template.node, arguments.clone());
    if let Some(existing) = session.generic.records.get(&key) {
        return Some(*existing);
    }
    let name = record_name(session, template)?;
    if session.generic.instance_count() >= INSTANCE_LIMIT {
        report_limit(session, origin, &name);
        return None;
    }
    session.generic.instantiated = true;
    session.generic.count_record();
    let identifier = declare(session, template, &name, &arguments);
    session.generic.records.insert(key.clone(), identifier);
    session.generic.origins.insert(identifier, key);
    fill(session, template, (identifier, arguments));
    Some(identifier)
}

fn record_name(session: &AnalysisSession<'_>, template: &GenericTemplate) -> Option<String> {
    let name_node = session.child(template.node, pseudolearn_syntax::NodeKind::Identifier)?;
    Some(session.name(name_node))
}

fn declare(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    name: &str,
    arguments: &[TypeId],
) -> RecordId {
    let identifier = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let label = crate::generic_labels::instance_name(session, &session.link_name(name), arguments);
    session.module.records.push(HirRecord {
        name: label,
        fields: Vec::new(),
        leaf_types: Vec::new(),
        leaf_names: Vec::new(),
        span: session.span(template.node),
        syntax: template.node,
    });
    identifier
}

fn fill(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (identifier, arguments): (RecordId, Vec<TypeId>),
) {
    let saved = std::mem::take(&mut session.generic.environment);
    session.generic.environment = template.parameters.iter().cloned().zip(arguments).collect();
    crate::record_registry::fields(session, identifier);
    crate::record_cycles::layout(session, &[identifier]);
    session.generic.environment = saved;
}

pub(crate) fn report_limit(session: &mut AnalysisSession<'_>, origin: usize, name: &str) {
    session.named_report(DiagnosticCode::GenericInstanceLimitExceeded, origin, name);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.arguments.insert(
            "limit".to_owned(),
            DiagnosticArgument::Number(u64::try_from(INSTANCE_LIMIT).unwrap_or(u64::MAX).into()),
        );
    }
}
