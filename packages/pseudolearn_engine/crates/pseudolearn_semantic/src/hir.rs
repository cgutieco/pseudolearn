use crate::arena::{Arena, ScopeId};
use crate::scopes::Scope;
use crate::symbols::Symbol;
use pseudolearn_diagnostics::Diagnostic;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SemanticModel {
    pub symbols: Arena<Symbol>,
    pub scopes: Arena<Scope>,
    pub root_scope: ScopeId,
    pub diagnostics: Vec<Diagnostic>,
    pub is_strict: bool,
}

impl SemanticModel {
    pub fn new(
        symbols: Arena<Symbol>,
        scopes: Arena<Scope>,
        root_scope: ScopeId,
        is_strict: bool,
    ) -> Self {
        Self {
            symbols,
            scopes,
            root_scope,
            diagnostics: Vec::new(),
            is_strict,
        }
    }
}
