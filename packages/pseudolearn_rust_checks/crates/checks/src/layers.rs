use pseudolearn_check_model::{Architecture, Layer, Violation, violation};
use std::path::Path;

pub fn check(root: &Path, rules: &Architecture) -> Result<Vec<Violation>, String> {
    if rules.declarative {
        return crate::declarative::check(root, rules);
    }
    let output = std::process::Command::new("cargo")
        .current_dir(root)
        .args(["metadata", "--no-deps", "--format-version", "1"])
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    let metadata: serde_json::Value =
        serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())?;
    let packages = metadata
        .get("packages")
        .and_then(serde_json::Value::as_array)
        .ok_or("Cargo metadata has no packages")?;
    let mut violations = Vec::new();
    for package in packages {
        inspect_package(package, rules, root, &mut violations)?;
    }
    inspect_cargo_layers(rules, root, packages, &mut violations)?;
    Ok(violations)
}

fn inspect_cargo_layers(
    rules: &Architecture,
    root: &Path,
    packages: &[serde_json::Value],
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    for layer in &rules.layers {
        if layer.pending {
            inspect_pending_layer(layer, root, packages, violations)?;
            continue;
        }
        if !packages.iter().any(|package| {
            package.get("name").and_then(|name| name.as_str()) == Some(layer.name.as_str())
        }) {
            violations.push(violation(
                "architecture.yaml",
                1,
                "LAYER-DECLARED",
                &format!("Missing declared crate: {}", layer.name),
            ));
        }
    }
    Ok(())
}

fn inspect_package(
    package: &serde_json::Value,
    rules: &Architecture,
    root: &Path,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let name = package
        .get("name")
        .and_then(|name| name.as_str())
        .ok_or("Missing crate name")?;
    let Some(layer) = rules.layers.iter().find(|layer| layer.name == name) else {
        violations.push(violation(
            "Cargo.toml",
            1,
            "LAYER-DECLARED",
            "Undeclared crate",
        ));
        return Ok(());
    };
    if layer.pending {
        violations.push(violation(
            &layer.path,
            1,
            "SPEC-FIRST",
            "Pending crate declared in Cargo",
        ));
        return Ok(());
    }
    inspect_manifest(package, layer, root, violations)?;
    inspect_dependencies(package, layer, rules, violations)
}

fn inspect_manifest(
    package: &serde_json::Value,
    layer: &Layer,
    root: &Path,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let manifest = package
        .get("manifest_path")
        .and_then(|path| path.as_str())
        .ok_or("Missing manifest path")?;
    let expected = root
        .join(&layer.path)
        .join("Cargo.toml")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    if Path::new(manifest) != expected {
        violations.push(violation(
            &layer.path,
            1,
            "LAYER-DECLARED",
            "Crate path differs from rule",
        ));
    }
    Ok(())
}

fn inspect_dependencies(
    package: &serde_json::Value,
    layer: &Layer,
    rules: &Architecture,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let dependencies = package
        .get("dependencies")
        .and_then(|value| value.as_array())
        .ok_or("Missing dependencies")?;
    for dependency in dependencies {
        inspect_dependency(dependency, layer, rules, violations)?;
    }
    Ok(())
}

fn inspect_dependency(
    dependency: &serde_json::Value,
    layer: &Layer,
    rules: &Architecture,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let name = dependency
        .get("name")
        .and_then(|value| value.as_str())
        .ok_or("Missing dependency name")?;
    let internal = rules.layers.iter().any(|candidate| candidate.name == name);
    let permitted = if internal {
        &layer.may_import
    } else {
        &layer.external_dependencies
    };
    if !permitted.iter().any(|allowed| allowed == name) {
        violations.push(violation(
            &layer.path,
            1,
            "LAYER-DIRECTION",
            &format!("Undeclared dependency: {name}"),
        ));
    }
    if !internal
        && !layer
            .permitted_path_dependencies
            .iter()
            .any(|allowed| allowed == name)
        && dependency.get("path").is_some_and(|path| !path.is_null())
    {
        violations.push(violation(
            &layer.path,
            1,
            "LAYER-DIRECTION",
            "External path dependency is forbidden",
        ));
    }
    Ok(())
}

fn inspect_pending_layer(
    layer: &Layer,
    root: &Path,
    packages: &[serde_json::Value],
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    if !root.join(&layer.path).join("README.md").is_file() {
        violations.push(violation(
            &layer.path,
            1,
            "LAYER-DECLARED",
            "Missing crate README",
        ));
    }
    if packages.iter().any(|package| {
        package.get("name").and_then(|name| name.as_str()) == Some(layer.name.as_str())
    }) {
        violations.push(violation(
            &layer.path,
            1,
            "SPEC-FIRST",
            "Pending crate declared in Cargo",
        ));
    }
    reject_pending_sources(root, &root.join(&layer.path), violations)
}

fn reject_pending_sources(
    root: &Path,
    directory: &Path,
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    if !directory.is_dir() {
        return Ok(());
    }
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() {
            reject_pending_sources(root, &path, violations)?;
        } else if path.file_name().is_some_and(|name| name == "Cargo.toml")
            || path.extension().is_some_and(|extension| extension == "rs")
        {
            let relative = path.strip_prefix(root).map_err(|error| error.to_string())?;
            violations.push(violation(
                &relative.to_string_lossy(),
                1,
                "SPEC-FIRST",
                "Code in pending layer",
            ));
        }
    }
    Ok(())
}
