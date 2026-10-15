use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{HirModule, SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;

pub fn analyze(text: &str, strict: bool) -> (Option<HirModule>, Vec<Diagnostic>) {
    let source = SourceText::new(text.to_owned());
    let policy = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let (tree, mut diagnostics) = parse_source_with_terminator(&source, Profile::English, policy);
    let (module, mut semantic) = analyze_with_options(
        &tree,
        &source,
        SemanticOptions {
            profile: Profile::English,
            strict,
        },
    );
    diagnostics.append(&mut semantic);
    (module, diagnostics)
}
