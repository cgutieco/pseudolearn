#[path = "support/fixture.rs"]
mod fixture;

use pseudolearn_check_model::Isolation;

fn isolation_rule(forbidden: &str) -> Isolation {
    Isolation {
        package: "subject".to_owned(),
        targets: vec!["aarch64-apple-darwin".to_owned()],
        forbidden: vec![forbidden.to_owned()],
    }
}

fn add_native_backend(fixture: &fixture::Fixture) -> Result<(), Box<dyn std::error::Error>> {
    std::fs::create_dir_all(fixture.root.join("native_backend/src"))?;
    std::fs::write(
        fixture.root.join("native_backend/Cargo.toml"),
        "[package]\nname = \"native_backend\"\nversion = \"0.1.0\"\nedition = \"2024\"\npublish = false\n",
    )?;
    std::fs::write(fixture.root.join("native_backend/src/lib.rs"), "")?;
    std::fs::write(
        fixture.root.join("Cargo.toml"),
        "[workspace]\nmembers = [\"subject\", \"native_backend\"]\nresolver = \"3\"\n",
    )?;
    Ok(())
}

fn depend_on_native_backend(fixture: &fixture::Fixture) -> Result<(), Box<dyn std::error::Error>> {
    let manifest = fixture.root.join("subject/Cargo.toml");
    let original = std::fs::read_to_string(&manifest)?;
    std::fs::write(
        manifest,
        format!(
            "{original}\n[dependencies]\nnative_backend = {{ path = \"../native_backend\" }}\n"
        ),
    )?;
    Ok(())
}

#[test]
fn accepts_graph_without_forbidden_package() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    add_native_backend(&fixture)?;
    let mut rules = fixture.rules()?;
    rules.isolation = vec![isolation_rule("native_backend")];
    assert!(pseudolearn_checks::isolation::check(&fixture.root, &rules)?.is_empty());
    Ok(())
}

#[test]
fn rejects_forbidden_package_reached_transitively() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    add_native_backend(&fixture)?;
    depend_on_native_backend(&fixture)?;
    let mut rules = fixture.rules()?;
    rules.isolation = vec![isolation_rule("native_backend")];
    let findings = pseudolearn_checks::isolation::check(&fixture.root, &rules)?;
    assert_eq!(findings.len(), 1);
    assert_eq!(
        findings.first().ok_or("Missing finding")?.rule,
        "LAYER-DIRECTION"
    );
    Ok(())
}

#[test]
fn rejects_forbidden_package_matched_by_prefix() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    add_native_backend(&fixture)?;
    depend_on_native_backend(&fixture)?;
    let mut rules = fixture.rules()?;
    rules.isolation = vec![isolation_rule("native_*")];
    assert_eq!(
        pseudolearn_checks::isolation::check(&fixture.root, &rules)?.len(),
        1
    );
    Ok(())
}

#[test]
fn reports_unknown_package_as_error() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    let mut rule = isolation_rule("native_backend");
    rule.package = "missing".to_owned();
    rules.isolation = vec![rule];
    assert!(pseudolearn_checks::isolation::check(&fixture.root, &rules).is_err());
    Ok(())
}

#[test]
fn accepts_architecture_without_isolation_rules() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let _source = fixture.source()?;
    assert!(pseudolearn_checks::isolation::check(&fixture.root, &fixture.rules()?)?.is_empty());
    Ok(())
}
