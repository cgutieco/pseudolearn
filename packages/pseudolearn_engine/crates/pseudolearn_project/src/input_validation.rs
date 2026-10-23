use crate::logical_path::segments;
use crate::project_error::MalformedProject;
use crate::project_model::{FileInput, PackageInput, ProjectInput};
use std::collections::BTreeSet;

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
    for package in packages {
        if package.name.is_empty() || !names.insert(package.name.as_str()) {
            return Err(malformed("package names must be non-empty and unique"));
        }
        if segments(&package.root).is_none() {
            return Err(malformed("package root is not a logical path"));
        }
        if package
            .entries
            .iter()
            .any(|entry| segments(entry).is_none())
        {
            return Err(malformed("package entry is not a logical path"));
        }
        if package.dependencies.keys().any(String::is_empty) {
            return Err(malformed("dependency aliases must be non-empty"));
        }
    }
    Ok(())
}

fn files(files: &[FileInput]) -> Result<(), MalformedProject> {
    let mut paths = BTreeSet::new();
    let mut identifiers = BTreeSet::new();
    for file in files {
        if segments(&file.path).is_none() || !paths.insert(file.path.as_str()) {
            return Err(malformed("file paths must be unique logical paths"));
        }
        if file.source_id == 0 || !identifiers.insert(file.source_id) {
            return Err(malformed("source identifiers must be positive and unique"));
        }
    }
    Ok(())
}

fn malformed(reason: &str) -> MalformedProject {
    MalformedProject(reason.to_owned())
}
