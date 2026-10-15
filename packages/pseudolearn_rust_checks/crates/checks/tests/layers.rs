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

#[test]
fn accepts_pending_layer_without_code() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    let pending_path = fixture.root.join("pending_layer");
    std::fs::create_dir_all(&pending_path)?;
    std::fs::write(pending_path.join("README.md"), "# Pending\n")?;
    rules.layers.push(pseudolearn_check_model::Layer {
        name: "pending_layer".to_owned(),
        path: "pending_layer".to_owned(),
        may_import: Vec::new(),
        external_dependencies: Vec::new(),
        unsafe_allowed: false,
        tooling: false,
        pending: true,
        permitted_path_dependencies: Vec::new(),
    });
    assert!(pseudolearn_checks::layers::check(&fixture.root, &rules)?.is_empty());
    Ok(())
}

#[test]
fn rejects_pending_layer_with_code() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    let pending_path = fixture.root.join("pending_layer");
    std::fs::create_dir_all(&pending_path)?;
    std::fs::write(pending_path.join("README.md"), "# Pending\n")?;
    std::fs::write(pending_path.join("lib.rs"), "pub fn candidate() {}\n")?;
    rules.layers.push(pseudolearn_check_model::Layer {
        name: "pending_layer".to_owned(),
        path: "pending_layer".to_owned(),
        may_import: Vec::new(),
        external_dependencies: Vec::new(),
        unsafe_allowed: false,
        tooling: false,
        pending: true,
        permitted_path_dependencies: Vec::new(),
    });
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert!(!findings.is_empty());
    Ok(())
}

#[test]
fn rejects_pending_layer_missing_readme() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let mut rules = fixture.rules()?;
    let pending_path = fixture.root.join("pending_layer");
    std::fs::create_dir_all(&pending_path)?;
    rules.layers.push(pseudolearn_check_model::Layer {
        name: "pending_layer".to_owned(),
        path: "pending_layer".to_owned(),
        may_import: Vec::new(),
        external_dependencies: Vec::new(),
        unsafe_allowed: false,
        tooling: false,
        pending: true,
        permitted_path_dependencies: Vec::new(),
    });
    let findings = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
    assert!(!findings.is_empty());
    Ok(())
}

#[test]
fn accepts_permitted_external_path_dependency() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    let external_path = fixture
        .root
        .parent()
        .ok_or("No parent")?
        .join("external_dep");
    std::fs::create_dir_all(external_path.join("src"))?;
    std::fs::write(
        external_path.join("Cargo.toml"),
        "[package]\nname = \"external_dep\"\nversion = \"0.1.0\"\nedition = \"2024\"\npublish = false\n",
    )?;
    std::fs::write(external_path.join("src/lib.rs"), "pub fn candidate() {}\n")?;
    let manifest = fixture.root.join("subject/Cargo.toml");
    let original = std::fs::read_to_string(&manifest)?;
    std::fs::write(
        manifest,
        format!(
            "{original}\n[dependencies]\nexternal_dep = {{ path = \"{path}\" }}\n",
            path = external_path.display()
        ),
    )?;
    let mut rules = fixture.rules()?;
    let layer = rules.layers.first_mut().ok_or("Missing layer")?;
    layer.external_dependencies.push("external_dep".to_owned());
    layer
        .permitted_path_dependencies
        .push("external_dep".to_owned());
    assert!(pseudolearn_checks::layers::check(&fixture.root, &rules)?.is_empty());
    let _cleanup = std::fs::remove_dir_all(&external_path);
    Ok(())
}
