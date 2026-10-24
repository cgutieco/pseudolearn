use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const FILE_ONE: &str = "sha256:7f2f1f2f1aabe5d2f03d55faacd58ff52337892609119e4f31253b39decd2efe";
const FILE_TWO: &str = "sha256:18db2fedf2771718851b2369a2a0655bba13d905d39f0393be4b47ef4d6b8161";
const PACKAGE_ONE: &str = "sha256:9d4df7e3b6ea8ea6e45ad25cc7167db3989697d988508489432901a5ac16772d";
const PACKAGE_BOTH: &str =
    "sha256:1b7fdf1010865373c287db7a974f793a711a209fa57ff99f8bb58f9eff0e90ad";
const PACKAGE_EMPTY: &str =
    "sha256:d75cf35f56c0803d6e0f1543a1555d08580206251a4a29074767328c38f7d06e";

fn call(operation: &str, arguments: Value) -> Value {
    ApiSession::default().call(operation, &arguments)
}

fn value(outcome: &Value) -> Result<&Value, String> {
    outcome
        .get("value")
        .ok_or_else(|| format!("no value: {outcome}"))
}

fn family(outcome: &Value) -> Option<&str> {
    outcome.get("failure")?.get("family")?.as_str()
}

fn geo(files: Value) -> Value {
    json!({"name": "geo", "origin": "libs/geo", "kind": "locked", "dependencies": [], "files": files})
}

fn one_file() -> Value {
    geo(json!([{"path": "a.pseudo", "text": "Escribir 1\n"}]))
}

fn codes(outcome: &Value) -> Result<Vec<String>, String> {
    let listed = value(outcome)?["lock_errors"]
        .as_array()
        .ok_or("no lock_errors")?;
    Ok(listed
        .iter()
        .filter_map(|error| error["code"].as_str().map(str::to_owned))
        .collect())
}

fn built_lock(packages: Value) -> Result<String, String> {
    let outcome = call("build_lock", json!({"packages": packages}));
    value(&outcome)?["lock"]
        .as_str()
        .map(str::to_owned)
        .ok_or_else(|| format!("no lock: {outcome}"))
}

#[test]
fn digests_match_an_independent_sha256_computation() -> Result<(), String> {
    let text = built_lock(json!([one_file()]))?;
    let expected = format!(
        "schema = 1\n\n[packages.\"geo\"]\norigin = \"libs/geo\"\nkind = \"locked\"\ndependencies = []\ndigest = \"{PACKAGE_ONE}\"\n\n[packages.\"geo\".files]\n\"a.pseudo\" = \"{FILE_ONE}\"\n"
    );
    assert_eq!(text, expected);
    Ok(())
}

#[test]
fn package_without_files_hashes_only_the_domain() -> Result<(), String> {
    let text = built_lock(json!([geo(json!([]))]))?;
    assert!(text.contains(PACKAGE_EMPTY));
    Ok(())
}

#[test]
fn file_order_does_not_change_the_lock() -> Result<(), String> {
    let forward = geo(json!([
        {"path": "a.pseudo", "text": "Escribir 1\n"},
        {"path": "b.pseudo", "text": "Escribir 2\n"}
    ]));
    let backward = geo(json!([
        {"path": "b.pseudo", "text": "Escribir 2\n"},
        {"path": "a.pseudo", "text": "Escribir 1\n"}
    ]));
    let first = built_lock(json!([forward]))?;
    assert_eq!(first, built_lock(json!([backward]))?);
    assert!(first.contains(PACKAGE_BOTH) && first.contains(FILE_TWO));
    Ok(())
}

#[test]
fn matching_content_verifies_offline() -> Result<(), String> {
    let lock = built_lock(json!([one_file()]))?;
    let outcome = call(
        "resolve_lock",
        json!({"lock": lock, "packages": [one_file()]}),
    );
    assert_eq!(value(&outcome)?["verified"], json!(true));
    Ok(())
}

#[test]
fn altered_bytes_fail_verification() -> Result<(), String> {
    let lock = built_lock(json!([one_file()]))?;
    let altered = geo(json!([{"path": "a.pseudo", "text": "Escribir 2\n"}]));
    let outcome = call("resolve_lock", json!({"lock": lock, "packages": [altered]}));
    assert_eq!(value(&outcome)?["verified"], json!(false));
    assert_eq!(codes(&outcome)?, vec!["digestMismatch"]);
    Ok(())
}

