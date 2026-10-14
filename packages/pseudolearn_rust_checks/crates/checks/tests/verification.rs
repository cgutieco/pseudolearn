#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn reports_invalid_syntax_and_configuration_as_errors() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let rules = fixture.rules()?;
    std::fs::write(
        fixture.root.join("architecture.yaml"),
        serde_json::to_string(&rules)?,
    )?;
    let _source = fixture.source()?;
    assert!(pseudolearn_checks::verify("comments", &fixture.root)?.is_empty());
    std::fs::write(fixture.root.join("subject/src/lib.rs"), "fn execute(")?;
    assert!(pseudolearn_checks::verify("comments", &fixture.root).is_err());
    std::fs::write(fixture.root.join("architecture.yaml"), "unexpected: true")?;
    assert!(pseudolearn_checks::verify("comments", &fixture.root).is_err());
    Ok(())
}

#[test]
fn rejects_unknown_command() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("architecture.yaml"),
        serde_json::to_string(&fixture.rules()?)?,
    )?;
    assert!(pseudolearn_checks::verify("unknown", &fixture.root).is_err());
    Ok(())
}
