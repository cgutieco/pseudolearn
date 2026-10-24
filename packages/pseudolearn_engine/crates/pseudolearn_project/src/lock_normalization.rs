use crate::lock_error::{LockError, LockErrorCode};
use crate::lock_model::{Lock, LockKind, LockPackage, is_digest};
use crate::logical_path::segments;
use std::collections::BTreeMap;

impl Lock {
    pub fn from_packages(packages: Vec<LockPackage>) -> Result<Self, Vec<LockError>> {
        let mut errors = Vec::new();
        let mut by_name: BTreeMap<String, LockPackage> = BTreeMap::new();
        for mut package in packages {
            package.dependencies.sort();
            package.dependencies.dedup();
            check_package(&package, &mut errors);
            if by_name.contains_key(&package.name) {
                errors.push(LockError::new(
                    LockErrorCode::AmbiguousOrigin,
                    &field(&package.name),
                    package.position,
                ));
                continue;
            }
            by_name.insert(package.name.clone(), package);
        }
        check_edges(&by_name, &mut errors);
        if errors.is_empty() {
            return Ok(Self { packages: by_name });
        }
        LockError::sort(&mut errors);
        Err(errors)
    }
}

pub(crate) fn field(name: &str) -> String {
    format!("packages.{name}")
}

fn check_package(package: &LockPackage, errors: &mut Vec<LockError>) {
    let here = field(&package.name);
    if package.name.is_empty() {
        errors.push(LockError::new(
            LockErrorCode::InvalidLockValue,
            &here,
            package.position,
        ));
    }
    if segments(&package.origin).is_none() {
        errors.push(LockError::new(
            LockErrorCode::InvalidLockPath,
            &format!("{here}.origin"),
            package.position,
        ));
    }
    match package.kind {
        LockKind::Local => check_local(package, &here, errors),
        LockKind::Locked => check_locked(package, &here, errors),
    }
}

fn check_local(package: &LockPackage, here: &str, errors: &mut Vec<LockError>) {
    if package.digest.is_some() || !package.files.is_empty() {
        errors.push(LockError::new(
            LockErrorCode::InvalidLockValue,
            &format!("{here}.kind"),
            package.position,
        ));
    }
}

fn check_locked(package: &LockPackage, here: &str, errors: &mut Vec<LockError>) {
    if !package.digest.as_deref().is_some_and(is_digest) {
        errors.push(LockError::new(
            LockErrorCode::InvalidLockValue,
            &format!("{here}.digest"),
            package.position,
        ));
    }
    for (path, digest) in &package.files {
        let file_field = format!("{here}.files.{path}");
        if segments(path).is_none() {
            errors.push(LockError::new(
                LockErrorCode::InvalidLockPath,
                &file_field,
                package.position,
            ));
        }
        if !is_digest(digest) {
            errors.push(LockError::new(
                LockErrorCode::InvalidLockValue,
                &file_field,
                package.position,
            ));
        }
    }
}

fn check_edges(packages: &BTreeMap<String, LockPackage>, errors: &mut Vec<LockError>) {
    for package in packages.values() {
        for dependency in &package.dependencies {
            if !packages.contains_key(dependency) {
                errors.push(LockError::new(
                    LockErrorCode::DanglingEdge,
                    &format!("{}.dependencies.{dependency}", field(&package.name)),
                    package.position,
                ));
            }
        }
    }
}
