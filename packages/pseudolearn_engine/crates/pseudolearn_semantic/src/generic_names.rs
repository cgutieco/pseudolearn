use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::{DiagnosticArgument, DiagnosticCode};
use pseudolearn_syntax::NodeKind;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    let arguments = session.child(node, NodeKind::TypeArguments);
    let Some(arguments) = arguments else {
        return plain(session, node, name);
    };
    let nodes = session.children(arguments);
    let Some(template) = session.generics.records.get(name).cloned() else {
        count_mismatch(session, node, (name, 0, nodes.len()));
        return Some(Type::Error);
    };
    if nodes.len() != template.parameters.len() {
        count_mismatch(
            session,
            node,
            (name, template.parameters.len(), nodes.len()),
        );
        return Some(Type::Error);
    }
    let kinds = nodes
        .into_iter()
        .map(|child| crate::type_resolution::resolve(session, child))
        .collect();
    Some(
        crate::generic_records::instantiate(session, &template, kinds, node)
            .map_or(Type::Error, Type::Record),
    )
}

fn plain(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    if let Some(kind) = session.generic.lookup(name) {
        return Some(session.module.types.get(kind));
    }
    let template = session.generics.records.get(name)?;
    let expected = template.parameters.len();
    count_mismatch(session, node, (name, expected, 0));
    Some(Type::Error)
}

pub(crate) fn count_mismatch(
    session: &mut AnalysisSession<'_>,
    node: usize,
    counts: (&str, usize, usize),
) {
    let (name, expected, found) = counts;
    session.named_report(DiagnosticCode::TypeArgumentCountMismatch, node, name);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.arguments.insert(
            "expected".to_owned(),
            DiagnosticArgument::Number(u64::try_from(expected).unwrap_or(u64::MAX).into()),
        );
        diagnostic.arguments.insert(
            "found".to_owned(),
            DiagnosticArgument::Number(u64::try_from(found).unwrap_or(u64::MAX).into()),
        );
    }
}
