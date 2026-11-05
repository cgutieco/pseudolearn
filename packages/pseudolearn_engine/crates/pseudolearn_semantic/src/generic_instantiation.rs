use crate::identities::{ClassId, TypeId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn class(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: Option<TypeId>,
) -> Option<ClassId> {
    let name_node = session.child(node, NodeKind::Identifier).unwrap_or(node);
    let name = session.name(name_node);
    let arguments = session.child(node, NodeKind::TypeArguments);
    if arguments.is_none()
        && let Some(class) = crate::generic_classes::from_context(session, &name, expected)
    {
        return Some(class);
    }
    if let Some(found) = crate::generic_classes::resolve(session, (&name, arguments), node) {
        return found;
    }
    let Some(class) = session.classes.get(&name).copied() else {
        session.named_report(DiagnosticCode::UndeclaredClass, name_node, &name);
        return None;
    };
    if let Some(arguments) = arguments {
        let found = session.children(arguments).len();
        crate::generic_names::count_mismatch(session, node, (&name, 0, found));
        return None;
    }
    Some(class)
}
