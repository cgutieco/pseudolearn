use crate::lock_error::{LockError, LockErrorCode};
use crate::lock_model::{Lock, LockKind, LockPackage, is_digest};
use crate::logical_path::{key, normalize, segments};
use std::collections::{BTreeMap, BTreeSet};

impl Lock {
    pub fn from_packages(packages: Vec<LockPackage>) -> Result<Self, Vec<LockError>> {
        let mut errors = Vec::new();
        let mut by_name: BTreeMap<String, LockPackage> = BTreeMap::new();
        let colliding_origins = colliding_origins(&packages);
        for mut package in packages {
            package.dependencies.sort();
            package.dependencies.dedup();
            normalize_package_paths(&mut package, &mut errors);
            check_package(&package, &mut errors);
            if key(&package.origin).is_some_and(|origin| colliding_origins.contains(&origin)) {
                errors.push(LockError::new(
                    LockErrorCode::InvalidLockPath,
                    &format!("{}.origin", field(&package.name)),
                    package.position,
                ));
            }
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

fn colliding_origins(packages: &[LockPackage]) -> BTreeSet<Vec<String>> {
    let mut names_by_origin: BTreeMap<Vec<String>, BTreeSet<&str>> = BTreeMap::new();
    for package in packages {
        if let Some(origin) = key(&package.origin) {
            names_by_origin
                .entry(origin)
                .or_default()
                .insert(&package.name);
        }
    }
    names_by_origin
        .into_iter()
        .filter_map(|(origin, names)| (names.len() > 1).then_some(origin))
        .collect()
}

fn normalize_package_paths(package: &mut LockPackage, errors: &mut Vec<LockError>) {
    if let Some(origin) = normalize(&package.origin) {
        package.origin = origin;
    }
    let mut files = BTreeMap::new();
    let mut keys = BTreeSet::new();
    for (path, digest) in std::mem::take(&mut package.files) {
        let here = format!("{}.files.{path}", field(&package.name));
        let Some(normalized) = normalize(&path) else {
            errors.push(LockError::new(
                LockErrorCode::InvalidLockPath,
                &here,
                package.position,
            ));
            continue;
        };
        let Some(path_key) = key(&normalized) else {
            errors.push(LockError::new(
                LockErrorCode::InvalidLockPath,
                &here,
                package.position,
            ));
            continue;
        };
        if !keys.insert(path_key) {
            errors.push(LockError::new(
                LockErrorCode::InvalidLockPath,
                &here,
                package.position,
            ));
            continue;
        }
        files.insert(normalized, digest);
    }
    package.files = files;
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
