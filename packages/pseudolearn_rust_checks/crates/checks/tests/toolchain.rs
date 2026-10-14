#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn accepts_identical_exact_versions() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let _rules = fixture.rules()?;
    let _source = fixture.source()?;
    std::fs::write(
        fixture.root.join("rust-toolchain.toml"),
        "channel = \"1.99.0\"",
    )?;
    std::fs::write(
        fixture.root.join("subject/rust-toolchain.toml"),
        "channel = \"1.99.0\"",
    )?;
    assert!(pseudolearn_checks::toolchain::verify_versions(&fixture.root).is_ok());
    Ok(())
}

#[test]
fn rejects_divergent_versions() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("rust-toolchain.toml"),
        "channel = \"1.99.0\"",
    )?;
    std::fs::write(
        fixture.root.join("subject/rust-toolchain.toml"),
        "channel = \"1.98.0\"",
    )?;
    assert!(pseudolearn_checks::toolchain::verify_versions(&fixture.root).is_err());
    Ok(())
}

#[test]
fn rejects_floating_or_absent_versions() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    assert!(pseudolearn_checks::toolchain::verify_versions(&fixture.root).is_err());
    std::fs::write(
        fixture.root.join("rust-toolchain.toml"),
        "channel = \"stable\"",
    )?;
    assert!(pseudolearn_checks::toolchain::verify_versions(&fixture.root).is_err());
    Ok(())
}
