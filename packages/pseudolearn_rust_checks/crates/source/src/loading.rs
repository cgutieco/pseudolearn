use pseudolearn_check_model::Architecture;
use std::path::{Path, PathBuf};

pub struct SourceFile {
    pub path: PathBuf,
    pub relative: String,
    pub text: String,
    pub syntax: syn::File,
    pub layer: usize,
    pub is_test: bool,
}

pub fn read_architecture(root: &Path) -> Result<Architecture, String> {
    let text = read_text(&root.join("architecture.yaml"))?;
    let rules: Architecture = serde_yaml::from_str(&text).map_err(|error| error.to_string())?;
    validate_rules(&rules)?;
    Ok(rules)
}

fn validate_rules(rules: &Architecture) -> Result<(), String> {
    let mut names = std::collections::BTreeSet::new();
    let mut paths = std::collections::BTreeSet::new();
    let mut generated_sources = std::collections::BTreeSet::new();
    if rules.package.is_empty() || rules.layers.is_empty() {
        return Err("Package and layers must be nonempty".to_owned());
    }
    for source in &rules.generated_sources {
        if source.is_empty()
            || !is_relative_path(source)
            || Path::new(source)
                .components()
                .any(|component| !matches!(component, std::path::Component::Normal(_)))
            || !generated_sources.insert(source)
        {
            return Err("Generated source paths must be unique member-relative paths".to_owned());
        }
    }
    for layer in &rules.layers {
        if !names.insert(&layer.name) || !paths.insert(&layer.path) {
            return Err("Duplicate layer name or path".to_owned());
        }
        if layer.path.is_empty() || !is_relative_path(&layer.path) {
            return Err("Layer paths must stay inside the member".to_owned());
        }
    }
    for layer in &rules.layers {
        if layer.may_import.iter().any(|name| !names.contains(name)) {
            return Err("Unknown permitted layer".to_owned());
        }
    }
    validate_limits(rules)
}

fn validate_limits(rules: &Architecture) -> Result<(), String> {
    let limits = &rules.limits;
    let thresholds = [
        limits.file_lines,
        limits.function_lines,
        limits.positional_parameters,
        limits.nesting_depth,
        limits.public_methods_per_class,
        limits.unsafe_function_lines,
        rules.names.minimum_length,
    ];
    if thresholds.contains(&0) {
        return Err("Limits must be positive".to_owned());
    }
    Ok(())
}

pub fn is_relative_path(value: &str) -> bool {
    Path::new(value).components().all(|component| {
        matches!(
            component,
            std::path::Component::Normal(_) | std::path::Component::CurDir
        )
    })
}

pub fn read_text(path: &Path) -> Result<String, String> {
    std::fs::read_to_string(path).map_err(|error| format!("{}: {error}", path.display()))
}

pub fn load_sources(root: &Path, rules: &Architecture) -> Result<Vec<SourceFile>, String> {
    let mut sources = Vec::new();
    for (index, layer) in rules.layers.iter().enumerate() {
        let directory = root.join(&layer.path);
        for relative in ["src", "tests", "examples", "benches"] {
            let source_root = directory.join(relative);
            if source_root.exists() {
                collect_sources(&source_root, &mut sources, root, index)?;
            }
        }
        let build_script = directory.join("build.rs");
        if build_script.exists() {
            sources.push(parse_source(&build_script, root, index)?);
        }
    }
    sources.retain(|source| !is_generated_source(&source.relative, &rules.generated_sources));
    sources.sort_by(|first, second| first.path.cmp(&second.path));
    Ok(sources)
}

fn is_generated_source(relative: &str, generated_sources: &[String]) -> bool {
    generated_sources.iter().any(|generated| {
        relative == generated
            || relative
                .strip_prefix(generated)
                .is_some_and(|suffix| suffix.starts_with('/'))
    })
}

fn collect_sources(
    directory: &Path,
    sources: &mut Vec<SourceFile>,
    root: &Path,
    layer: usize,
) -> Result<(), String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_symlink() {
            return Err(format!("Symlink source is not allowed: {}", path.display()));
        }
        if path.is_dir() {
            collect_sources(&path, sources, root, layer)?;
        } else if path.extension().is_some_and(|extension| extension == "rs") {
            sources.push(parse_source(&path, root, layer)?);
        }
    }
    Ok(())
}

fn parse_source(path: &Path, root: &Path, layer: usize) -> Result<SourceFile, String> {
    let text = read_text(path)?;
    let syntax = syn::parse_file(&text).map_err(|error| format!("{}: {error}", path.display()))?;
    let relative = path
        .strip_prefix(root)
        .map_err(|error| error.to_string())?
        .to_string_lossy()
        .replace('\\', "/");
    let is_test = relative.contains("/tests/") || relative.ends_with("_tests.rs");
    Ok(SourceFile {
        path: path.to_owned(),
        relative,
        text,
        syntax,
        layer,
        is_test,
    })
}
