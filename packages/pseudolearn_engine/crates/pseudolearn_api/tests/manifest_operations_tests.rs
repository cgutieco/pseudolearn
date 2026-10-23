use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const APP: &str = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[requests.limits]\nstatements = 5\n";
const LOOP: &str =
    "Algoritmo P\nMientras Verdadero Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n";
const QUIET: &str = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";

fn call(operation: &str, arguments: Value) -> Value {
    ApiSession::default().call(operation, &arguments)
}

fn value(outcome: &Value) -> Result<&Value, String> {
    outcome
        .get("value")
        .ok_or_else(|| format!("no value: {outcome}"))
}

fn project(main: &str) -> Value {
    json!({
        "project_id": "1",
        "revision_id": "1",
        "manifests": [{"location": "app", "text": APP}],
        "files": [{"path": "app/main", "source_id": 1, "text": main}]
    })
}

fn family(outcome: &Value) -> Option<&str> {
    outcome.get("failure")?.get("family")?.as_str()
}

#[test]
fn resolve_manifest_reports_errors_and_no_configuration() -> Result<(), String> {
    let outcome = call(
        "resolve_manifest",
        json!({"manifest": "schema 1\n", "location": "app"}),
    );
    let result = value(&outcome)?;
    assert_eq!(result.pointer("/configuration"), Some(&Value::Null));
    assert_eq!(
        result.pointer("/manifest_errors/0/code"),
        Some(&json!("manifestSyntax"))
    );
    assert_eq!(
        result.pointer("/manifest_errors/0/location"),
        Some(&json!("app"))
    );
    Ok(())
}

#[test]
fn resolve_manifest_ignores_the_interface_language() -> Result<(), String> {
    let arguments = |profile: &str| json!({"manifest": APP, "location": "app", "profile": profile, "grants": {"limits": {"statements": 9}}});
    let spanish = call("resolve_manifest", arguments("es"));
    let english = call("resolve_manifest", arguments("en"));
    assert_eq!(value(&spanish)?, value(&english)?);
    assert_eq!(
        value(&spanish)?.pointer("/configuration/limits/statements/effective"),
        Some(&json!(5))
    );
    Ok(())
}

#[test]
fn malformed_grants_and_locations_are_usage_failures() {
    let base = |extra: Value| {
        let mut arguments = json!({"manifest": APP, "location": "app"});
        if let (Some(target), Some(source)) = (arguments.as_object_mut(), extra.as_object()) {
            target.extend(source.clone());
        }
        arguments
    };
    for arguments in [
        base(json!({"grants": 5})),
        base(json!({"grants": {"permissions": {}}})),
        base(json!({"grants": {"limits": {"speed": 1}}})),
        base(json!({"grants": {"limits": {"depth": -1}}})),
        base(json!({"location": "../x"})),
        json!({"location": "app"}),
        json!({"manifest": APP}),
    ] {
        let outcome = call("resolve_manifest", arguments);
        assert_eq!(family(&outcome), Some("usage"), "{outcome}");
    }
}

#[test]
fn granted_statement_limit_stops_the_execution() -> Result<(), String> {
    let outcome = call(
        "execute_project",
        json!({"project": project(LOOP), "entry": "app/main", "grants": {"limits": {"statements": 5}}}),
    );
    let result = value(&outcome)?;
    assert_eq!(
        result.pointer("/termination/limit"),
        Some(&json!("statements"))
    );
    assert_eq!(result.pointer("/manifest_errors"), Some(&json!([])));
    Ok(())
}

#[test]
fn ungranted_request_blocks_the_execution() -> Result<(), String> {
    let outcome = call(
        "execute_project",
        json!({"project": project(QUIET), "entry": "app/main"}),
    );
    let result = value(&outcome)?;
    assert_eq!(
        result.pointer("/manifest_errors/0/code"),
        Some(&json!("limitNotGranted"))
    );
    assert!(result.get("output").is_none());
    Ok(())
}

#[test]
fn wider_grant_never_amplifies_beyond_the_request() -> Result<(), String> {
    let outcome = call(
        "execute_project",
        json!({"project": project(LOOP), "entry": "app/main", "grants": {"limits": {"statements": 1000000}}}),
    );
    assert_eq!(
        value(&outcome)?.pointer("/termination/limit"),
        Some(&json!("statements"))
    );
    Ok(())
}

#[test]
fn packages_and_manifests_together_or_neither_are_usage_failures() {
    let mut both = project(QUIET);
    if let Some(object) = both.as_object_mut() {
        object.insert("packages".to_owned(), json!([]));
    }
    let neither = json!({"project_id": "1", "revision_id": "1", "files": []});
    for candidate in [both, neither] {
        let outcome = call("analyze_project", json!({"project": candidate}));
        assert_eq!(family(&outcome), Some("usage"), "{outcome}");
    }
}

#[test]
fn manifest_projects_without_manifests_ignore_script_like_content() -> Result<(), String> {
    let hostile = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[scripts]\nbuild = \"rm -rf /\"\n";
    let candidate = json!({
        "project_id": "1",
        "revision_id": "1",
        "manifests": [{"location": "app", "text": hostile}],
        "files": [{"path": "app/main", "source_id": 1, "text": QUIET}]
    });
    let outcome = call("analyze_project", json!({"project": candidate}));
    let result = value(&outcome)?;
    assert_eq!(
        result.pointer("/manifest_errors/0/code"),
        Some(&json!("unknownField"))
    );
    assert_eq!(
        result.pointer("/manifest_errors/0/field"),
        Some(&json!("scripts"))
    );
    Ok(())
}
