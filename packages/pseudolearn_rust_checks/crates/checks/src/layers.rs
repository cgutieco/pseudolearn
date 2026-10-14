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
    for layer in &rules.layers {
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
    Ok(violations)
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
    inspect_dependencies(package, layer, rules, violations)
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
        if !internal && dependency.get("path").is_some_and(|path| !path.is_null()) {
            violations.push(violation(
                &layer.path,
                1,
                "LAYER-DIRECTION",
                "External path dependency is forbidden",
            ));
        }
    }
    Ok(())
}
