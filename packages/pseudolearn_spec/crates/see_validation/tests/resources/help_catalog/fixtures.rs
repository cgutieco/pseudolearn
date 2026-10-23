use super::{catalog_resource_mut, check, reference_corpus};
use see_validation::resources::help_catalog::references;
use serde_json::Value;
use std::path::PathBuf;

const MINIMUM_FIXTURES: usize = 21;

fn fixture_paths() -> Result<Vec<PathBuf>, String> {
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../fixtures/help-catalog");
    let mut paths = Vec::new();
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path
            .extension()
            .is_some_and(|extension| extension == "json")
        {
            paths.push(path);
        }
    }
    paths.sort();
    Ok(paths)
}

fn apply(catalog: &mut Value, edit: &Value) -> Result<(), String> {
    let path = edit
        .get("path")
        .and_then(Value::as_str)
        .ok_or("Missing edit path")?;
    match edit.get("op").and_then(Value::as_str) {
        Some("set") => set(
            catalog,
            path,
            edit.get("value").cloned().ok_or("Missing edit value")?,
        ),
        Some("remove") => remove(catalog, path),
        Some("duplicate") => duplicate(catalog, path),
        _ => Err("Unknown edit operation".to_owned()),
    }
}

fn set(catalog: &mut Value, path: &str, replacement: Value) -> Result<(), String> {
    if let Some(destination) = catalog.pointer_mut(path) {
        *destination = replacement;
        return Ok(());
    }
    let (parent, key) = split_parent(path)?;
    catalog
        .pointer_mut(parent)
        .and_then(Value::as_object_mut)
        .ok_or_else(|| format!("Missing value at {path}"))?
        .insert(key.to_owned(), replacement);
    Ok(())
}

fn split_parent(path: &str) -> Result<(&str, &str), String> {
    path.rsplit_once('/')
        .ok_or_else(|| format!("Invalid edit path {path}"))
}

fn remove(catalog: &mut Value, path: &str) -> Result<(), String> {
    let (parent, key) = split_parent(path)?;
    match catalog.pointer_mut(parent) {
        Some(Value::Object(entries)) => entries.remove(key).map(|_| ()),
        Some(Value::Array(items)) => {
            let index = key.parse::<usize>().map_err(|error| error.to_string())?;
            (index < items.len())
                .then(|| items.remove(index))
                .map(|_| ())
        }
        _ => None,
    }
    .ok_or_else(|| format!("Missing value at {path}"))
}

fn duplicate(catalog: &mut Value, path: &str) -> Result<(), String> {
    let copy = catalog
        .pointer(path)
        .cloned()
        .ok_or_else(|| format!("Missing value at {path}"))?;
    let (parent, _) = split_parent(path)?;
    catalog
        .pointer_mut(parent)
        .and_then(Value::as_array_mut)
        .ok_or_else(|| format!("Parent of {path} is not a list"))?
        .push(copy);
    Ok(())
}

fn diagnostics(catalog: &Value) -> Result<Vec<String>, String> {
    let corpus = reference_corpus()?;
    let mut errors = references(catalog, &corpus);
    if let Err(error) = check(catalog) {
        errors.push(error);
    }
    Ok(errors)
}

#[test]
fn live_catalog_has_no_diagnostics() -> Result<(), String> {
    let mut corpus = reference_corpus()?;
    let catalog = catalog_resource_mut(&mut corpus)?.clone();
    assert_eq!(diagnostics(&catalog)?, Vec::<String>::new());
    Ok(())
}

#[test]
fn every_fixture_is_rejected_by_its_expected_diagnostic() -> Result<(), String> {
    let paths = fixture_paths()?;
    assert!(
        paths.len() >= MINIMUM_FIXTURES,
        "negative fixtures were removed"
    );
    let mut corpus = reference_corpus()?;
    let live = catalog_resource_mut(&mut corpus)?.clone();
    for path in paths {
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        let fixture: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
        let expected = fixture
            .get("expect")
            .and_then(Value::as_str)
            .ok_or("Missing expected diagnostic")?;
        let mut catalog = live.clone();
        for edit in fixture
            .get("edits")
            .and_then(Value::as_array)
            .ok_or("Missing edits")?
        {
            apply(&mut catalog, edit)?;
        }
        let errors = diagnostics(&catalog)?;
        assert!(
            errors.iter().any(|error| error.contains(expected)),
            "{} was not rejected with `{expected}`: {errors:?}",
            path.display()
        );
    }
    Ok(())
}
