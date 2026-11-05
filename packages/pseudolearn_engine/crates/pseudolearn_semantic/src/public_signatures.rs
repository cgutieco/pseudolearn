use crate::module_exports::ExportResolver;
use crate::module_symbols::{SymbolKind, UnitDeclarations};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};
use std::collections::BTreeSet;

pub(crate) fn check(session: &mut AnalysisSession<'_>, resolver: &ExportResolver<'_>) {
    for unit in 0..session.units.len() {
        let Some(declarations) = resolver.declarations(unit) else {
            continue;
        };
        let private = private_types(declarations);
        if private.is_empty() {
            continue;
        }
        session.switch_unit(unit);
        for type_node in private_appearances(session, &private) {
            let spelling = session.lexeme(type_node).to_owned();
            session.named_report(
                DiagnosticCode::PrivateTypeInPublicSignature,
                type_node,
                &spelling,
            );
        }
    }
}

fn private_appearances(session: &AnalysisSession<'_>, private: &BTreeSet<String>) -> Vec<usize> {
    public_units(session)
        .into_iter()
        .flat_map(|node| signature_types(session, node))
        .filter(|type_node| private.contains(&session.name(*type_node)))
        .collect()
}

fn private_types(declarations: &UnitDeclarations) -> BTreeSet<String> {
    declarations
        .symbols
        .iter()
        .filter(|(_, declaration)| {
            !declaration.public
                && matches!(
                    declaration.kind,
                    SymbolKind::Class
                        | SymbolKind::Record
                        | SymbolKind::Enum
                        | SymbolKind::Interface
                )
        })
        .map(|(name, _)| name.clone())
        .collect()
}

fn public_units(session: &AnalysisSession<'_>) -> Vec<usize> {
    let Some(root) = session.tree.nodes.len().checked_sub(1) else {
        return Vec::new();
    };
    session
        .children(root)
        .into_iter()
        .filter(|node| has_visibility(session, *node, KeywordKind::PublicVisibility))
        .collect()
}

fn has_visibility(session: &AnalysisSession<'_>, node: usize, keyword: KeywordKind) -> bool {
    session.token_kind(node) == Some(TokenKind::Keyword(keyword))
}

fn signature_types(session: &AnalysisSession<'_>, node: usize) -> Vec<usize> {
    let mut types = Vec::new();
    match session.kind(node) {
        NodeKind::Subprogram => callable_types(session, node, &mut types),
        NodeKind::RecordUnit => record_types(session, node, &mut types),
        NodeKind::ClassUnit => class_types(session, node, &mut types),
        NodeKind::InterfaceUnit => interface_types(session, node, &mut types),
        _ => (),
    }
    types
}

fn callable_types(session: &AnalysisSession<'_>, node: usize, types: &mut Vec<usize>) {
    for child in session.children(node) {
        match session.kind(child) {
            NodeKind::Parameters | NodeKind::Type => collect_types(session, child, types),
            _ => (),
        }
    }
}

fn record_types(session: &AnalysisSession<'_>, node: usize, types: &mut Vec<usize>) {
    for field in session.children(node) {
        if session.kind(field) == NodeKind::RecordField {
            collect_types(session, field, types);
        }
    }
}

fn class_types(session: &AnalysisSession<'_>, node: usize, types: &mut Vec<usize>) {
    for member in session.children(node) {
        if has_visibility(session, member, KeywordKind::PrivateVisibility) {
            continue;
        }
        match session.kind(member) {
            NodeKind::FieldDeclaration => collect_types(session, member, types),
            NodeKind::MethodMember | NodeKind::ConstructorMember => {
                callable_types(session, member, types);
            }
            _ => (),
        }
    }
}

fn interface_types(session: &AnalysisSession<'_>, node: usize, types: &mut Vec<usize>) {
    for signature in session.children(node) {
        if session.kind(signature) == NodeKind::InterfaceSignature {
            callable_types(session, signature, types);
        }
    }
}

fn collect_types(session: &AnalysisSession<'_>, node: usize, types: &mut Vec<usize>) {
    if session.kind(node) == NodeKind::Type {
        types.push(node);
    }
    for child in session.children(node) {
        collect_types(session, child, types);
    }
}
