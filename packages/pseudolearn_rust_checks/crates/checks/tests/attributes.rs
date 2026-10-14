mod support;

#[test]
fn accepts_valid_source() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source(include_str!("../../../fixtures/valid.rs.txt"))?;
    assert!(pseudolearn_checks::attributes::check(&source).is_empty());
    Ok(())
}

#[test]
fn rejects_deliberate_violation() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source(include_str!("../../../fixtures/attributes.rs.txt"))?;
    assert!(!pseudolearn_checks::attributes::check(&source).is_empty());
    Ok(())
}

#[test]
fn accepts_empty_source() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source("")?;
    assert!(pseudolearn_checks::attributes::check(&source).is_empty());
    Ok(())
}
