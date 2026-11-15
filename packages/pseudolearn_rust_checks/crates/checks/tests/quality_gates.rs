#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn clippy_rejects_unwrap_fixture() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let _rules = fixture.rules()?;
    let _source = fixture.source()?;
    std::fs::write(
        fixture.root.join("subject/src/lib.rs"),
        include_str!("../../../fixtures/panic.rs.txt"),
    )?;
    let output = std::process::Command::new("cargo")
        .current_dir(&fixture.root)
        .args(["clippy", "--offline", "--", "-D", "clippy::unwrap_used"])
        .output()?;
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("unwrap"));
    Ok(())
}

#[test]
fn rustfmt_rejects_unformatted_fixture() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("subject/src/lib.rs"),
        "pub fn execute( ){    }\n",
    )?;
    let output = std::process::Command::new("cargo")
        .current_dir(&fixture.root)
        .args(["fmt", "--all", "--check"])
        .output()?;
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stdout).contains("Diff"));
    Ok(())
}

#[test]
fn cargo_deny_rejects_unlicensed_private_crates_without_explicit_private_policy()
-> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let configuration = fixture.root.join("deny.toml");
    std::fs::write(
        &configuration,
        "[licenses]\nversion = 2\nallow = [\"MIT\"]\n",
    )?;
    let output = std::process::Command::new("cargo")
        .current_dir(&fixture.root)
        .args([
            "deny",
            "--config",
            configuration.to_str().ok_or("Non-UTF8 fixture")?,
            "check",
            "licenses",
        ])
        .output()?;
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("unlicensed"));
    Ok(())
}
