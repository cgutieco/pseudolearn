use crate::lock_error::{LockError, LockErrorCode};
use crate::lock_model::{Lock, LockKind, LockPackage};
use crate::lock_normalization::field;
use std::collections::BTreeSet;

impl Lock {
    pub fn verify(&self, observed: &Lock) -> Vec<LockError> {
        let mut errors = Vec::new();
        let names: BTreeSet<&String> = self
            .packages
            .keys()
            .chain(observed.packages.keys())
            .collect();
        for name in names {
            match (self.packages.get(name), observed.packages.get(name)) {
                (Some(locked), Some(actual)) => compare(locked, actual, &mut errors),
                (Some(locked), None) => errors.push(LockError::new(
                    LockErrorCode::LockedPackageAbsent,
                    &field(name),
                    locked.position,
                )),
                (None, Some(actual)) => errors.push(LockError::new(
                    LockErrorCode::PackageNotLocked,
                    &field(name),
                    actual.position,
                )),
                (None, None) => {}
            }
        }
        LockError::sort(&mut errors);
        errors
    }
}

fn compare(locked: &LockPackage, actual: &LockPackage, errors: &mut Vec<LockError>) {
    let here = field(&locked.name);
    let mut report = |code: LockErrorCode, suffix: &str| {
        errors.push(LockError::new(
            code,
            &format!("{here}{suffix}"),
            locked.position,
        ));
    };
    if locked.origin != actual.origin {
        report(LockErrorCode::OriginMismatch, ".origin");
    }
    if locked.kind != actual.kind {
        report(LockErrorCode::KindMismatch, ".kind");
    }
    if locked.dependencies != actual.dependencies {
        report(LockErrorCode::DependencyEdgeMismatch, ".dependencies");
    }
    if locked.kind == LockKind::Locked && actual.kind == LockKind::Locked {
        compare_content(locked, actual, &mut report);
    }
}

fn compare_content(
    locked: &LockPackage,
    actual: &LockPackage,
    report: &mut impl FnMut(LockErrorCode, &str),
) {
    let mut file_problem = false;
    for (path, digest) in &locked.files {
        match actual.files.get(path) {
            None => {
                file_problem = true;
                report(LockErrorCode::FileMissing, &format!(".files.{path}"));
            }
            Some(found) if found != digest => {
                file_problem = true;
                report(LockErrorCode::DigestMismatch, &format!(".files.{path}"));
            }
            Some(_) => {}
        }
    }
    for path in actual
        .files
        .keys()
        .filter(|path| !locked.files.contains_key(*path))
    {
        file_problem = true;
        report(LockErrorCode::FileNotLocked, &format!(".files.{path}"));
    }
    if !file_problem && locked.digest != actual.digest {
        report(LockErrorCode::DigestMismatch, ".digest");
    }
}
