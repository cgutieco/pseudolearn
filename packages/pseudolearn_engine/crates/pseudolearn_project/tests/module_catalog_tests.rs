use pseudolearn_project::{
    BuildFailure, FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectErrorCode,
    ProjectInput, qualifier,
};
use std::collections::BTreeMap;

fn package(name: &str, root: &str, kind: PackageKind) -> PackageInput {
    PackageInput {
        name: name.to_owned(),
        root: root.to_owned(),
        kind,
        entries: Vec::new(),
        dependencies: BTreeMap::new(),
    }
}

fn file(path: &str, source_id: u32) -> FileInput {
    FileInput {
        path: path.to_owned(),
        source_id,
        text: String::new(),
    }
}

fn input(packages: Vec<PackageInput>, files: Vec<FileInput>) -> ProjectInput {
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages,
        files,
    }
}

fn built(project: &ProjectInput) -> Result<ProjectCatalog, String> {
    ProjectCatalog::build(project).map_err(|failure| format!("{failure:?}"))
}

fn rejected(project: &ProjectInput) -> Result<BuildFailure, String> {
    match ProjectCatalog::build(project) {
        Ok(_) => Err("project was accepted".to_owned()),
        Err(failure) => Ok(failure),
    }
}

fn codes(failure: BuildFailure) -> Vec<(ProjectErrorCode, Option<String>)> {
    match failure {
        BuildFailure::Project(errors) => errors
            .into_iter()
            .map(|error| (error.code, error.path))
            .collect(),
        BuildFailure::Malformed(_) => Vec::new(),
    }
}

fn is_malformed(failure: &BuildFailure) -> bool {
    matches!(failure, BuildFailure::Malformed(_))
}

#[test]
fn modules_are_sorted_by_path_and_named_from_their_root() -> Result<(), String> {
    let catalog = built(&input(
        vec![package("geo", "geo", PackageKind::Library)],
        vec![file("geo/zeta", 2), file("geo/alpha/inner", 1)],
    ))?;
    let paths: Vec<_> = catalog
        .modules()
        .iter()
        .map(|module| module.path.as_str())
        .collect();
    assert_eq!(paths, ["geo/alpha/inner", "geo/zeta"]);
    let first = catalog.modules().first().ok_or("no module")?;
    assert_eq!(qualifier(&catalog, first.id), "geo.alpha.inner");
    assert_eq!(first.segments, ["alpha", "inner"]);
    Ok(())
}

#[test]
fn every_module_carries_its_source_identity() -> Result<(), String> {
    let catalog = built(&input(
        vec![package("geo", "geo", PackageKind::Library)],
        vec![file("geo/a", 7)],
    ))?;
    let module = catalog.modules().first().ok_or("no module")?;
    let source = catalog.source(module.id).ok_or("no source")?;
    let identity = pseudolearn_source::source_identity(source).ok_or("no identity")?;
    assert_eq!(identity.source_id.value(), 7);
    assert_eq!(identity.project_id.value(), 1);
    Ok(())
}

#[test]
fn project_without_files_is_valid_but_without_packages_is_empty_workspace() -> Result<(), String> {
    let empty_package = built(&input(
        vec![package("geo", "geo", PackageKind::Library)],
        Vec::new(),
    ))?;
    assert!(empty_package.modules().is_empty());
    let failure = rejected(&input(Vec::new(), Vec::new()))?;
    assert_eq!(codes(failure), [(ProjectErrorCode::EmptyWorkspace, None)]);
    Ok(())
}

#[test]
fn file_under_two_roots_is_ambiguous_and_outside_roots_is_rejected() -> Result<(), String> {
    let packages = vec![
        package("app", "app", PackageKind::Library),
        package("sub", "app/sub", PackageKind::Library),
    ];
    let failure = rejected(&input(
        packages,
        vec![file("app/sub/x", 1), file("lib/y", 2)],
    ))?;
    assert_eq!(
        codes(failure),
        [
            (
                ProjectErrorCode::ModuleInMultipleRoots,
                Some("app/sub/x".to_owned())
            ),
            (
                ProjectErrorCode::ModuleOutsideRoots,
                Some("lib/y".to_owned())
            ),
        ]
    );
    Ok(())
}

#[test]
fn file_named_like_the_root_itself_is_outside_roots() -> Result<(), String> {
    let failure = rejected(&input(
        vec![package("geo", "geo", PackageKind::Library)],
        vec![file("geo", 1)],
    ))?;
    assert_eq!(
        codes(failure),
        [(ProjectErrorCode::ModuleOutsideRoots, Some("geo".to_owned()))]
    );
    Ok(())
}

#[test]
fn unknown_dependency_target_is_reported_with_the_package_name() -> Result<(), String> {
    let mut app = package("app", "app", PackageKind::Library);
    app.dependencies
        .insert("g".to_owned(), "missing".to_owned());
    let failure = rejected(&input(vec![app], Vec::new()))?;
    assert_eq!(
        codes(failure),
        [(ProjectErrorCode::DependencyNotFound, Some("app".to_owned()))]
    );
    Ok(())
}

#[test]
fn errors_do_not_depend_on_file_order() -> Result<(), String> {
    let build = |files: Vec<FileInput>| {
        rejected(&input(
            vec![package("geo", "geo", PackageKind::Library)],
            files,
        ))
    };
    let forward = codes(build(vec![file("a/x", 1), file("b/y", 2)])?);
    let backward = codes(build(vec![file("b/y", 2), file("a/x", 1)])?);
    assert_eq!(forward, backward);
    Ok(())
}

#[test]
fn malformed_inputs_are_usage_failures_not_project_errors() -> Result<(), String> {
    let geo = || vec![package("geo", "geo", PackageKind::Library)];
    let cases = [
        input(
            vec![package("geo", "geo/../x", PackageKind::Library)],
            Vec::new(),
        ),
        input(
            vec![
                package("geo", "geo", PackageKind::Library),
                package("geo", "other", PackageKind::Library),
            ],
            Vec::new(),
        ),
        input(geo(), vec![file("geo/a", 0)]),
        input(geo(), vec![file("geo/a", 1), file("geo/b", 1)]),
        input(geo(), vec![file("geo/a", 1), file("geo/a", 2)]),
        input(geo(), vec![file("geo//a", 1)]),
    ];
    for case in &cases {
        assert!(is_malformed(&rejected(case)?));
    }
    let mut zero_project = input(Vec::new(), Vec::new());
    zero_project.project_id = 0;
    assert!(is_malformed(&rejected(&zero_project)?));
    Ok(())
}

#[test]
fn empty_module_text_is_accepted() -> Result<(), String> {
    let catalog = built(&input(
        vec![package("geo", "geo", PackageKind::Library)],
        vec![file("geo/empty", 3)],
    ))?;
    assert_eq!(catalog.modules().len(), 1);
    Ok(())
}
