mod support;

#[test]
fn accepts_valid_source() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source(include_str!("../../../fixtures/valid.rs.txt"))?;
    assert!(pseudolearn_checks::limits::check(&source, &support::rules()?.limits).is_empty());
    Ok(())
}

#[test]
fn rejects_deliberate_violation() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source(include_str!("../../../fixtures/limits.rs.txt"))?;
    assert!(!pseudolearn_checks::limits::check(&source, &support::rules()?.limits).is_empty());
    Ok(())
}

#[test]
fn accepts_empty_source() -> Result<(), Box<dyn std::error::Error>> {
    let source = support::source("")?;
    assert!(pseudolearn_checks::limits::check(&source, &support::rules()?.limits).is_empty());
    Ok(())
}

#[test]
fn rejects_parameters_nesting_and_public_method_excess() -> Result<(), Box<dyn std::error::Error>> {
    let rules = support::rules()?;
    for text in [
        "fn execute(first: u8, second: u8, third: u8, fourth: u8, fifth: u8) {}",
        "fn execute() { loop { loop { loop { loop {} } } } }",
    ] {
        let source = support::source(text)?;
        assert!(!pseudolearn_checks::limits::check(&source, &rules.limits).is_empty());
    }
    let methods = (0..8)
        .map(|index| format!("pub fn method_{index}() {{}}"))
        .collect::<Vec<_>>()
        .join("\n");
    let source = support::source(&format!("struct Target; impl Target {{ {methods} }}"))?;
    assert!(!pseudolearn_checks::limits::check(&source, &rules.limits).is_empty());
    Ok(())
}
