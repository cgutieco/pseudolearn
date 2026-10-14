use super::reject;
use super::root_references;

#[test]
fn rejects_links_paths_and_section_citations() {
    let documents = vec!["42-transient.md".to_owned()];
    for text in [
        "[research](../../docs/42-transient.md#section)",
        "/repository/docs/42-transient.md",
        "According to 42-transient.md section 3",
        "See docs/42 section 3",
    ] {
        assert!(reject(text, &documents).is_err());
    }
}

#[test]
fn allows_general_policy_and_package_documents() -> Result<(), String> {
    let documents = vec!["42-transient.md".to_owned()];
    for text in [
        "Root docs are transient",
        "docs/",
        "docs/language-spec.md",
        "README.md",
    ] {
        reject(text, &documents)?;
    }
    reject("", &[])
}

#[test]
fn resolves_root_readme_links_without_rejecting_package_documents() -> Result<(), String> {
    let root = std::path::Path::new("/repository");
    let readme = ["docs", "README.md"].join("/");
    assert!(root_references(root, "README.md", &readme).is_err());
    assert!(
        root_references(
            root,
            "packages/example/README.md",
            &format!("../../{readme}")
        )
        .is_err()
    );
    root_references(root, "packages/example/README.md", &readme)?;
    root_references(root, "README.md", "docs/")
}
