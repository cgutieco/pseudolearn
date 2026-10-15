mod support;

#[test]
fn registers_forward_calls_with_isolated_parameter_scopes() -> Result<(), String> {
    let source = "subroutine outer(amount as integer) as integer\nreturn inner(amount);\nendSubroutine\nsubroutine inner(amount as integer) as integer\nreturn amount * 2;\nendSubroutine\nalgorithm Entry\nwrite outer(9);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let module = module.ok_or("Missing HIR")?;
    assert_eq!(module.functions.len(), 3);
    assert_eq!(module.locals.len(), 2);
    assert_ne!(
        module.locals.first().map(|local| local.scope),
        module.locals.get(1).map(|local| local.scope)
    );
    Ok(())
}

#[test]
fn a_duplicate_signature_does_not_change_call_arity() {
    let source = "subroutine repeated(left as integer, left as integer)\nwrite left;\nendSubroutine\nalgorithm Entry\nrepeated(2, 3);\nendAlgorithm\n";
    let (module, diagnostics) = support::analyze(source, true);
    assert!(module.is_none());
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "duplicateParameterName")
    );
    assert!(
        !diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "argumentCountMismatch")
    );
}
