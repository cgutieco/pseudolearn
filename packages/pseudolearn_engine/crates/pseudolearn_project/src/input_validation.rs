use crate::logical_path::{key_parts, segments};
use crate::project_error::MalformedProject;
use crate::project_model::{FileInput, PackageInput, ProjectInput};
use pseudolearn_source::IdentifierNormalizer;
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn check(input: &ProjectInput) -> Result<(), MalformedProject> {
    if input.project_id == 0 || input.revision_id == 0 {
        return Err(malformed(
            "project and revision identifiers must be positive",
        ));
    }
    packages(&input.packages)?;
    files(&input.files)
}

fn packages(packages: &[PackageInput]) -> Result<(), MalformedProject> {
    let mut names = BTreeSet::new();
    let mut name_keys = BTreeSet::new();
    let mut roots = BTreeSet::new();
    for package in packages {
        let normalized_name = IdentifierNormalizer::normalize(&package.name);
        if package.name.is_empty()
            || !names.insert(package.name.as_str())
            || !name_keys.insert(key_parts(&[normalized_name]))
        {
            return Err(malformed("package names must be non-empty and unique"));
        }
        let Some(root) = segments(&package.root) else {
            return Err(malformed("package root is not a logical path"));
        };
        if !roots.insert(key_parts(&root)) {
            return Err(malformed("package roots must have unique portable paths"));
        }
        for entry in &package.entries {
            if segments(entry).is_none() {
                return Err(malformed("package entry is not a logical path"));
            }
        }
        if package.dependencies.keys().any(String::is_empty) {
            return Err(malformed("dependency aliases must be non-empty"));
        }
    }
    Ok(())
}

fn files(files: &[FileInput]) -> Result<(), MalformedProject> {
    let mut paths = BTreeMap::new();
    let mut directories = BTreeMap::new();
    let mut identifiers = BTreeSet::new();
    for file in files {
        let Some(parts) = segments(&file.path) else {
            return Err(malformed("file path is not a logical path"));
        };
        let path_key = key_parts(&parts);
        if paths.insert(path_key, parts.clone()).is_some() {
            return Err(malformed("file paths must have unique portable paths"));
        }
        for depth in 1..parts.len() {
            let prefix = parts.get(..depth).unwrap_or_default();
            let prefix_key = key_parts(prefix);
            if directories
                .get(&prefix_key)
                .is_some_and(|existing| existing != prefix)
            {
                return Err(malformed(
                    "implicit directories must have unique portable paths",
                ));
            }
            directories.insert(prefix_key, prefix.to_vec());
        }
        if file.source_id == 0 || !identifiers.insert(file.source_id) {
            return Err(malformed("source identifiers must be positive and unique"));
        }
    }
    if directories
        .keys()
        .any(|directory| paths.contains_key(directory))
    {
        return Err(malformed("file paths cannot also be directories"));
    }
    Ok(())
}

fn malformed(reason: &str) -> MalformedProject {
    MalformedProject(reason.to_owned())
}
