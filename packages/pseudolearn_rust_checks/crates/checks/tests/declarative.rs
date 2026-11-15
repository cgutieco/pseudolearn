#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn declarative_member_checks_readmes_without_cargo() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let _source = fixture.source()?;
    let mut rules = fixture.rules()?;
    rules.declarative = true;
    std::fs::remove_file(fixture.root.join("Cargo.toml"))?;
    std::fs::remove_file(fixture.root.join("subject/Cargo.toml"))?;
    std::fs::remove_dir_all(fixture.root.join("subject/src"))?;
    assert!(pseudolearn_checks::layers::check(&fixture.root, &rules)?.is_empty());
    std::fs::remove_file(fixture.root.join("subject/README.md"))?;
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert!(
        findings
            .iter()
            .any(|finding| finding.rule == "LAYER-DECLARED")
    );
    std::fs::write(fixture.root.join("subject/README.md"), "# Subject")?;
    std::fs::create_dir(fixture.root.join("undeclared"))?;
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert!(
        findings
            .iter()
            .any(|finding| finding.rule == "LAYER-DECLARED")
    );
    Ok(())
}

#[test]
fn declarative_member_rejects_sources_and_unknown_dependency()
-> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    rules.declarative = true;
    rules
        .layers
        .first_mut()
        .ok_or("Missing layer")?
        .may_import
        .push("unknown".to_owned());
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert!(findings.iter().any(|finding| finding.rule == "SPEC-FIRST"));
    assert!(
        findings
            .iter()
            .any(|finding| finding.rule == "LAYER-DIRECTION")
    );
    Ok(())
}
