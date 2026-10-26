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
        .filter(|(_, node)| matches!(node.kind, NodeKind::RecordUnit | NodeKind::Subprogram))
        .map(|(index, _)| index)
        .filter(|node| is_generic(session, *node))
        .collect();
    for node in nodes {
        declare(session, node);
    }
}

pub(crate) fn is_generic(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.child(node, NodeKind::TypeParameters).is_some()
}

fn declare(session: &mut AnalysisSession<'_>, node: usize) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let name = session.name(name_node);
    let (parameters, constraints) = parameters(session, node);
    let template = GenericTemplate {
        node,
        parameters,
        constraints,
    };
    let record = session.kind(node) == NodeKind::RecordUnit;
    let taken = session.generics.records.contains_key(&name)
        || session.generics.functions.contains_key(&name);
    if taken {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return;
    }
    if record {
        session.generics.records.insert(name, template);
    } else {
        session.generics.functions.insert(name, template);
    }
}

fn parameters(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> (Vec<String>, Vec<Option<String>>) {
    let mut names: Vec<String> = Vec::new();
    let mut constraints = Vec::new();
    let Some(parameters) = session.child(node, NodeKind::TypeParameters) else {
        return (names, constraints);
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
    }
    (names, constraints)
}
