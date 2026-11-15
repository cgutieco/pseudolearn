use pseudolearn_project::{
    BuildFailure, FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectInput,
    logical_path_key, normalize_logical_path, select_entry, source_order_keys,
};
use std::collections::BTreeMap;

fn project(files: Vec<FileInput>, roots: Vec<&str>) -> ProjectInput {
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages: roots
            .into_iter()
            .enumerate()
            .map(|(index, root)| PackageInput {
                name: format!("package{index}"),
                root: root.to_owned(),
                kind: PackageKind::Application,
                entries: Vec::new(),
                dependencies: BTreeMap::new(),
            })
            .collect(),
        files,
    }
}

fn file(path: &str, source_id: u32) -> FileInput {
    FileInput {
        path: path.to_owned(),
        source_id,
        text: String::new(),
    }
}

#[test]
fn normalizes_nfc_and_builds_case_insensitive_keys() {
    assert_eq!(
        normalize_logical_path("App/café"),
        Some("App/café".to_owned())
    );
    assert_eq!(logical_path_key("App/CAFÉ"), Some("app/café".to_owned()));
}

#[test]
fn rejects_nonportable_logical_path_components() {
    for path in [
        "",
        "/absolute",
        "C:/absolute",
        "a//b",
        "a/./b",
        "a/../b",
        "a\\b",
        "a/trailing.",
        "a/trailing ",
        "a/CON",
        "a/NUL.txt",
        "a/COM1",
        "a/PRN",
        "a/AUX",
        "a/CONIN$",
        "a/CONOUT$",
        "a/LPT9.log",
        "a/COM¹",
        "a/name:stream",
        "a/name?part",
        "a/control\u{0001}",
    ] {
        assert_eq!(normalize_logical_path(path), None, "{path:?}");
    }
}

#[test]
fn module_references_resolve_through_canonical_path_keys() -> Result<(), String> {
    let mut input = project(vec![file("app/main", 1)], vec!["APP"]);
    input
        .packages
        .first_mut()
        .ok_or("package is missing")?
        .entries
        .push("App/MAIN".to_owned());
    let catalog = ProjectCatalog::build(&input).map_err(|failure| format!("{failure:?}"))?;
    let module = select_entry(&catalog, Some("APP/Main"), true)
        .map_err(|error| format!("{error:?}"))?
        .ok_or("entry was not selected")?;
    assert_eq!(
        catalog.module(module).map(|found| found.path.as_str()),
        Some("app/main")
    );
    Ok(())
}

#[test]
fn source_order_keys_use_canonical_package_name_and_case_preserving_module_segments()
-> Result<(), String> {
    let mut input = project(
        vec![file("app/Zeta/main", 1), file("app/café/main", 2)],
        vec!["app"],
    );
    input.packages.first_mut().ok_or("package is missing")?.name = "Geo".to_owned();
    let catalog = ProjectCatalog::build(&input).map_err(|failure| format!("{failure:?}"))?;
    let keys = source_order_keys(&catalog);
    assert_eq!(
        keys.get(&pseudolearn_source::SourceId::new(1)),
        Some(&vec![
            "geo".to_owned(),
            "Zeta".to_owned(),
            "main".to_owned()
        ])
    );
    assert_eq!(
        keys.get(&pseudolearn_source::SourceId::new(2)),
        Some(&vec![
            "geo".to_owned(),
            "café".to_owned(),
            "main".to_owned()
        ])
    );
    Ok(())
}

#[test]
fn rejects_file_case_collisions_and_implicit_directory_collisions() {
    let case_collision = project(
        vec![file("app/Module", 1), file("app/module", 2)],
        vec!["app"],
    );
    assert!(matches!(
        ProjectCatalog::build(&case_collision),
        Err(BuildFailure::Malformed(_))
    ));

    let directory_collision = project(
        vec![file("app/Foo/first", 1), file("app/foo/second", 2)],
        vec!["app"],
    );
    assert!(matches!(
        ProjectCatalog::build(&directory_collision),
        Err(BuildFailure::Malformed(_))
    ));

    let unicode_collision = project(vec![file("app/café", 1), file("app/café", 2)], vec!["app"]);
    assert!(matches!(
        ProjectCatalog::build(&unicode_collision),
        Err(BuildFailure::Malformed(_))
    ));

    let unicode_directory_collision = project(
        vec![file("app/Café/first", 1), file("app/café/second", 2)],
        vec!["app"],
    );
    assert!(matches!(
        ProjectCatalog::build(&unicode_directory_collision),
        Err(BuildFailure::Malformed(_))
    ));
}

#[test]
fn rejects_file_and_directory_prefix_collisions() {
    let input = project(
        vec![file("app/name", 1), file("app/name/child", 2)],
        vec!["app"],
    );
    assert!(matches!(
        ProjectCatalog::build(&input),
        Err(BuildFailure::Malformed(_))
    ));
}

#[test]
fn rejects_package_roots_with_portable_collisions() {
    let input = project(Vec::new(), vec!["App", "app"]);
    assert!(matches!(
        ProjectCatalog::build(&input),
        Err(BuildFailure::Malformed(_))
    ));

    let unicode_roots = project(Vec::new(), vec!["café", "café"]);
    assert!(matches!(
        ProjectCatalog::build(&unicode_roots),
        Err(BuildFailure::Malformed(_))
    ));
}

#[test]
fn rejects_package_names_with_portable_collisions() -> Result<(), String> {
    let mut input = project(Vec::new(), vec!["app", "library"]);
    input
        .packages
        .first_mut()
        .ok_or("first package is absent")?
        .name = "Geo".to_owned();
    input
        .packages
        .get_mut(1)
        .ok_or("second package is absent")?
        .name = "geo".to_owned();
    assert!(matches!(
        ProjectCatalog::build(&input),
        Err(BuildFailure::Malformed(_))
    ));

    input
        .packages
        .get_mut(1)
        .ok_or("second package is absent")?
        .name = "géo".to_owned();
    input
        .packages
        .first_mut()
        .ok_or("first package is absent")?
        .name = "géO".to_owned();
    assert!(matches!(
        ProjectCatalog::build(&input),
        Err(BuildFailure::Malformed(_))
    ));
    Ok(())
}
