use std::path::Path;

pub fn check(root: &Path) -> Result<(), String> {
    for directory in [
        "apps/pseudolearn_app/lib",
        "apps/pseudolearn_app/tool",
        ".github",
    ] {
        visit(&root.join(directory))?;
    }
    for relative in [
        "apps/pseudolearn_app/pubspec.yaml",
        "packages/pseudolearn_benchmarks/pubspec.yaml",
    ] {
        inspect(&root.join(relative))?;
    }
    if root.join("packages/pseudolearn_core").exists() {
        return Err("RETIRED-DEPENDENCY: retired package is installed".to_owned());
    }
    Ok(())
}

fn visit(directory: &Path) -> Result<(), String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() {
            visit(&path)?;
        } else {
            inspect(&path)?;
        }
    }
    Ok(())
}

fn inspect(path: &Path) -> Result<(), String> {
    let source = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    if violates(
        &source,
        path.extension()
            .and_then(|extension| extension.to_str())
            .unwrap_or(""),
    ) {
        return Err(format!("RETIRED-DEPENDENCY: {}", path.display()));
    }
    Ok(())
}

fn violates(source: &str, extension: &str) -> bool {
    match extension {
        "dart" => source.lines().map(str::trim_start).any(|line| {
            (line.starts_with("import ") || line.starts_with("export "))
                && line.contains("package:pseudolearn_core/")
        }),
        "yaml" | "yml" => {
            source.contains("packages/pseudolearn_core")
                || source
                    .lines()
                    .any(|line| line.trim_start().starts_with("pseudolearn_core:"))
        }
        _ => false,
    }
}

#[cfg(test)]
#[path = "retirement_tests.rs"]
mod retirement_tests;
