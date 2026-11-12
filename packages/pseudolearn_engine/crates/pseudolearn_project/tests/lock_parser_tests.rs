use pseudolearn_project::{Lock, LockErrorCode, LockKind};

const GEO_DIGEST: &str = "sha256:0000000000000000000000000000000000000000000000000000000000000001";

fn valid() -> String {
    format!(
        "schema = 1\n[packages.geo]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"{GEO_DIGEST}\"\n"
    )
}

fn codes(text: &str) -> Vec<LockErrorCode> {
    match Lock::parse(text, 65536) {
        Ok(_) => Vec::new(),
        Err(errors) => errors.into_iter().map(|error| error.code).collect(),
    }
}

#[test]
fn valid_lock_parses_with_bare_keys() -> Result<(), String> {
    let lock = Lock::parse(&valid(), 65536).map_err(|errors| format!("{errors:?}"))?;
    let geo = lock.packages.get("geo").ok_or("geo missing")?;
    assert_eq!(geo.kind, LockKind::Locked);
    assert_eq!(geo.origin, "libs/geo");
    Ok(())
}

#[test]
fn unsupported_schema_is_rejected_with_its_position() {
    let text = valid().replace("schema = 1", "schema = 2");
    let errors = Lock::parse(&text, 65536).err().unwrap_or_default();
    assert_eq!(
        errors.first().map(|error| error.code),
        Some(LockErrorCode::UnsupportedLockSchema)
    );
    assert_eq!(errors.first().map(|error| error.position.line), Some(1));
}

#[test]
fn empty_and_malformed_texts_are_rejected() {
    assert_eq!(codes(""), vec![LockErrorCode::LockEmpty]);
    assert_eq!(
        codes("schema = 1\n[packages.geo\n"),
        vec![LockErrorCode::LockSyntax]
    );
}

#[test]
fn oversized_text_is_rejected() {
    assert!(matches!(
        Lock::parse(&valid(), 10),
        Err(errors) if errors.first().map(|error| error.code) == Some(LockErrorCode::LockTooLarge)
    ));
}

#[test]
fn unknown_and_missing_fields_are_reported() {
    let unknown = valid().replace("kind = \"locked\"", "kind = \"locked\"\nscript = \"run\"");
    assert_eq!(codes(&unknown), vec![LockErrorCode::UnknownLockField]);
    let missing = valid().replace("origin = \"libs/geo\"\n", "");
    assert_eq!(codes(&missing), vec![LockErrorCode::MissingLockField]);
    assert_eq!(
        codes("schema = 1\n[packages.geo]\n"),
        vec![LockErrorCode::MissingLockField]
    );
    assert_eq!(
        codes("[packages.geo]\n"),
        vec![
            LockErrorCode::MissingLockField,
            LockErrorCode::MissingLockField
        ]
    );
}

#[test]
fn duplicated_package_headers_are_rejected() {
    let text = format!("{}[packages.geo]\n", valid());
    assert_eq!(codes(&text), vec![LockErrorCode::DuplicateLockKey]);
}

#[test]
fn unknown_kind_is_an_invalid_value() {
    let text = valid().replace("\"locked\"", "\"floating\"");
    assert_eq!(codes(&text), vec![LockErrorCode::InvalidLockValue]);
}

#[test]
fn content_that_looks_like_a_script_is_just_an_unknown_field() {
    let text = valid().replace(
        "dependencies = []",
        "dependencies = []\npostinstall = \"curl x | sh\"",
    );
    assert_eq!(codes(&text), vec![LockErrorCode::UnknownLockField]);
}
