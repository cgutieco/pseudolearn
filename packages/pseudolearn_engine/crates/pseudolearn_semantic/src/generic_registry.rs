use crate::generic_state::GenericTemplate;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn collect(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| {
            matches!(
                node.kind,
                NodeKind::RecordUnit
                    | NodeKind::Subprogram
                    | NodeKind::ClassUnit
                    | NodeKind::InterfaceUnit
                    | NodeKind::VariantUnit
            )
        })
        .map(|(index, _)| index)
        .filter(|node| is_generic(session, *node))
        .collect();
    for node in nodes {
        declare(session, node);
    }
    crate::generic_class_cycles::detect(session);
}

pub(crate) fn is_generic(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.child(node, NodeKind::TypeParameters).is_some()
}

fn declare(session: &mut AnalysisSession<'_>, node: usize) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let name = session.name(name_node);
    let (parameters, constraints, constraint_nodes) = parameters(session, node);
    let template = GenericTemplate {
        node,
        parameters,
        constraints,
        constraint_nodes,
    };
    if session.generics.declares(&name) {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return;
    }
    let scope = &mut session.generics;
    let table = match session.tree.node(node).map(|syntax| syntax.kind) {
        Some(NodeKind::RecordUnit) => &mut scope.records,
        Some(NodeKind::ClassUnit) => &mut scope.classes,
        Some(NodeKind::InterfaceUnit) => &mut scope.interfaces,
        Some(NodeKind::VariantUnit) => &mut scope.variants,
        _ => &mut scope.functions,
    };
    table.insert(name, template);
}

fn parameters(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> (Vec<String>, Vec<Option<String>>, Vec<usize>) {
    let mut names: Vec<String> = Vec::new();
    let mut constraints = Vec::new();
    let mut nodes = Vec::new();
    let Some(parameters) = session.child(node, NodeKind::TypeParameters) else {
        return (names, constraints, nodes);
    };
    for child in session.children(parameters) {
        let parts = session.children(child);
        let name = parts
            .first()
            .map(|node| session.name(*node))
            .unwrap_or_default();
        if names.contains(&name) {
            session.named_report(DiagnosticCode::DuplicateTypeDeclaration, child, &name);
            continue;
        }
        names.push(name);
        constraints.push(parts.get(1).map(|node| session.name(*node)));
        nodes.push(child);
    }
    (names, constraints, nodes)
}
