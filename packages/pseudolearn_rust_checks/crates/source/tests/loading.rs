#[test]
fn rejects_missing_configuration() {
    let root = std::path::Path::new("missing-architecture-root");
    assert!(pseudolearn_check_source::loading::read_architecture(root).is_err());
}

#[test]
fn rejects_escaping_paths() {
    assert!(!pseudolearn_check_source::loading::is_relative_path(
        "../escape"
    ));
    assert!(!pseudolearn_check_source::loading::is_relative_path(
        "/absolute"
    ));
    assert!(pseudolearn_check_source::loading::is_relative_path(
        "crates/source"
    ));
}

#[test]
fn loads_workspace_configuration_and_sources() -> Result<(), String> {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let rules = pseudolearn_check_source::loading::read_architecture(&root)?;
    let sources = pseudolearn_check_source::loading::load_sources(&root, &rules)?;
    assert!(!sources.is_empty());
    assert!(
        !sources
            .iter()
            .any(|source| source.relative.contains("fixtures"))
    );
    Ok(())
}
