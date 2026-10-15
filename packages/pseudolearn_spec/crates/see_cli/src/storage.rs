use see_model::{Corpus, contract::Lock};
use serde_json::Value;
use std::path::Path;

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
    if !path.exists() {
        return Ok(Lock::default());
    }
    read_json(&path)
}

pub fn valid(root: &Path) -> Result<Corpus, String> {
    let corpus = corpus(root)?;
    let mut errors = see_validation::validate(&corpus, &lock(root)?)?;
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
