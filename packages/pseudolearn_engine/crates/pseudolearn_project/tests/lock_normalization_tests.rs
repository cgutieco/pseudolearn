use pseudolearn_project::{Location, Lock, LockErrorCode, LockKind, LockPackage};
use std::collections::BTreeMap;

fn digest(seed: u64) -> String {
    format!("sha256:{seed:064x}")
}

fn package(name: &str, origin: &str, kind: LockKind) -> LockPackage {
    LockPackage {
        name: name.to_owned(),
        origin: origin.to_owned(),
        kind,
        dependencies: Vec::new(),
        digest: (kind == LockKind::Locked).then(|| digest(1)),
        files: BTreeMap::new(),
        position: Location::START,
    }
}

fn codes(packages: Vec<LockPackage>) -> Vec<LockErrorCode> {
    match Lock::from_packages(packages) {
        Ok(_) => Vec::new(),
        Err(errors) => errors.into_iter().map(|error| error.code).collect(),
    }
}

#[test]
fn same_name_with_two_origins_is_ambiguous() {
    let found = codes(vec![
        package("geo", "libs/geo", LockKind::Locked),
        package("geo", "vendor/geo", LockKind::Locked),
    ]);
    assert_eq!(found, vec![LockErrorCode::AmbiguousOrigin]);
}

#[test]
fn absolute_or_escaping_origins_are_rejected() {
    for origin in ["/home/me/geo", "../geo", "libs//geo", ""] {
        let found = codes(vec![package("geo", origin, LockKind::Local)]);
        assert_eq!(
            found,
            vec![LockErrorCode::InvalidLockPath],
            "origin {origin:?}"
        );
    }
}

#[test]
fn edge_to_an_absent_package_is_dangling() {
    let mut geo = package("geo", "libs/geo", LockKind::Locked);
    geo.dependencies = vec!["missing".to_owned()];
    assert_eq!(codes(vec![geo]), vec![LockErrorCode::DanglingEdge]);
}

#[test]
fn locked_package_needs_a_well_formed_digest() {
    let mut geo = package("geo", "libs/geo", LockKind::Locked);
    geo.digest = Some("sha256:ABC".to_owned());
    assert_eq!(
        codes(vec![geo.clone()]),
        vec![LockErrorCode::InvalidLockValue]
    );
    geo.digest = None;
    assert_eq!(codes(vec![geo]), vec![LockErrorCode::InvalidLockValue]);
}

#[test]
fn uppercase_hex_is_not_a_digest() {
    let mut geo = package("geo", "libs/geo", LockKind::Locked);
    geo.digest = Some(format!("sha256:{}", "A".repeat(64)));
    assert_eq!(codes(vec![geo]), vec![LockErrorCode::InvalidLockValue]);
}

#[test]
fn local_package_cannot_carry_content() {
    let mut app = package("app", "apps/app", LockKind::Local);
    app.digest = Some(digest(1));
    assert_eq!(codes(vec![app]), vec![LockErrorCode::InvalidLockValue]);
}

#[test]
fn file_paths_must_be_logical() {
    let mut geo = package("geo", "libs/geo", LockKind::Locked);
    geo.files.insert("../escape.pseudo".to_owned(), digest(2));
    assert_eq!(codes(vec![geo]), vec![LockErrorCode::InvalidLockPath]);
}

#[test]
fn empty_name_is_rejected() {
    assert_eq!(
        codes(vec![package("", "libs/geo", LockKind::Local)]),
        vec![LockErrorCode::InvalidLockValue]
    );
}
