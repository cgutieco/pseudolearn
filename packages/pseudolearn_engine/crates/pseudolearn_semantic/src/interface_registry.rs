use crate::generic_interfaces::InterfaceLookup;
use crate::identities::ClassId;
use crate::interface_model::{HirInterface, InterfaceId, InterfaceMethod};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn declare_all(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::InterfaceUnit)
        .map(|(index, _)| index)
        .filter(|node| !crate::generic_registry::is_generic(session, *node))
        .collect();
    for node in nodes {
        declare(session, node);
    }
}

pub(crate) fn find_in_unit(
    session: &AnalysisSession<'_>,
    unit: usize,
    name: &str,
) -> Option<InterfaceId> {
    session
        .module
        .interfaces
        .iter()
        .position(|interface| interface.unit == unit && interface.name == name)
        .and_then(|index| u32::try_from(index).ok())
        .map(InterfaceId)
}

pub(crate) fn find(session: &AnalysisSession<'_>, name: &str) -> Option<InterfaceId> {
    if let Some(imported) = session.declared.interfaces.get(name) {
        return Some(*imported);
    }
    session
        .module
        .interfaces
        .iter()
        .position(|interface| interface.unit == session.unit && interface.name == name)
        .and_then(|index| u32::try_from(index).ok())
        .map(InterfaceId)
}

fn declare(session: &mut AnalysisSession<'_>, node: usize) {
    let name_node = session.child(node, NodeKind::Identifier).unwrap_or(node);
    let name = session.name(name_node);
    let taken = find(session, &name).is_some()
        || session.generics.declares_type(&name)
        || session.classes.contains_key(&name)
        || session.declared.records.contains_key(&name)
        || session.declared.variants.contains_key(&name)
        || session.declared.enums.contains_key(&name);
    if taken {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return;
    }
    let identifier =
        InterfaceId(u32::try_from(session.module.interfaces.len()).unwrap_or(u32::MAX));
    session.module.interfaces.push(HirInterface {
        name,
        unit: session.unit,
        syntax: node,
        span: session.span(node),
        methods: Vec::new(),
    });
    session.note_declaration(
        node,
        crate::service_model::ServiceSymbolTarget::Interface(identifier),
    );
}

pub(crate) fn signatures(session: &mut AnalysisSession<'_>) {
    crate::interface_uses::constraints(session);
    for index in 0..session.module.interfaces.len() {
        let Some(model) = session.module.interfaces.get(index) else {
            continue;
        };
        let syntax = model.syntax;
        if model.unit != session.unit || crate::generic_registry::is_generic(session, syntax) {
            continue;
        }
        let methods = methods_of(session, syntax);
        if let Some(model) = session.module.interfaces.get_mut(index) {
            model.methods = methods;
        }
    }
    session.generic.signatures_ready = true;
    let pending: Vec<InterfaceId> = session
        .generic
        .interface_environments
        .keys()
        .copied()
        .collect();
    for interface in pending {
        let unit = usize::try_from(interface.0)
            .ok()
            .and_then(|index| session.module.interfaces.get(index))
            .map(|model| model.unit);
        if unit == Some(session.unit) {
            crate::generic_interfaces::fill(session, interface);
        }
    }
}

pub(crate) fn methods_of(session: &mut AnalysisSession<'_>, syntax: usize) -> Vec<InterfaceMethod> {
    let mut methods: Vec<InterfaceMethod> = Vec::new();
    for node in session.children(syntax) {
        if session.kind(node) != NodeKind::InterfaceSignature {
            continue;
        }
        let method = crate::interface_signatures::resolve(session, node);
        if methods.iter().any(|previous| previous.name == method.name) {
            session.named_report(DiagnosticCode::DuplicateMember, node, &method.name);
        } else {
            methods.push(method);
        }
    }
    methods
}

pub(crate) fn realizations(session: &mut AnalysisSession<'_>) {
    for index in 0..session.module.classes.len() {
        let class = ClassId(u32::try_from(index).unwrap_or(u32::MAX));
        if session.module.units.class_unit(class) != session.unit
            || session.generic.class_origins.contains_key(&class)
        {
            continue;
        }
        realize_class(session, class);
    }
}

pub(crate) fn realize_class(session: &mut AnalysisSession<'_>, class: ClassId) {
    let Some(syntax) = crate::hierarchy::class_model(session, class).map(|model| model.syntax)
    else {
        return;
    };
    let Some(node) = session.child(syntax, NodeKind::Realization) else {
        return;
    };
    let children = session.children(node);
    for (position, name_node) in children.iter().copied().enumerate() {
        if session.kind(name_node) != NodeKind::Identifier {
            continue;
        }
        let arguments = children
            .get(position.saturating_add(1))
            .copied()
            .filter(|next| session.kind(*next) == NodeKind::TypeArguments);
        let name = session.name(name_node);
        match crate::generic_interfaces::resolve(session, &name, arguments, name_node) {
            InterfaceLookup::Found(interface) => {
                session.note_use(
                    name_node,
                    crate::service_model::ServiceSymbolTarget::Interface(interface),
                );
                let realizations = session.module.realizations.entry(class).or_default();
                realizations.extend(std::iter::once(interface));
                realizations.sort();
                realizations.dedup();
            }
            InterfaceLookup::Reported => {}
            InterfaceLookup::Missing => {
                session.named_report(DiagnosticCode::UnknownInterface, name_node, &name);
            }
        }
    }
}
