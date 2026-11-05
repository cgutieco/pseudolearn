use crate::generic_state::{GenericTemplate, INSTANCE_LIMIT};
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_syntax::NodeKind;

pub(crate) fn resolve(
    session: &mut AnalysisSession<'_>,
    (name, arguments): (&str, Option<usize>),
    origin: usize,
) -> Option<Option<RecordId>> {
    let template = session.generics.variants.get(name).cloned()?;
    let nodes = arguments
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if nodes.len() != template.parameters.len() {
        let counts = (name, template.parameters.len(), nodes.len());
        crate::generic_names::count_mismatch(session, origin, counts);
        return Some(None);
    }
    let kinds = nodes
        .into_iter()
        .map(|node| crate::type_resolution::resolve(session, node))
        .collect();
    Some(instantiate(session, &template, kinds, origin))
}

pub(crate) fn instantiate(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: Vec<TypeId>,
    origin: usize,
) -> Option<RecordId> {
    if !crate::interface_constraints::check(session, template, &arguments, origin) {
        return None;
    }
    let key = (session.unit, template.node, arguments.clone());
    if let Some(existing) = session.generic.records.get(&key) {
        return Some(*existing);
    }
    let name_node = session.child(template.node, NodeKind::Identifier)?;
    let name = session.name(name_node);
    if session.generic.instance_count() >= INSTANCE_LIMIT {
        crate::generic_records::report_limit(session, origin, &name);
        return None;
    }
    session.generic.instantiated = true;
    session.generic.count_record();
    let label =
        crate::generic_labels::instance_name(session, &session.link_name(&name), &arguments);
    let identifier = crate::user_variants::placeholder(session, label, template.node);
    session.generic.records.insert(key.clone(), identifier);
    session.generic.origins.insert(identifier, key);
    let environment = template.parameters.iter().cloned().zip(arguments).collect();
    let saved = std::mem::replace(&mut session.generic.environment, environment);
    crate::user_variants::alternatives(session, identifier);
    session.generic.environment = saved;
    crate::record_cycles::layout(session, &[identifier]);
    Some(identifier)
}

pub(crate) fn from_context(
    session: &AnalysisSession<'_>,
    template: &GenericTemplate,
    expected: Option<TypeId>,
) -> Option<RecordId> {
    let Type::Record(record) = session.module.types.get(expected?) else {
        return None;
    };
    let (unit, node, _) = session.generic.origins.get(&record)?;
    (*unit == session.unit && *node == template.node).then_some(record)
}

pub(crate) fn belongs(session: &AnalysisSession<'_>, name: &str, record: RecordId) -> bool {
    if session.declared.variants.get(name) == Some(&record) {
        return true;
    }
    let Some(template) = session.generics.variants.get(name) else {
        return false;
    };
    session
        .generic
        .origins
        .get(&record)
        .is_some_and(|(unit, node, _)| *unit == session.unit && *node == template.node)
}
