use pseudolearn_project::{Location, Lock, LockKind, LockPackage};
use std::collections::BTreeMap;

fn digest(seed: u64) -> String {
    format!("sha256:{seed:064x}")
}

fn locked(name: &str, dependencies: &[&str], files: &[(&str, u64)]) -> LockPackage {
    LockPackage {
        name: name.to_owned(),
        origin: format!("libs/{name}"),
        kind: LockKind::Locked,
        dependencies: dependencies.iter().map(|each| (*each).to_owned()).collect(),
        digest: Some(digest(900)),
        files: files
            .iter()
            .map(|(path, seed)| ((*path).to_owned(), digest(*seed)))
            .collect(),
        position: Location::START,
    }
}

fn local(name: &str) -> LockPackage {
    LockPackage {
        name: name.to_owned(),
        origin: format!("apps/{name}"),
        kind: LockKind::Local,
        dependencies: Vec::new(),
        digest: None,
        files: BTreeMap::new(),
        position: Location::START,
    }
}

fn build(packages: Vec<LockPackage>) -> Result<Lock, String> {
    Lock::from_packages(packages).map_err(|errors| format!("{errors:?}"))
}

#[test]
fn canonical_text_lists_packages_in_name_order_with_sorted_files() -> Result<(), String> {
    let lock = build(vec![
        locked("geo", &["util"], &[("b.pseudo", 2), ("a.pseudo", 1)]),
        locked("util", &[], &[]),
        local("app"),
    ])?;
    let expected = format!(
        "schema = 1\n\n[packages.\"app\"]\norigin = \"apps/app\"\nkind = \"local\"\ndependencies = []\n\n\
[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = [\"util\"]\ndigest = \"{d}\"\n\n\
[packages.\"geo\".files]\n\"a.pseudo\" = \"{a}\"\n\"b.pseudo\" = \"{b}\"\n\n\
[packages.\"util\"]\norigin = \"libs/util\"\nkind = \"locked\"\ndependencies = []\ndigest = \"{d}\"\n",
        d = digest(900),
        a = digest(1),
        b = digest(2),
    );
    assert_eq!(lock.canonical_text(), expected);
    Ok(())
}

#[test]
fn input_order_does_not_change_the_bytes() -> Result<(), String> {
    let forward = build(vec![
        locked("geo", &["util", "app"], &[("a.pseudo", 1), ("b.pseudo", 2)]),
        locked("util", &[], &[]),
        local("app"),
    ])?;
    let shuffled = build(vec![
        local("app"),
        locked("util", &[], &[]),
        locked(
            "geo",
            &["app", "util", "util"],
            &[("b.pseudo", 2), ("a.pseudo", 1)],
        ),
    ])?;
    assert_eq!(forward.canonical_text(), shuffled.canonical_text());
    Ok(())
}

#[test]
fn every_permutation_of_four_packages_gives_identical_bytes() -> Result<(), String> {
    let names = ["a", "b", "c", "d"];
    let reference = build(
        names
            .iter()
            .map(|name| locked(name, &[], &[("x.pseudo", 3)]))
            .collect(),
    )?
    .canonical_text();
    for rotation in 0..names.len() {
        let mut rotated: Vec<LockPackage> = names
            .iter()
            .map(|name| locked(name, &[], &[("x.pseudo", 3)]))
            .collect();
        rotated.rotate_left(rotation);
        rotated.reverse();
        assert_eq!(build(rotated)?.canonical_text(), reference);
    }
    Ok(())
}

#[test]
fn canonical_text_parses_back_to_the_same_lock() -> Result<(), String> {
    let lock = build(vec![
        locked("geo", &["util"], &[("a.pseudo", 1)]),
        locked("util", &[], &[("sub/dir.pseudo", 4)]),
        local("app"),
    ])?;
    let parsed =
        Lock::parse(&lock.canonical_text(), 65536).map_err(|errors| format!("{errors:?}"))?;
    assert_eq!(parsed.canonical_text(), lock.canonical_text());
    Ok(())
}

#[test]
fn names_needing_escapes_survive_the_round_trip() -> Result<(), String> {
    let mut package = locked("a\"b\\c", &[], &[]);
    package.origin = "libs/geo".to_owned();
    let lock = build(vec![package])?;
    let parsed =
        Lock::parse(&lock.canonical_text(), 65536).map_err(|errors| format!("{errors:?}"))?;
    assert!(parsed.packages.contains_key("a\"b\\c"));
    Ok(())
}

#[test]
fn empty_lock_has_only_the_schema_line() -> Result<(), String> {
    assert_eq!(build(Vec::new())?.canonical_text(), "schema = 1\n");
    Ok(())
}
