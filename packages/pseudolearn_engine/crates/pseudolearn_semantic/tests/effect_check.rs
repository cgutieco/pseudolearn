use pseudolearn_diagnostics::DiagnosticCode;
use serde_json::Value;

#[test]
fn purity_cases_reject_hidden_effects() -> Result<(), String> {
    let corpus =
        include_str!("../../../../pseudolearn_spec/specifications/lang/lang.capability.purity.md");
    for identity in ["C7", "C8", "C9"] {
        let case = find_case(corpus, identity)?;
        let program = case
            .get("programa")
            .and_then(Value::as_str)
            .ok_or("missing program")?;
        let (module, diagnostics) = analyze(program);
        assert!(module.is_none(), "{identity}: hidden effect accepted");
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code
                    == DiagnosticCode::PureFunctionTransitiveSideEffect),
            "{identity}: {diagnostics:?}"
        );
    }
    Ok(())
}

fn find_case(corpus: &str, identity: &str) -> Result<Value, String> {
    for block in corpus.split("```caso\n").skip(1) {
        let source = block.split("\n```").next().ok_or("missing case body")?;
        let case: Value = serde_json::from_str(source).map_err(|error| error.to_string())?;
        if case.get("id").and_then(Value::as_str) == Some(identity) {
            return Ok(case);
        }
    }
    Err(format!("missing case {identity}"))
}

fn analyze(
    program: &str,
) -> (
    Option<pseudolearn_semantic::HirModule>,
    Vec<pseudolearn_diagnostics::Diagnostic>,
) {
    let source = pseudolearn_source::SourceText::new(program.to_owned());
    let profile = pseudolearn_lexicon::Profile::Spanish;
    let (tree, mut diagnostics) = pseudolearn_syntax::parse_source_with_terminator(
        &source,
        profile,
        Some(DiagnosticCode::MissingStatementTerminator),
    );
    let (module, mut semantic) = pseudolearn_semantic::analyze_with_options(
        &tree,
        &source,
        pseudolearn_semantic::SemanticOptions {
            profile,
            strict: true,
        },
    );
    diagnostics.append(&mut semantic);
    (module, diagnostics)
}
