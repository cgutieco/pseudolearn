mod support;

#[test]
fn accepts_valid_source() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source(include_str!("../../../fixtures/valid.rs.txt"))?;
    assert!(pseudolearn_checks::names::check(&source, &support::rules()?.names).is_empty());
    Ok(())
}

#[test]
fn rejects_deliberate_violation() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source(include_str!("../../../fixtures/names.rs.txt"))?;
    assert!(!pseudolearn_checks::names::check(&source, &support::rules()?.names).is_empty());
    Ok(())
}

#[test]
fn accepts_empty_source() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source("")?;
    assert!(pseudolearn_checks::names::check(&source, &support::rules()?.names).is_empty());
    Ok(())
}

#[test]
fn rejects_short_lifetimes_generics_and_camel_case_abbreviations()
-> Result<(), Box<dyn std::error::Error>> {
    let rules = support::rules()?;
    for text in [
        "fn execute<'a>() {}",
        "struct Node<T> { value: T }",
        "fn execute() { let currentCtx = 1; }",
        "fn execute() { let id = 1; }",
    ] {
        let source = support::source(text)?;
        let findings = pseudolearn_checks::names::check(&source, &rules.names);
        assert_eq!(findings.is_empty(), text.contains("let id"));
    }
    Ok(())
}
