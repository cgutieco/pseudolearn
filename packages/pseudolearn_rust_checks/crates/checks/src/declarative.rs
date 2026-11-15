use pseudolearn_check_model::{Architecture, Violation, violation};
use std::collections::BTreeSet;
use std::path::Path;

pub fn check(root: &Path, rules: &Architecture) -> Result<Vec<Violation>, String> {
    let mut violations = Vec::new();
    let mut parents = BTreeSet::new();
    for layer in &rules.layers {
        let path = Path::new(&layer.path);
        if path.is_absolute()
            || path
                .components()
                .any(|part| part == std::path::Component::ParentDir)
        {
            return Err("Declarative crate path must stay inside member".to_owned());
        }
        parents.insert(path.parent().ok_or("Missing layer parent")?.to_path_buf());
        if !root.join(path).join("README.md").is_file() {
            violations.push(violation(
                &layer.path,
                1,
                "LAYER-DECLARED",
                "Missing crate README",
            ));
        }
        inspect_dependencies(layer, rules, &mut violations);
    }
    for parent in parents {
        inspect_children(root, &parent, rules, &mut violations)?;
    }
    reject_sources(root, root, &mut violations)?;
    Ok(violations)
}

fn inspect_children(
    root: &Path,
    parent: &Path,
    rules: &Architecture,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let directory = root.join(parent);
    if !directory.is_dir() {
        return Ok(());
    }
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir()
            && !rules
                .layers
                .iter()
                .any(|layer| root.join(&layer.path) == path)
        {
            let relative = path.strip_prefix(root).map_err(|error| error.to_string())?;
            violations.push(violation(
                &relative.to_string_lossy(),
                1,
                "LAYER-DECLARED",
                "Undeclared crate folder",
            ));
        }
    }
    Ok(())
}

fn reject_sources(
    root: &Path,
    directory: &Path,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() {
            reject_sources(root, &path, violations)?;
        } else if path.file_name().is_some_and(|name| name == "Cargo.toml")
            || path.extension().is_some_and(|extension| extension == "rs")
        {
            let relative = path.strip_prefix(root).map_err(|error| error.to_string())?;
            violations.push(violation(
                &relative.to_string_lossy(),
                1,
                "SPEC-FIRST",
                "Code in declarative member",
            ));
        }
    }
    Ok(())
}

fn inspect_dependencies(
    layer: &pseudolearn_check_model::Layer,
    rules: &Architecture,
    violations: &mut Vec<Violation>,
) {
    for dependency in &layer.may_import {
        if !rules
            .layers
            .iter()
            .any(|candidate| candidate.name == *dependency)
        {
            violations.push(violation(
                &layer.path,
                1,
                "LAYER-DIRECTION",
                "Unknown declared dependency",
            ));
        }
    }
}
