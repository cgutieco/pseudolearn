use crate::interface_model::{HirInterface, InterfaceId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::InterfaceUnit)
        .map(|(index, _)| index)
        .collect();
    for node in nodes {
        declare(session, node);
    }
    realizations(session);
}

pub(crate) fn find(session: &AnalysisSession<'_>, name: &str) -> Option<InterfaceId> {
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
        || session.generics.records.contains_key(&name)
        || session.classes.contains_key(&name)
        || session.declared.records.contains_key(&name)
        || session.declared.enums.contains_key(&name);
    if taken {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return;
    }
    session.module.interfaces.push(HirInterface {
        name,
        unit: session.unit,
        syntax: node,
        span: session.span(node),
        methods: Vec::new(),
    });
}

pub(crate) fn signatures(session: &mut AnalysisSession<'_>) {
    for index in 0..session.module.interfaces.len() {
        let Some(model) = session.module.interfaces.get(index) else {
            continue;
        };
        if model.unit != session.unit {
            continue;
        }
        let syntax = model.syntax;
        let mut methods = Vec::new();
        for node in session.children(syntax) {
            if session.kind(node) != NodeKind::InterfaceSignature {
                continue;
            }
            let method = crate::interface_signatures::resolve(session, node);
            if methods
                .iter()
                .any(|previous: &crate::interface_model::InterfaceMethod| {
                    previous.name == method.name
                })
            {
                session.named_report(DiagnosticCode::DuplicateMember, node, &method.name);
            } else {
                methods.push(method);
            }
        }
        if let Some(model) = session.module.interfaces.get_mut(index) {
            model.methods = methods;
        }
    }
}

fn realizations(session: &mut AnalysisSession<'_>) {
    for index in 0..session.module.classes.len() {
        let class = crate::identities::ClassId(u32::try_from(index).unwrap_or(u32::MAX));
        if session.module.units.class_unit(class) != session.unit {
            continue;
        }
        let Some(model) = session.module.classes.get(index) else {
            continue;
        };
        let Some(node) = session.child(model.syntax, NodeKind::Realization) else {
            continue;
        };
        for name_node in session.children(node) {
            let name = session.name(name_node);
            if let Some(interface) = find(session, &name) {
                let realizations = session.module.realizations.entry(class).or_default();
                realizations.extend(std::iter::once(interface));
                realizations.sort();
                realizations.dedup();
            } else {
                session.named_report(DiagnosticCode::UnknownInterface, name_node, &name);
            }
        }
    }
}
