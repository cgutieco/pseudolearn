use crate::generic_functions::SavedState;
use crate::generic_state::{GenericTemplate, INSTANCE_LIMIT};
use crate::hir::HirClass;
use crate::identities::{ClassId, TypeId};
use crate::session::AnalysisSession;

pub(crate) fn instantiate(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    arguments: Vec<TypeId>,
    origin: usize,
) -> Option<ClassId> {
    if !crate::interface_constraints::check(session, template, &arguments, origin) {
        return None;
    }
    let key = (template.unit, template.node, arguments.clone());
    if let Some(existing) = session.generic.classes.get(&key) {
        return Some(*existing);
    }
    let name = crate::generic_home::template_name(session, template)?;
    if session.generic.instance_count() >= INSTANCE_LIMIT {
        crate::generic_records::report_limit(session, origin, &name);
        return None;
    }
    session.generic.instantiated = true;
    let saved = SavedState::take(session);
    let class = crate::generic_home::at_home(session, template, |session| {
        let class = declare(session, template, (&name, &arguments));
        session.generic.classes.insert(key.clone(), class);
        session.generic.class_origins.insert(class, key);
        let environment: Vec<(String, TypeId)> =
            template.parameters.iter().cloned().zip(arguments).collect();
        session
            .generic
            .class_environments
            .insert(class, environment.clone());
        session.generic.environment = environment;
        complete(session, class);
        class
    });
    saved.restore(session);
    Some(class)
}

fn complete(session: &mut AnalysisSession<'_>, class: ClassId) {
    crate::class_registry::members(session, class);
    crate::interface_registry::realize_class(session, class);
    crate::hierarchy::check_class(session, class);
    if session.generic.checking_bodies {
        crate::interface_realizations::check_class(session, class);
        bodies(session, class);
    }
}

fn declare(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (name, arguments): (&str, &[TypeId]),
) -> ClassId {
    let identifier = ClassId(u32::try_from(session.module.classes.len()).unwrap_or(u32::MAX));
    let label = crate::generic_labels::instance_name(session, &session.link_name(name), arguments);
    session.tag_class();
    session.module.classes.push(HirClass {
        name: label,
        superclass: None,
        fields: Vec::new(),
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span: session.span(template.node),
        syntax: template.node,
    });
    identifier
}

fn bodies(session: &mut AnalysisSession<'_>, class: ClassId) {
    let Some(model) = crate::hierarchy::class_model(session, class) else {
        return;
    };
    let functions: Vec<_> = model
        .constructor
        .into_iter()
        .chain(model.methods.iter().copied())
        .collect();
    for function in functions {
        if let Ok(index) = usize::try_from(function.0) {
            crate::flow::function(session, index);
        }
    }
}

pub(crate) fn environment(
    session: &AnalysisSession<'_>,
    class: ClassId,
) -> Option<Vec<(String, TypeId)>> {
    session.generic.class_environments.get(&class).cloned()
}

pub(crate) fn resolve(
    session: &mut AnalysisSession<'_>,
    (name, arguments): (&str, Option<usize>),
    origin: usize,
) -> Option<Option<ClassId>> {
    let template = session.generics.classes.get(name).cloned()?;
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

pub(crate) fn from_context(
    session: &AnalysisSession<'_>,
    name: &str,
    expected: Option<TypeId>,
) -> Option<ClassId> {
    let template = session.generics.classes.get(name)?;
    let crate::types::Type::Object(class) = session.module.types.get(expected?) else {
        return None;
    };
    let (unit, node, _) = session.generic.class_origins.get(&class)?;
    (*unit == template.unit && *node == template.node).then_some(class)
}

pub(crate) fn truncate(session: &mut AnalysisSession<'_>, count: usize) {
    let below = |class: &ClassId| usize::try_from(class.0).is_ok_and(|slot| slot < count);
    session.module.classes.truncate(count);
    session.module.units.classes.truncate(count);
    session.generic.classes.retain(|_, class| below(class));
    session
        .generic
        .class_origins
        .retain(|class, _| below(class));
    session
        .generic
        .class_environments
        .retain(|class, _| below(class));
    session.module.realizations.retain(|class, _| below(class));
    session
        .module
        .class_record_fields
        .retain(|entry| below(&entry.field.owner));
}
