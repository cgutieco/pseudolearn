use pseudolearn_api::ApiSession;
use serde_json::{Map, Value, json};
use std::collections::BTreeMap;

const SOURCE: &str = "Algoritmo P\nEscribir @;\nFinAlgoritmo\n";

fn request(reverse: bool, locale: &str) -> Value {
    let (packages, files) = if reverse {
        (
            json!([
                {"name": "zeta", "root": "zeta", "kind": "application"},
                {"name": "alpha", "root": "alpha", "kind": "application"}
            ]),
            json!([
                {"path": "alpha/main", "source_id": 1, "text": SOURCE},
                {"path": "zeta/main", "source_id": 2, "text": SOURCE}
            ]),
        )
    } else {
        (
            json!([
                {"name": "alpha", "root": "alpha", "kind": "application"},
                {"name": "zeta", "root": "zeta", "kind": "application"}
            ]),
            json!([
                {"path": "zeta/main", "source_id": 1, "text": SOURCE},
                {"path": "alpha/main", "source_id": 2, "text": SOURCE}
            ]),
        )
    };
    json!({
        "locale": locale,
        "profile": "es",
        "strictness": "strict",
        "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": packages,
            "files": files
        }
    })
}

fn analyze(reverse: bool, locale: &str) -> Result<Value, String> {
    let outcome = ApiSession::default().call("analyze_project", &request(reverse, locale));
    outcome
        .get("value")
        .cloned()
        .ok_or_else(|| format!("project analysis failed: {outcome}"))
}

fn normalize_identities(value: &mut Value, paths: &BTreeMap<u64, &str>) {
    match value {
        Value::Array(items) => {
            for value in items {
                normalize_identities(value, paths);
            }
        }
        Value::Object(object) => {
            normalize_span(object, paths);
            for value in object.values_mut() {
                normalize_identities(value, paths);
            }
        }
        _ => {}
    }
}

fn normalize_span(object: &mut Map<String, Value>, paths: &BTreeMap<u64, &str>) {
    let Some(source) = object.get_mut("source").and_then(Value::as_object_mut) else {
        return;
    };
    let Some(source_id) = source.get("source_id").and_then(Value::as_u64) else {
        return;
    };
    let Some(path) = paths.get(&source_id) else {
        return;
    };
    object.insert("source_path".to_owned(), json!(path));
    object.remove("source");
}

#[test]
fn project_diagnostics_match_after_file_and_package_permutations() -> Result<(), String> {
    let mut first = analyze(false, "es")?;
    let mut second = analyze(true, "es")?;
    normalize_identities(
        &mut first,
        &BTreeMap::from([(1, "zeta/main"), (2, "alpha/main")]),
    );
    normalize_identities(
        &mut second,
        &BTreeMap::from([(1, "alpha/main"), (2, "zeta/main")]),
    );
    assert_eq!(first, second);
    let diagnostics = first
        .get("diagnostics")
        .and_then(Value::as_array)
        .ok_or("diagnostics are absent")?;
    assert_eq!(diagnostics.len(), 2);
    let paths: Vec<&str> = diagnostics
        .iter()
        .filter(|diagnostic| {
            diagnostic.get("code").and_then(Value::as_str) == Some("unrecognizedCharacter")
        })
        .filter_map(|diagnostic| {
            diagnostic
                .get("span")
                .and_then(|span| span.get("source_path"))
                .and_then(Value::as_str)
        })
        .collect();
    assert_eq!(paths, ["alpha/main", "zeta/main"]);
    Ok(())
}

#[test]
fn project_diagnostic_order_is_independent_of_interface_locale() -> Result<(), String> {
    assert_eq!(analyze(false, "es")?, analyze(false, "en")?);
    Ok(())
}
