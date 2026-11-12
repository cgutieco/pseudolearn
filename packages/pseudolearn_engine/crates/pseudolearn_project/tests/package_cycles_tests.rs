use pseudolearn_project::{
    BuildFailure, FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectError,
    ProjectErrorCode, ProjectInput,
};
use std::collections::BTreeMap;

fn package(name: &str, dependencies: &[(&str, &str)]) -> PackageInput {
    PackageInput {
        name: name.to_owned(),
        root: name.to_owned(),
        kind: PackageKind::Library,
        entries: Vec::new(),
        dependencies: dependencies
            .iter()
            .map(|(alias, target)| ((*alias).to_owned(), (*target).to_owned()))
            .collect::<BTreeMap<_, _>>(),
    }
}

fn project(packages: Vec<PackageInput>) -> ProjectInput {
    let files = packages
        .iter()
        .enumerate()
        .map(|(index, package)| FileInput {
            path: format!("{}/module", package.name),
            source_id: u32::try_from(index).unwrap_or(0).saturating_add(1),
            text: String::new(),
        })
        .collect();
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages,
        files,
    }
}

fn cycle_errors(packages: Vec<PackageInput>) -> Result<Vec<ProjectError>, String> {
    match ProjectCatalog::build(&project(packages)) {
        Ok(_) => Ok(Vec::new()),
        Err(BuildFailure::Project(errors)) => Ok(errors
            .into_iter()
            .filter(|error| error.code == ProjectErrorCode::PackageCycle)
            .collect()),
        Err(BuildFailure::Malformed(reason)) => Err(format!("{reason:?}")),
    }
}

fn chain_of(error: &ProjectError) -> Vec<&str> {
    error.chain.iter().map(String::as_str).collect()
}

#[test]
fn two_packages_depending_on_each_other_are_rejected_with_the_chain() -> Result<(), String> {
    let errors = cycle_errors(vec![
        package("geo", &[("a", "app")]),
        package("app", &[("g", "geo")]),
    ])?;
    assert_eq!(errors.len(), 1);
    let error = errors.first().ok_or("no error")?;
    assert_eq!(error.path.as_deref(), Some("app"));
    assert_eq!(chain_of(error), ["app", "geo", "app"]);
    Ok(())
}

#[test]
fn a_package_depending_on_itself_is_a_cycle() -> Result<(), String> {
    let errors = cycle_errors(vec![package("geo", &[("yo", "geo")])])?;
    let error = errors.first().ok_or("no error")?;
    assert_eq!(chain_of(error), ["geo", "geo"]);
    Ok(())
}

#[test]
fn diamond_of_packages_is_accepted() -> Result<(), String> {
    let diamond = vec![
        package("top", &[("l", "left"), ("r", "right")]),
        package("left", &[("b", "base")]),
        package("right", &[("b", "base")]),
        package("base", &[]),
    ];
    assert!(cycle_errors(diamond)?.is_empty());
    Ok(())
}

#[test]
fn chain_choice_does_not_depend_on_declaration_order() -> Result<(), String> {
    let forward = vec![
        package("a", &[("x", "b"), ("y", "c")]),
        package("b", &[("x", "d")]),
        package("c", &[("x", "d")]),
        package("d", &[("x", "a")]),
    ];
    let mut reversed = forward.clone();
    reversed.reverse();
    let first = cycle_errors(forward)?;
    let second = cycle_errors(reversed)?;
    assert_eq!(first, second);
    let error = first.first().ok_or("no error")?;
    assert_eq!(chain_of(error), ["a", "b", "d", "a"]);
    Ok(())
}

#[test]
fn independent_cycles_yield_one_error_each_ordered_by_start() -> Result<(), String> {
    let errors = cycle_errors(vec![
        package("n", &[("x", "m")]),
        package("m", &[("x", "n")]),
        package("b", &[("x", "a")]),
        package("a", &[("x", "b")]),
    ])?;
    let starts: Vec<_> = errors.iter().map(|error| error.path.as_deref()).collect();
    assert_eq!(starts, [Some("a"), Some("m")]);
    Ok(())
}

#[test]
fn dependency_on_a_missing_package_is_not_a_cycle() -> Result<(), String> {
    assert!(cycle_errors(vec![package("geo", &[("x", "absent")])])?.is_empty());
    Ok(())
}

#[test]
fn cycle_errors_carry_a_stable_code() {
    assert_eq!(ProjectErrorCode::PackageCycle.as_str(), "packageCycle");
}
