use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use serde_json::Value;

#[test]
fn nominal_interface_cases_follow_the_normative_rules() -> Result<(), String> {
    let corpus =
        include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.interface.md");
    for block in corpus.split("```caso\n").skip(1) {
        let case: Value = serde_json::from_str(block.split("\n```").next().ok_or("missing case")?)
            .map_err(|error| error.to_string())?;
        for (profile, name) in [(Profile::Spanish, "es"), (Profile::English, "en")] {
            let text = case
                .pointer(&format!("/programas/{name}"))
                .and_then(Value::as_str)
                .ok_or("missing program")?;
            let source = SourceText::new(text.to_owned());
            let (tree, mut diagnostics) = pseudolearn_syntax::parse_source(&source, profile);
            let (module, semantic) = analyze_with_options(
                &tree,
                &source,
                SemanticOptions {
                    profile,
                    strict: true,
                },
            );
            diagnostics.extend(semantic);
            let expected = case
                .pointer("/espera/diagnosticos/0/codigo")
                .and_then(Value::as_str);
            if let Some(code) = expected {
                assert!(
                    diagnostics
                        .iter()
                        .any(|diagnostic| diagnostic.code.as_str() == code),
                    "{}: {diagnostics:?}",
                    case.get("id").map(Value::to_string).unwrap_or_default()
                );
            } else {
                assert!(
                    module.is_some(),
                    "{}: {diagnostics:?}",
                    case.get("id").map(Value::to_string).unwrap_or_default()
                );
            }
        }
    }
    Ok(())
}
