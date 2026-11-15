use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::inspection_expression::{InspectionEnvironment, check_inspection};
use pseudolearn_semantic::types::Type;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::expression_entry::parse_expression_source;

#[test]
fn resolves_an_explicit_lexical_capture_with_shared_typing() -> Result<(), String> {
    let source = SourceText::new("answer + 22".to_owned());
    let (tree, diagnostics) = parse_expression_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    let mut environment = InspectionEnvironment::default();
    let kind = environment.module.types.intern(Type::Integer);
    environment.bindings.push(("answer".to_owned(), kind));
    let inspection = check_inspection(&tree, &source, environment, Profile::Spanish)
        .map_err(|diagnostics| format!("{diagnostics:?}"))?;
    assert_eq!(inspection.parameters.len(), 1);
    assert_eq!(inspection.module.expressions.kinds.len(), 3);
    Ok(())
}

#[test]
fn rejects_calls_unknown_names_and_effect_forms() {
    for input in [
        "Azar(10)",
        "unknown + 1",
        "Aguardar result",
        "Lanzar Work()",
    ] {
        let source = SourceText::new(input.to_owned());
        let (tree, _) = parse_expression_source(&source, Profile::Spanish);
        assert!(
            check_inspection(
                &tree,
                &source,
                InspectionEnvironment::default(),
                Profile::Spanish
            )
            .is_err()
        );
    }
}

#[test]
fn preserves_string_literals_as_explicit_captures() -> Result<(), String> {
    let source = SourceText::new("\"é🧩\" + \"text\"".to_owned());
    let (tree, diagnostics) = parse_expression_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    let inspection = check_inspection(
        &tree,
        &source,
        InspectionEnvironment::default(),
        Profile::Spanish,
    )
    .map_err(|diagnostics| format!("{diagnostics:?}"))?;
    assert_eq!(inspection.text_captures, ["é🧩", "text"]);
    assert_eq!(inspection.parameters.len(), 2);
    Ok(())
}

#[test]
fn resolves_flattened_record_fields_without_runtime_dependencies() -> Result<(), String> {
    let source = SourceText::new("point.left + point.right".to_owned());
    let (tree, diagnostics) = parse_expression_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    let mut environment = InspectionEnvironment::default();
    let kind = environment.module.types.intern(Type::Integer);
    environment.bindings.push(("point.left".to_owned(), kind));
    environment.bindings.push(("point.right".to_owned(), kind));
    let inspection = check_inspection(&tree, &source, environment, Profile::Spanish)
        .map_err(|diagnostics| format!("{diagnostics:?}"))?;
    assert_eq!(inspection.parameters.len(), 2);
    assert_eq!(inspection.module.records.len(), 1);
    Ok(())
}
