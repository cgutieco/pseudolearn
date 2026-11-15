use crate::tree::{NodeKind, SyntaxTree};
use pseudolearn_source::{SourceText, Span};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum UnitKind {
    Program,
    Procedure,
    Function,
    Class,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ParameterSignature {
    pub name: String,
    pub type_name: Option<String>,
    pub by_reference: bool,
    pub span: Span,
}

impl ParameterSignature {
    pub fn new(name: String, type_name: Option<String>, by_reference: bool, span: Span) -> Self {
        Self {
            name,
            type_name,
            by_reference,
            span,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct UnitDeclaration {
    pub kind: UnitKind,
    pub name: String,
    pub return_type_name: Option<String>,
    pub parameters: Vec<ParameterSignature>,
    pub span: Span,
    pub node_index: usize,
}

impl UnitDeclaration {
    pub fn new(kind: UnitKind, name: String, span: Span, node_index: usize) -> Self {
        Self {
            kind,
            name,
            return_type_name: None,
            parameters: Vec::new(),
            span,
            node_index,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ModuleSchema {
    pub units: Vec<UnitDeclaration>,
}

impl ModuleSchema {
    pub fn new(units: Vec<UnitDeclaration>) -> Self {
        Self { units }
    }

    pub fn extract(tree: &SyntaxTree, source: &SourceText) -> Self {
        let units = tree
            .nodes
            .len()
            .checked_sub(1)
            .map(|root| {
                tree.child_indices(root)
                    .iter()
                    .filter_map(|index| unit(tree, source, *index))
                    .collect()
            })
            .unwrap_or_default();
        Self { units }
    }
}

fn unit(tree: &SyntaxTree, source: &SourceText, index: usize) -> Option<UnitDeclaration> {
    let node = tree.node(index)?;
    let result = child(tree, index, NodeKind::Type).and_then(|index| text(tree, source, index));
    let kind = match node.kind {
        NodeKind::AlgorithmUnit => UnitKind::Program,
        NodeKind::Subprogram if result.is_some() => UnitKind::Function,
        NodeKind::Subprogram => UnitKind::Procedure,
        NodeKind::ClassUnit => UnitKind::Class,
        _ => return None,
    };
    let name = text(tree, source, child(tree, index, NodeKind::Identifier)?)?;
    let parameters = child(tree, index, NodeKind::Parameters)
        .map(|parameters| {
            tree.child_indices(parameters)
                .iter()
                .filter_map(|index| parameter(tree, source, *index))
                .collect()
        })
        .unwrap_or_default();
    Some(UnitDeclaration {
        kind,
        name,
        return_type_name: result,
        parameters,
        span: tree.span_for_node(index)?,
        node_index: index,
    })
}

fn parameter(tree: &SyntaxTree, source: &SourceText, index: usize) -> Option<ParameterSignature> {
    let name = text(tree, source, child(tree, index, NodeKind::Identifier)?)?;
    let type_name = child(tree, index, NodeKind::Type).and_then(|index| text(tree, source, index));
    let span = tree.span_for_node(index)?;
    let by_reference = tree.tokens.kinds.iter().enumerate().any(|(token, kind)| {
        *kind == crate::TokenKind::Keyword(pseudolearn_lexicon::KeywordKind::ByReference)
            && tree
                .tokens
                .span(token)
                .is_some_and(|token| token.start >= span.start && token.ending <= span.ending)
    });
    Some(ParameterSignature {
        name,
        type_name,
        by_reference,
        span,
    })
}

fn child(tree: &SyntaxTree, index: usize, kind: NodeKind) -> Option<usize> {
    tree.child_indices(index)
        .iter()
        .copied()
        .find(|index| tree.node(*index).is_some_and(|node| node.kind == kind))
}

fn text(tree: &SyntaxTree, source: &SourceText, index: usize) -> Option<String> {
    tree.tokens
        .text(
            source.as_str(),
            usize::try_from(tree.node(index)?.first_token).ok()?,
        )
        .map(str::to_owned)
}
