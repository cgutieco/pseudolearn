use crate::arena::{Arena, ScopeId};
use crate::scopes::Scope;
use crate::symbols::Symbol;
use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::SyntaxTree;

pub struct AnalysisSession<'syntax> {
    pub syntax_tree: &'syntax SyntaxTree,
    pub source_text: &'syntax SourceText,
    pub symbols: &'syntax mut Arena<Symbol>,
    pub scopes: &'syntax mut Arena<Scope>,
    pub current_scope: ScopeId,
    pub is_strict: bool,
    pub diagnostics: &'syntax mut Vec<Diagnostic>,
}
