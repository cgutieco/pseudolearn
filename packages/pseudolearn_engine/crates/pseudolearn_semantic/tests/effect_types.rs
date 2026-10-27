use pseudolearn_lexicon::Profile;
use serde_json::Value;

#[test]
fn capability_library_cases_have_typed_effects() -> Result<(), String> {
    for corpus in [
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.time.md"),
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.io.md"),
    ] {
        for block in corpus.split("```caso\n").skip(1) {
            let case: Value =
                serde_json::from_str(block.split("\n```").next().ok_or("missing body")?)
                    .map_err(|error| error.to_string())?;
            if case.get("anfitrion").is_none() {
                continue;
            }
            for (name, profile) in [("es", Profile::Spanish), ("en", Profile::English)] {
                let program = case
                    .get("programas")
                    .and_then(|programs| programs.get(name))
                    .and_then(Value::as_str)
                    .ok_or("missing program")?;
                let source = pseudolearn_source::SourceText::new(program.to_owned());
                let (tree, syntax) = pseudolearn_syntax::parse_source_with_terminator(
                    &source,
                    profile,
                    Some(pseudolearn_diagnostics::DiagnosticCode::MissingStatementTerminator),
                );
                assert!(syntax.is_empty(), "{name}: {syntax:?}");
                let (module, diagnostics) = pseudolearn_semantic::analyze_with_options(
                    &tree,
                    &source,
                    pseudolearn_semantic::SemanticOptions {
                        profile,
                        strict: true,
                    },
                );
                let module = module
                    .ok_or_else(|| format!("{:?} {name}: {diagnostics:?}", case.get("id")))?;
                assert!(!module.opaque_types.is_empty());
                assert!(module.expressions.kinds.iter().any(|expression| matches!(
                    expression,
                    pseudolearn_semantic::HirExpression::Effect { .. }
                )));
            }
        }
    }
    Ok(())
}
