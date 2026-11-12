use crate::generic_state::{GenericTemplate, INSTANCE_LIMIT};
use crate::identities::TypeId;
use crate::interface_model::{HirInterface, InterfaceId};
use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) enum InterfaceLookup {
    Found(InterfaceId),
    Reported,
    Missing,
}

pub(crate) fn resolve(
    session: &mut AnalysisSession<'_>,
    name: &str,
    arguments: Option<usize>,
    origin: usize,
) -> InterfaceLookup {
    let Some(template) = session.generics.interfaces.get(name).cloned() else {
        let Some(found) = crate::interface_registry::find(session, name) else {
            return InterfaceLookup::Missing;
        };
        let Some(arguments) = arguments else {
            return InterfaceLookup::Found(found);
        };
        let count = session.children(arguments).len();
        crate::generic_names::count_mismatch(session, origin, (name, 0, count));
        return InterfaceLookup::Reported;
    };
    let nodes = arguments
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if nodes.len() != template.parameters.len() {
        let counts = (name, template.parameters.len(), nodes.len());
        crate::generic_names::count_mismatch(session, origin, counts);
        return InterfaceLookup::Reported;
    }
    let kinds = nodes
        .into_iter()
        .map(|node| crate::type_resolution::resolve(session, node))
        .collect();
    instantiate(session, &template, kinds, origin)
        .map_or(InterfaceLookup::Reported, InterfaceLookup::Found)
}

pub(crate) fn constraint(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    index: usize,
    arguments: &[TypeId],
) -> InterfaceLookup {
    let Some(Some(name)) = template.constraints.get(index).cloned() else {
        return InterfaceLookup::Missing;
    };
    let node = template
        .constraint_nodes
        .get(index)
        .copied()
        .unwrap_or(template.node);
    let type_arguments = session.child(node, NodeKind::TypeArguments);
    let environment = template
        .parameters
        .iter()
        .cloned()
        .zip(arguments.iter().copied())
        .collect();
    let saved = std::mem::replace(&mut session.generic.environment, environment);
    let found = resolve(session, &name, type_arguments, node);
    session.generic.environment = saved;
    found
}

pub(crate) fn define(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: Vec<TypeId>,
) {
    instantiate(session, template, arguments, template.node);
}

fn instantiate(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: Vec<TypeId>,
    origin: usize,
) -> Option<InterfaceId> {
    let key = (template.unit, template.node, arguments.clone());
    if let Some(existing) = session.generic.interfaces.get(&key) {
        return Some(*existing);
    }
    let name = crate::generic_home::template_name(session, template)?;
    if session.generic.instance_count() >= INSTANCE_LIMIT {
        crate::generic_records::report_limit(session, origin, &name);
        return None;
    }
    session.generic.instantiated = true;
    session.generic.count_record();
    Some(crate::generic_home::at_home(session, template, |session| {
        declare(session, template, (key, &name), arguments)
    }))
}

fn declare(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (key, name): (crate::generic_state::InstanceKey, &str),
    arguments: Vec<TypeId>,
) -> InterfaceId {
    let identifier =
        InterfaceId(u32::try_from(session.module.interfaces.len()).unwrap_or(u32::MAX));
    let label = crate::generic_labels::instance_name(session, name, &arguments);
    session.module.interfaces.push(HirInterface {
        name: label,
        unit: session.unit,
        syntax: template.node,
        span: session.span(template.node),
        methods: Vec::new(),
    });
    session.generic.interfaces.insert(key, identifier);
    let environment = template.parameters.iter().cloned().zip(arguments).collect();
    session
        .generic
        .interface_environments
        .insert(identifier, environment);
    if session.generic.signatures_ready {
        fill(session, identifier);
    }
    identifier
}

pub(crate) fn fill(session: &mut AnalysisSession<'_>, interface: InterfaceId) {
    let Some(environment) = session
        .generic
        .interface_environments
        .get(&interface)
        .cloned()
    else {
        return;
    };
    let Some(syntax) = usize::try_from(interface.0)
        .ok()
        .and_then(|index| session.module.interfaces.get(index))
        .map(|model| model.syntax)
    else {
        return;
    };
    let saved = std::mem::replace(&mut session.generic.environment, environment);
    let methods = crate::interface_registry::methods_of(session, syntax);
    session.generic.environment = saved;
    if let Some(model) = usize::try_from(interface.0)
        .ok()
        .and_then(|index| session.module.interfaces.get_mut(index))
    {
        model.methods = methods;
    }
}
