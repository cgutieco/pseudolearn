mod support;

#[test]
fn accepts_valid_source() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source(include_str!("../../../fixtures/valid.rs.txt"))?;
    assert!(pseudolearn_checks::comments::check(&source).is_empty());
    Ok(())
}

#[test]
fn rejects_deliberate_violation() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source(include_str!("../../../fixtures/comments.rs.txt"))?;
    assert!(!pseudolearn_checks::comments::check(&source).is_empty());
    Ok(())
}

#[test]
fn accepts_empty_source() -> Result<(), Box<dyn std::error::Error>> {
    let _rules = support::rules()?;
    let source = support::source("")?;
    assert!(pseudolearn_checks::comments::check(&source).is_empty());
    Ok(())
}

#[test]
fn rejects_documentation_hidden_in_conditional_attributes() -> Result<(), Box<dyn std::error::Error>>
{
    let _rules = support::rules()?;
    let source = support::source("#[cfg_attr(test, doc = \"hidden\")] fn execute() {}")?;
    assert!(!pseudolearn_checks::comments::check(&source).is_empty());
    Ok(())
}
