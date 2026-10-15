use crate::hir::HirModule;
use crate::session::{AnalysisSession, SemanticOptions};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticSeverity};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::SyntaxTree;

pub fn analyze(
    tree: &SyntaxTree,
    source: &SourceText,
    options: SemanticOptions,
) -> (Option<HirModule>, Vec<Diagnostic>) {
    if tree.has_errors {
        return (None, Vec::new());
    }
    let mut session = AnalysisSession::new(tree, source, options);
    crate::unit_resolver::register(&mut session);
    crate::hierarchy::check(&mut session);
    crate::flow::bodies(&mut session);
    crate::usage::unused(&mut session);
    let valid = !session
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error);
    (valid.then_some(session.module), session.diagnostics)
}
