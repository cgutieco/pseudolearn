#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn accepts_declared_crate() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let _source = fixture.source()?;
    assert!(pseudolearn_checks::layers::check(&fixture.root, &fixture.rules()?)?.is_empty());
    Ok(())
}

#[test]
fn rejects_undeclared_external_dependency() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let manifest = fixture.root.join("subject/Cargo.toml");
    let original = std::fs::read_to_string(&manifest)?;
    std::fs::write(
        manifest,
        format!("{original}\n[dependencies]\nserde = \"1\"\n"),
    )?;
    assert!(!pseudolearn_checks::layers::check(&fixture.root, &fixture.rules()?)?.is_empty());
    Ok(())
}

#[test]
fn rejects_missing_or_undeclared_crate() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    rules.layers.first_mut().ok_or("Missing layer")?.name = "missing".to_owned();
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert_eq!(findings.len(), 2);
    Ok(())
}
