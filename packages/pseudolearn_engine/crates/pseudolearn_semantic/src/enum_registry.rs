use crate::hir::HirEnum;
use crate::identities::EnumId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_source::IdentifierNormalizer;
use pseudolearn_syntax::NodeKind;
use std::collections::BTreeSet;

pub(crate) fn name_taken(session: &AnalysisSession<'_>, name: &str) -> bool {
    session.classes.contains_key(name)
        || session.declared.enums.contains_key(name)
        || session.declared.records.contains_key(name)
}

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::EnumUnit)
        .map(|(index, _)| index)
        .collect();
    for node in nodes {
        register_enum(session, node);
    }
}

fn register_enum(session: &mut AnalysisSession<'_>, node: usize) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let name = session.name(name_node);
    if name_taken(session, &name) {
        session.named_report(DiagnosticCode::DuplicateTypeDeclaration, name_node, &name);
        return;
    }
    let members = members(session, node);
    let identifier = EnumId(u32::try_from(session.module.enums.len()).unwrap_or(u32::MAX));
    session.module.enums.push(HirEnum {
        name: session.link_name(&name),
        members,
        span: session.span(node),
    });
    session.declared.enums.insert(name, identifier);
}

fn members(session: &mut AnalysisSession<'_>, node: usize) -> Vec<String> {
    let Some(list) = session.child(node, NodeKind::EnumMembers) else {
        return Vec::new();
    };
    let mut seen = BTreeSet::new();
    let mut spellings = Vec::new();
    for member in session.children(list) {
        let spelling = session.lexeme(member).to_owned();
        if seen.insert(IdentifierNormalizer::normalize(&spelling)) {
            spellings.push(spelling);
        } else {
            session.named_report(DiagnosticCode::DuplicateEnumMember, member, &spelling);
        }
    }
    spellings
}
