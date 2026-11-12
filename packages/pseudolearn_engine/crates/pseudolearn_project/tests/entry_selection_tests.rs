use pseudolearn_project::{
    BuildFailure, FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectErrorCode,
    ProjectInput, select_entry,
};
use std::collections::BTreeMap;

fn package(name: &str, kind: PackageKind, entries: &[&str]) -> PackageInput {
    PackageInput {
        name: name.to_owned(),
        root: name.to_owned(),
        kind,
        entries: entries.iter().map(|entry| (*entry).to_owned()).collect(),
        dependencies: BTreeMap::new(),
    }
}

fn input(packages: Vec<PackageInput>, paths: &[&str]) -> ProjectInput {
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages,
        files: paths
            .iter()
            .enumerate()
            .map(|(index, path)| FileInput {
                path: (*path).to_owned(),
                source_id: u32::try_from(index).unwrap_or(0).saturating_add(1),
                text: String::new(),
            })
            .collect(),
    }
}

fn built(project: &ProjectInput) -> Result<ProjectCatalog, String> {
    ProjectCatalog::build(project).map_err(|failure| format!("{failure:?}"))
}

fn error_codes(project: &ProjectInput) -> Result<Vec<ProjectErrorCode>, String> {
    match ProjectCatalog::build(project) {
        Ok(_) => Err("project was accepted".to_owned()),
        Err(BuildFailure::Project(errors)) => {
            Ok(errors.into_iter().map(|error| error.code).collect())
        }
        Err(BuildFailure::Malformed(reason)) => Err(format!("{reason:?}")),
    }
}

fn application_catalog() -> Result<ProjectCatalog, String> {
    built(&input(
        vec![package("app", PackageKind::Application, &["app/main"])],
        &["app/main", "app/other"],
    ))
}

#[test]
fn declared_entry_is_selected() -> Result<(), String> {
    let catalog = application_catalog()?;
    let selected =
        select_entry(&catalog, Some("app/main"), true).map_err(|error| format!("{error:?}"))?;
    assert_eq!(selected, catalog.module_by_path("app/main"));
    Ok(())
}

#[test]
fn missing_selection_is_an_error_only_when_required() -> Result<(), String> {
    let catalog = application_catalog()?;
    assert_eq!(select_entry(&catalog, None, false), Ok(None));
    let error = select_entry(&catalog, None, true).err().ok_or("accepted")?;
    assert_eq!(error.code, ProjectErrorCode::EntryNotSelected);
    Ok(())
}

#[test]
fn undeclared_or_unknown_entry_is_not_found() -> Result<(), String> {
    let catalog = application_catalog()?;
    for requested in ["app/other", "app/nope", ""] {
        let error = select_entry(&catalog, Some(requested), true)
            .err()
            .ok_or("accepted")?;
        assert_eq!(error.code, ProjectErrorCode::EntryNotFound);
    }
    Ok(())
}

#[test]
fn duplicated_entry_is_reported_once() -> Result<(), String> {
    for entries in [["app/main", "app/main"], ["app/main", "APP/MAIN"]] {
        let codes = error_codes(&input(
            vec![package("app", PackageKind::Application, &entries)],
            &["app/main"],
        ))?;
        assert_eq!(codes, [ProjectErrorCode::EntryDuplicated]);
    }
    Ok(())
}

#[test]
fn declared_entry_without_a_module_is_not_found() -> Result<(), String> {
    let codes = error_codes(&input(
        vec![package("app", PackageKind::Application, &["app/main"])],
        &[],
    ))?;
    assert_eq!(codes, [ProjectErrorCode::EntryNotFound]);
    Ok(())
}

#[test]
fn library_with_entries_is_rejected() -> Result<(), String> {
    let codes = error_codes(&input(
        vec![package("geo", PackageKind::Library, &["geo/a"])],
        &["geo/a"],
    ))?;
    assert_eq!(codes, [ProjectErrorCode::NoEntryInLibrary]);
    Ok(())
}

#[test]
fn library_module_cannot_be_selected_as_entry() -> Result<(), String> {
    let catalog = built(&input(
        vec![package("geo", PackageKind::Library, &[])],
        &["geo/a"],
    ))?;
    let error = select_entry(&catalog, Some("geo/a"), true)
        .err()
        .ok_or("accepted")?;
    assert_eq!(error.code, ProjectErrorCode::EntryNotFound);
    Ok(())
}
