use crate::arena::ScopeId;
use crate::types::Type;
use pseudolearn_source::Span;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SymbolKind {
    Variable,
    Parameter {
        by_reference: bool,
    },
    Function {
        return_type: Type,
        parameter_types: Vec<Type>,
    },
    Procedure {
        parameter_types: Vec<Type>,
    },
    Class {
        superclass_name: Option<String>,
    },
    Field,
    Method,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Symbol {
    pub name: String,
    pub kind: SymbolKind,
    pub inferred_type: Type,
    pub span: Span,
    pub scope_id: ScopeId,
    pub is_assigned: bool,
    pub is_read: bool,
}

impl Symbol {
    pub fn new(name: String, kind: SymbolKind, span: Span, scope_id: ScopeId) -> Self {
        Self {
            name,
            kind,
            inferred_type: Type::Unknown,
            span,
            scope_id,
            is_assigned: false,
            is_read: false,
        }
    }

    pub fn with_type(mut self, inferred_type: Type) -> Self {
        self.inferred_type = inferred_type;
        self
    }

    pub fn mark_assigned(&mut self) {
        self.is_assigned = true;
    }

    pub fn mark_read(&mut self) {
        self.is_read = true;
    }
}
