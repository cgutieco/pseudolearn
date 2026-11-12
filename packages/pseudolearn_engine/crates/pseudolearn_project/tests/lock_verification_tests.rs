use pseudolearn_project::{Location, Lock, LockErrorCode, LockKind, LockPackage};
use std::collections::BTreeMap;

fn digest(seed: u64) -> String {
    format!("sha256:{seed:064x}")
}

fn geo(file_seed: u64, package_seed: u64) -> LockPackage {
    LockPackage {
        name: "geo".to_owned(),
        origin: "libs/geo".to_owned(),
        kind: LockKind::Locked,
        dependencies: Vec::new(),
        digest: Some(digest(package_seed)),
        files: BTreeMap::from([("a.pseudo".to_owned(), digest(file_seed))]),
        position: Location::START,
    }
}

fn lock(packages: Vec<LockPackage>) -> Result<Lock, String> {
    Lock::from_packages(packages).map_err(|errors| format!("{errors:?}"))
}

fn codes(recorded: &Lock, observed: &Lock) -> Vec<LockErrorCode> {
    recorded
        .verify(observed)
        .into_iter()
        .map(|error| error.code)
        .collect()
}

#[test]
fn identical_locks_verify() -> Result<(), String> {
    let recorded = lock(vec![geo(1, 10)])?;
    assert!(recorded.verify(&lock(vec![geo(1, 10)])?).is_empty());
    Ok(())
}

#[test]
fn altered_content_is_a_file_digest_mismatch() -> Result<(), String> {
    let found = codes(&lock(vec![geo(1, 10)])?, &lock(vec![geo(2, 11)])?);
    assert_eq!(found, vec![LockErrorCode::DigestMismatch]);
    Ok(())
}

#[test]
fn false_package_digest_is_detected_when_files_agree() -> Result<(), String> {
    let found = codes(&lock(vec![geo(1, 10)])?, &lock(vec![geo(1, 11)])?);
    assert_eq!(found, vec![LockErrorCode::DigestMismatch]);
    Ok(())
}

#[test]
fn missing_and_extra_files_are_reported() -> Result<(), String> {
    let mut observed = geo(1, 10);
    observed.files = BTreeMap::from([("b.pseudo".to_owned(), digest(1))]);
    let found = codes(&lock(vec![geo(1, 10)])?, &lock(vec![observed])?);
    assert_eq!(
        found,
        vec![LockErrorCode::FileMissing, LockErrorCode::FileNotLocked]
    );
    Ok(())
}

#[test]
fn absent_and_unlocked_packages_are_reported() -> Result<(), String> {
    let empty = lock(Vec::new())?;
    assert_eq!(
        codes(&lock(vec![geo(1, 10)])?, &empty),
        vec![LockErrorCode::LockedPackageAbsent]
    );
    assert_eq!(
        codes(&empty, &lock(vec![geo(1, 10)])?),
        vec![LockErrorCode::PackageNotLocked]
    );
    Ok(())
}

#[test]
fn changed_origin_kind_and_edges_are_reported() -> Result<(), String> {
    let util = LockPackage {
        name: "util".to_owned(),
        origin: "libs/util".to_owned(),
        kind: LockKind::Local,
        dependencies: Vec::new(),
        digest: None,
        files: BTreeMap::new(),
        position: Location::START,
    };
    let mut moved = geo(1, 10);
    moved.origin = "vendor/geo".to_owned();
    moved.dependencies = vec!["util".to_owned()];
    let recorded = lock(vec![geo(1, 10), util.clone()])?;
    let observed = lock(vec![moved, util])?;
    assert_eq!(
        codes(&recorded, &observed),
        vec![
            LockErrorCode::DependencyEdgeMismatch,
            LockErrorCode::OriginMismatch
        ]
    );
    Ok(())
}

#[test]
fn local_package_ignores_content_changes() -> Result<(), String> {
    let mut editable = geo(1, 10);
    editable.kind = LockKind::Local;
    editable.digest = None;
    editable.files.clear();
    let recorded = lock(vec![editable.clone()])?;
    assert!(recorded.verify(&lock(vec![editable])?).is_empty());
    Ok(())
}
