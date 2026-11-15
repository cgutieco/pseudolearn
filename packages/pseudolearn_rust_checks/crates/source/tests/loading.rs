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

#[test]
fn skips_only_declared_generated_sources() -> Result<(), Box<dyn std::error::Error>> {
    static NEXT: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
    let sequence = NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let root = std::env::temp_dir().join(format!("generated-source-check-{sequence}"));
    std::fs::create_dir_all(root.join("src"))?;
    std::fs::write(
        root.join("architecture.yaml"),
        "package: generated_sample\ngenerated_sources:\n  - src/generated.rs\nlayers:\n  - name: generated_sample\n    path: .\n    may_import: []\n    external_dependencies: []\n    unsafe_allowed: false\nlimits:\n  file_lines: 300\n  function_lines: 40\n  positional_parameters: 4\n  nesting_depth: 3\n  public_methods_per_class: 7\n  unsafe_function_lines: 10\nnames:\n  minimum_length: 3\n  permitted_short: [id, io, ir, vm, gc, os]\n  forbidden_components: []\n  forbidden_files: []\n",
    )?;
    std::fs::write(root.join("src/lib.rs"), "pub fn execute() {}\n")?;
    std::fs::write(
        root.join("src/generated.rs"),
        "// generated\npub fn bridge() {}\n",
    )?;
    let rules = pseudolearn_check_source::loading::read_architecture(&root)?;
    let sources = pseudolearn_check_source::loading::load_sources(&root, &rules)?;
    assert_eq!(sources.len(), 1);
    assert_eq!(
        sources.first().map(|source| source.relative.as_str()),
        Some("src/lib.rs")
    );
    std::fs::remove_dir_all(&root)?;
    Ok(())
}

#[test]
fn rejects_generated_source_paths_outside_the_member() -> Result<(), Box<dyn std::error::Error>> {
    static NEXT: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
    let sequence = NEXT.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let root = std::env::temp_dir().join(format!("invalid-generated-source-check-{sequence}"));
    std::fs::create_dir_all(&root)?;
    std::fs::write(
        root.join("architecture.yaml"),
        "package: generated_sample\ngenerated_sources:\n  - ../generated.rs\nlayers:\n  - name: generated_sample\n    path: .\n    may_import: []\n    external_dependencies: []\n    unsafe_allowed: false\nlimits:\n  file_lines: 300\n  function_lines: 40\n  positional_parameters: 4\n  nesting_depth: 3\n  public_methods_per_class: 7\n  unsafe_function_lines: 10\nnames:\n  minimum_length: 3\n  permitted_short: [id, io, ir, vm, gc, os]\n  forbidden_components: []\n  forbidden_files: []\n",
    )?;
    assert!(pseudolearn_check_source::loading::read_architecture(&root).is_err());
    std::fs::remove_dir_all(&root)?;
    Ok(())
}