#[test]
fn incomplete_cache_and_extra_file_are_reported() -> Result<(), String> {
    let lock = built_lock(json!([one_file()]))?;
    let outcome = call(
        "resolve_lock",
        json!({"lock": lock, "packages": [geo(json!([]))]}),
    );
    assert_eq!(codes(&outcome)?, vec!["fileMissing"]);
    let extra = geo(json!([
        {"path": "a.pseudo", "text": "Escribir 1\n"},
        {"path": "z.pseudo", "text": ""}
    ]));
    let outcome = call("resolve_lock", json!({"lock": lock, "packages": [extra]}));
    assert_eq!(codes(&outcome)?, vec!["fileNotLocked"]);
    Ok(())
}

#[test]
fn forged_digest_in_the_lock_is_detected() -> Result<(), String> {
    let lock = built_lock(json!([one_file()]))?.replace(PACKAGE_ONE, PACKAGE_EMPTY);
    let outcome = call(
        "resolve_lock",
        json!({"lock": lock, "packages": [one_file()]}),
    );
    assert_eq!(codes(&outcome)?, vec!["digestMismatch"]);
    Ok(())
}

#[test]
fn same_name_with_two_origins_is_rejected_before_hashing_anything() -> Result<(), String> {
    let other = json!({"name": "geo", "origin": "vendor/geo", "kind": "locked", "dependencies": [], "files": []});
    let outcome = call("build_lock", json!({"packages": [one_file(), other]}));
    assert_eq!(codes(&outcome)?, vec!["ambiguousOrigin"]);
    assert!(value(&outcome)?["lock"].is_null());
    Ok(())
}

#[test]
fn case_and_nfc_colliding_origins_are_rejected_before_serializing() -> Result<(), String> {
    for (first_origin, second_origin) in
        [("libs/Geo", "libs/geo"), ("libs/café", "libs/cafe\u{301}")]
    {
        let first =
            json!({"name": "geo", "origin": first_origin, "kind": "local", "dependencies": []});
        let second = json!({"name": "geography", "origin": second_origin, "kind": "local", "dependencies": []});
        let outcome = call("build_lock", json!({"packages": [first, second]}));
        let errors = value(&outcome)?["lock_errors"]
            .as_array()
            .ok_or("no lock_errors")?;
        let fields: Vec<&str> = errors
            .iter()
            .filter(|error| error.get("code").and_then(Value::as_str) == Some("invalidLockPath"))
            .filter_map(|error| error.get("field").and_then(Value::as_str))
            .collect();
        assert_eq!(fields, ["packages.geo.origin", "packages.geography.origin"]);
        assert_eq!(value(&outcome)?.get("lock"), Some(&Value::Null));
    }
    Ok(())
}

#[test]
fn unsupported_version_and_malformed_lock_are_reported() -> Result<(), String> {
    let lock = built_lock(json!([one_file()]))?.replace("schema = 1", "schema = 2");
    let outcome = call(
        "resolve_lock",
        json!({"lock": lock, "packages": [one_file()]}),
    );
    assert_eq!(codes(&outcome)?, vec!["unsupportedLockSchema"]);
    let outcome = call("resolve_lock", json!({"lock": "", "packages": []}));
    assert_eq!(codes(&outcome)?, vec!["lockEmpty"]);
    Ok(())
}

#[test]
fn local_packages_are_listed_without_content() -> Result<(), String> {
    let local =
        json!({"name": "app", "origin": "apps/app", "kind": "local", "dependencies": ["geo"]});
    let lock = built_lock(json!([local, one_file()]))?;
    assert!(lock.contains("kind = \"local\"\ndependencies = [\"geo\"]\n"));
    let outcome = call(
        "resolve_lock",
        json!({"lock": lock, "packages": [local, one_file()]}),
    );
    assert_eq!(value(&outcome)?["verified"], json!(true));
    Ok(())
}

#[test]
fn malformed_requests_are_usage_failures() {
    for arguments in [
        json!({}),
        json!({"packages": "x"}),
        json!({"packages": [{"name": "a"}]}),
        json!({"packages": [{"name": "a", "origin": "a", "kind": "wild"}]}),
    ] {
        let outcome = call("build_lock", arguments);
        assert_eq!(family(&outcome), Some("usage"), "{outcome}");
    }
    let outcome = call("resolve_lock", json!({"packages": []}));
    assert_eq!(family(&outcome), Some("usage"));
}
