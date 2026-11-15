use pseudolearn_project::{Location, Lock, LockErrorCode, LockKind, LockPackage};
use std::collections::BTreeMap;

const DIGEST: &str = "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

fn package(origin: &str, files: &[(&str, &str)]) -> LockPackage {
    LockPackage {
        name: "geo".to_owned(),
        origin: origin.to_owned(),
        kind: LockKind::Locked,
        dependencies: Vec::new(),
        digest: Some(DIGEST.to_owned()),
        files: files
            .iter()
            .map(|(path, digest)| ((*path).to_owned(), (*digest).to_owned()))
            .collect::<BTreeMap<_, _>>(),
        position: Location::START,
    }
}

#[test]
fn canonical_lock_normalizes_paths_and_sorts_by_portable_key() -> Result<(), String> {
    let lock = Lock::from_packages(vec![package(
        "libs/café",
        &[
            ("Z.pseudo", DIGEST),
            ("café.pseudo", DIGEST),
            ("a.pseudo", DIGEST),
        ],
    )])
    .map_err(|errors| format!("{errors:?}"))?;
    let text = lock.canonical_text();
    assert!(text.contains("origin = \"libs/café\""));
    let first = text.find("\"a.pseudo\"").ok_or("missing a.pseudo")?;
    let second = text.find("\"café.pseudo\"").ok_or("missing café.pseudo")?;
    let third = text.find("\"Z.pseudo\"").ok_or("missing Z.pseudo")?;
    assert!(first < second && second < third);
    Ok(())
}

#[test]
fn rejects_case_and_nfc_collisions_in_lock_file_paths() {
    for files in [
        vec![("A.pseudo", DIGEST), ("a.pseudo", DIGEST)],
        vec![("café.pseudo", DIGEST), ("café.pseudo", DIGEST)],
    ] {
        let result = Lock::from_packages(vec![package("libs/geo", &files)]);
        assert!(result.is_err());
        assert!(result.is_err_and(|errors| {
            errors
                .iter()
                .any(|error| error.code == LockErrorCode::InvalidLockPath)
        }));
    }
}

#[test]
fn rejects_case_and_nfc_collisions_in_lock_origins() {
    let mut second = package("libs/geo", &[]);
    second.name = "geography".to_owned();
    let errors = Lock::from_packages(vec![package("libs/Geo", &[]), second])
        .err()
        .unwrap_or_default();
    let collisions: Vec<_> = errors
        .iter()
        .filter(|error| error.code == LockErrorCode::InvalidLockPath)
        .collect();
    assert_eq!(collisions.len(), 2);
    assert_eq!(
        collisions.first().map(|error| error.field.as_str()),
        Some("packages.geo.origin")
    );
    assert_eq!(
        collisions.last().map(|error| error.field.as_str()),
        Some("packages.geography.origin")
    );

    let mut second = package("libs/café", &[]);
    second.name = "geography".to_owned();
    let result = Lock::from_packages(vec![package("libs/café", &[]), second]);
    assert!(result.is_err_and(|errors| {
        errors
            .iter()
            .filter(|error| error.code == LockErrorCode::InvalidLockPath)
            .count()
            == 2
    }));
}

#[test]
fn rejects_nonportable_origins_and_file_paths() {
    let invalid_origin = Lock::from_packages(vec![package("../geo", &[])]);
    assert!(invalid_origin.is_err_and(|errors| {
        errors
            .iter()
            .any(|error| error.code == LockErrorCode::InvalidLockPath)
    }));

    let invalid_file = Lock::from_packages(vec![package("libs/geo", &[("CON.txt", DIGEST)])]);
    assert!(invalid_file.is_err_and(|errors| {
        errors
            .iter()
            .any(|error| error.code == LockErrorCode::InvalidLockPath)
    }));
}
