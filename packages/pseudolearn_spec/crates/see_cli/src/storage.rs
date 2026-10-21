use see_model::{Corpus, contract::Lock};
use serde_json::Value;
use std::collections::BTreeSet;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

pub fn corpus(root: &Path) -> Result<Corpus, String> {
    see_format::read(&root.join("specifications"))
}

pub fn read_json<Type: serde::de::DeserializeOwned>(path: &Path) -> Result<Type, String> {
    let text =
        std::fs::read_to_string(path).map_err(|error| format!("{}: {error}", path.display()))?;
    serde_json::from_str(&text).map_err(|error| format!("{}: {error}", path.display()))
}

pub fn lock(root: &Path) -> Result<Lock, String> {
    let path = root.join("specifications/specifications.lock");
    let Some(previous) = previous_corpus(root)? else {
        return if path.exists() {
            read_json(&path)
        } else {
            Ok(Lock::default())
        };
    };
    see_change::locking::generate(&previous, &Lock::default())
}

pub fn local_lock(root: &Path) -> Result<Lock, String> {
    let path = root.join("specifications/specifications.lock");
    if path.exists() {
        return read_json(&path);
    }
    lock(root)
}

fn previous_corpus(root: &Path) -> Result<Option<Corpus>, String> {
    let Some(repository) = repository_root(root) else {
        return Ok(None);
    };
    let package = root
        .canonicalize()
        .map_err(|error| error.to_string())?
        .strip_prefix(&repository)
        .map_err(|error| error.to_string())?
        .to_path_buf();
    let specification_directory = package.join("specifications");
    let directory = specification_directory.to_string_lossy().into_owned();
    let base = baseline_revision(&repository, &directory);
    let changed = changed_sources(&repository, &base, &directory)?;
    let current = see_format::read(&root.join("specifications"))?;
    let mut previous = unchanged_sources(current, &changed)?;
    previous.extend(previous_changed_sources(&repository, &base, &changed)?);
    Ok(Some(previous))
}

fn repository_root(root: &Path) -> Option<PathBuf> {
    let output = Command::new("git")
        .current_dir(root)
        .args(["rev-parse", "--show-toplevel"])
        .output()
        .ok()?;
    output
        .status
        .success()
        .then(|| PathBuf::from(String::from_utf8_lossy(&output.stdout).trim()))
}

fn baseline_revision(repository: &Path, directory: &str) -> String {
    if changed_since(repository, "HEAD", directory) {
        return "HEAD".to_owned();
    }
    if changed_since(repository, "HEAD^", directory) {
        return "HEAD^".to_owned();
    }
    "HEAD".to_owned()
}

fn changed_since(repository: &Path, revision: &str, directory: &str) -> bool {
    Command::new("git")
        .current_dir(repository)
        .args(["diff", "--quiet", revision, "--", directory])
        .status()
        .is_ok_and(|status| status.code() == Some(1))
}

fn changed_sources(
    repository: &Path,
    revision: &str,
    directory: &str,
) -> Result<BTreeSet<PathBuf>, String> {
    let changed = git_output(
        repository,
        &["diff", "--name-only", revision, "--", directory],
    )?;
    let untracked = git_output(
        repository,
        &[
            "ls-files",
            "--others",
            "--exclude-standard",
            "--",
            directory,
        ],
    )?;
    let mut paths = BTreeSet::new();
    for name in changed
        .stdout
        .split(|byte| *byte == b'\n')
        .chain(untracked.stdout.split(|byte| *byte == b'\n'))
    {
        if name.ends_with(b".md") {
            let relative = String::from_utf8_lossy(name).trim().to_owned();
            paths.insert(repository.join(relative));
        }
    }
    Ok(paths)
}

fn unchanged_sources(current: Corpus, changed: &BTreeSet<PathBuf>) -> Result<Corpus, String> {
    let current_directory = std::env::current_dir().map_err(|error| error.to_string())?;
    let mut previous = Vec::new();
    for specification in current {
        let path = PathBuf::from(&specification.path);
        let absolute = if path.is_absolute() {
            path
        } else {
            current_directory.join(path)
        };
        let canonical = absolute.canonicalize().map_err(|error| error.to_string())?;
        if !changed.contains(&canonical) {
            previous.push(specification);
        }
    }
    Ok(previous)
}

fn previous_changed_sources(
    repository: &Path,
    revision: &str,
    changed: &BTreeSet<PathBuf>,
) -> Result<Corpus, String> {
    let mut previous = Vec::new();
    for absolute in changed {
        let Ok(relative) = absolute.strip_prefix(repository) else {
            continue;
        };
        let source = format!("{revision}:{}", relative.to_string_lossy());
        let output = git_output(repository, &["show", &source])?;
        if output.status.success() {
            previous.push(see_format::parsing::parse(
                &absolute.to_string_lossy(),
                &String::from_utf8_lossy(&output.stdout),
            )?);
        }
    }
    Ok(previous)
}

fn git_output(repository: &Path, arguments: &[&str]) -> Result<Output, String> {
    Command::new("git")
        .current_dir(repository)
        .args(arguments)
        .output()
        .map_err(|error| error.to_string())
}

pub fn valid(root: &Path) -> Result<Corpus, String> {
    let corpus = corpus(root)?;
    validate_corpus(root, corpus, &lock(root)?)
}

pub fn valid_for_diff(root: &Path) -> Result<Corpus, String> {
    validate_corpus(root, corpus(root)?, &Lock::default())
}

fn validate_corpus(root: &Path, corpus: Corpus, anchor: &Lock) -> Result<Corpus, String> {
    let mut errors = see_validation::validate(&corpus, anchor)?;
    errors.extend(crate::resources::check(root, &corpus)?);
    errors.extend(crate::bindings::check(root, &corpus)?);
    errors.extend(crate::property_registry::check(root, &corpus)?);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    Ok(corpus)
}

pub fn artifact(path: &Path, value: &Value, check: bool) -> Result<String, String> {
    let canonical = format!(
        "{}\n",
        serde_json::to_string_pretty(value).map_err(|error| error.to_string())?
    );
    if check {
        let existing = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
        if existing != canonical {
            return Err(format!("SEE-STALE: {}", path.display()));
        }
    } else {
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
        }
        std::fs::write(path, canonical).map_err(|error| error.to_string())?;
    }
    Ok(format!("Verified {}", path.display()))
}

pub fn valid_for_refresh(root: &Path, authorized: &[String]) -> Result<Corpus, String> {
    let corpus = corpus(root)?;
    let mut errors = see_validation::validate(&corpus, &lock(root)?)?;
    errors.retain(|error| {
        !corpus.iter().any(|specification| {
            authorized.contains(&specification.metadata.id)
                && error
                    == &format!(
                        "SEE-HASH: content changed without version: {}@{}",
                        specification.metadata.id, specification.metadata.version
                    )
        })
    });
    errors.extend(crate::resources::check(root, &corpus)?);
    errors.extend(crate::bindings::check(root, &corpus)?);
    errors.extend(crate::property_registry::check(root, &corpus)?);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    Ok(corpus)
}
