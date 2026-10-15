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

    pub fn extract(syntax_tree: &SyntaxTree, source: &SourceText) -> Self {
        let mut units = Vec::new();
        for (index, node) in syntax_tree.nodes.iter().enumerate() {
            let unit_kind = match node.kind {
                NodeKind::ProgramUnit => UnitKind::Program,
                NodeKind::ProcedureUnit => UnitKind::Procedure,
                NodeKind::FunctionUnit => UnitKind::Function,
                NodeKind::ClassUnit => UnitKind::Class,
                _ => continue,
            };
            let first_token = usize::try_from(node.first_token).unwrap_or(0);
            let unit_name = syntax_tree
                .tokens
                .text(source.as_str(), first_token.saturating_add(1))
                .unwrap_or("anonimo")
                .to_owned();
            let span = syntax_tree
                .tokens
                .span(first_token)
                .unwrap_or(Span::new(0, 0));
            units.push(UnitDeclaration::new(unit_kind, unit_name, span, index));
        }
        Self { units }
    }
}
