pub mod arena;
pub mod checker;
pub mod expression_checker;
pub mod hir;
pub mod scopes;
pub mod session;
pub mod statement_checker;
pub mod symbols;
pub mod types;
pub mod unit_resolver;

pub use arena::{Arena, ScopeId, SymbolId, TypeId};
pub use checker::SemanticChecker;
pub use hir::SemanticModel;
pub use scopes::{Scope, ScopeKind};
pub use session::AnalysisSession;
pub use symbols::{Symbol, SymbolKind};
pub use types::Type;

use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::SyntaxTree;

pub fn analyze_semantics(
    syntax_tree: &SyntaxTree,
    source_text: &SourceText,
    is_strict: bool,
) -> (SemanticModel, Vec<Diagnostic>) {
    let checker = SemanticChecker::new(syntax_tree, source_text, is_strict);
    checker.check()
}
