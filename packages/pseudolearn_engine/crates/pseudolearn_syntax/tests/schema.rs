use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{ModuleSchema, UnitKind, parse_source};

#[test]
fn extracts_direct_units_and_parameter_contracts() -> Result<(), String> {
    let source = SourceText::new("subroutine Transform(value as integer byReference) as real\nreturn value;\nendSubroutine\nalgorithm Main\nendAlgorithm\n".to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let schema = ModuleSchema::extract(&tree, &source);
    assert_eq!(schema.units.len(), 2);
    let function = schema.units.first().ok_or("Missing function")?;
    assert_eq!(function.kind, UnitKind::Function);
    assert_eq!(function.name, "Transform");
    assert_eq!(function.return_type_name.as_deref(), Some("real"));
    let parameter = function.parameters.first().ok_or("Missing parameter")?;
    assert_eq!(parameter.name, "value");
    assert!(parameter.by_reference);
    assert_eq!(
        schema.units.get(1).map(|unit| unit.kind),
        Some(UnitKind::Program)
    );
    Ok(())
}

#[test]
fn extracts_empty_schema_from_missing_units() {
    let source = SourceText::new(String::new());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    assert!(ModuleSchema::extract(&tree, &source).units.is_empty());
}
