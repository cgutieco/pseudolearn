use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{HirModule, SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

pub fn analyze(text: &str) -> (Option<HirModule>, Vec<Diagnostic>) {
    let source = SourceText::new(text.to_owned());
    let (tree, mut diagnostics) = parse_source(&source, Profile::English);
    let (module, mut semantic) = analyze_with_options(
        &tree,
        &source,
        SemanticOptions {
            profile: Profile::English,
        },
    );
    diagnostics.append(&mut semantic);
    (module, diagnostics)
}
