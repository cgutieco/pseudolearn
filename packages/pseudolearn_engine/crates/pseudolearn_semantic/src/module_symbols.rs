use crate::session::AnalysisSession;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum SymbolKind {
    Function,
    Class,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct Origin {
    pub unit: usize,
    pub name: String,
    pub kind: SymbolKind,
}

#[derive(Clone, Copy, Debug)]
pub(crate) struct Declaration {
    pub kind: SymbolKind,
    pub public: bool,
}

#[derive(Clone, Debug)]
pub(crate) struct Directive {
    pub export: bool,
    pub path_node: usize,
    pub segments: Vec<String>,
    pub alias: Option<(usize, String)>,
}

#[derive(Clone, Debug, Default)]
pub(crate) struct UnitDeclarations {
    pub symbols: BTreeMap<String, Declaration>,
    pub directives: Vec<Directive>,
}

pub(crate) fn collect(session: &AnalysisSession<'_>) -> UnitDeclarations {
    let mut declarations = UnitDeclarations::default();
    for (index, node) in session.tree.nodes.iter().enumerate() {
        match node.kind {
            NodeKind::ClassUnit => declare(session, index, SymbolKind::Class, &mut declarations),
            NodeKind::Subprogram => {
                declare(session, index, SymbolKind::Function, &mut declarations);
            }
            NodeKind::ImportDeclaration | NodeKind::ExportDeclaration => {
                if let Some(directive) = directive(session, index) {
                    declarations.directives.push(directive);
                }
            }
            _ => (),
        }
    }
    declarations
}

fn declare(
    session: &AnalysisSession<'_>,
    node: usize,
    kind: SymbolKind,
    declarations: &mut UnitDeclarations,
) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let public =
        session.token_kind(node) == Some(TokenKind::Keyword(KeywordKind::PublicVisibility));
    declarations
        .symbols
        .entry(session.name(name_node))
        .or_insert(Declaration { kind, public });
}

fn directive(session: &AnalysisSession<'_>, node: usize) -> Option<Directive> {
    let path_node = session.child(node, NodeKind::ModulePath)?;
    let segments = session
        .children(path_node)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::Identifier)
        .map(|child| session.name(child))
        .collect();
    let alias = session
        .children(node)
        .into_iter()
        .filter(|child| session.kind(*child) == NodeKind::Identifier)
        .map(|child| (child, session.name(child)))
        .next();
    Some(Directive {
        export: session.kind(node) == NodeKind::ExportDeclaration,
        path_node,
        segments,
        alias,
    })
}
