use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";
const MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n";

fn project(files: Value) -> Value {
    json!({
        "project_id": "1",
        "revision_id": "1",
        "packages": [
            {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
            {"name": "geo", "root": "geo", "kind": "library"}
        ],
        "files": files
    })
}

fn default_files() -> Value {
    json!([
        {"path": "app/main", "source_id": 1, "text": MAIN},
        {"path": "geo/vectores", "source_id": 2, "text": LIBRARY}
    ])
}

fn call(operation: &str, arguments: Value) -> Value {
    ApiSession::default().call(operation, &arguments)
}

fn value(outcome: &Value) -> Result<&Value, String> {
    outcome
        .get("value")
        .ok_or_else(|| format!("no value: {outcome}"))
}

#[test]
fn execute_project_runs_the_selected_entry() -> Result<(), String> {
    let outcome = call(
        "execute_project",
        json!({"project": project(default_files()), "entry": "app/main"}),
    );
    let result = value(&outcome)?;
    assert_eq!(result.get("output"), Some(&json!("42\n")));
    assert_eq!(result.get("project_errors"), Some(&json!([])));
    Ok(())
}

#[test]
fn analyze_project_lists_modules_ordered_by_path() -> Result<(), String> {
    let files = json!([
        {"path": "geo/vectores", "source_id": 2, "text": LIBRARY},
        {"path": "app/main", "source_id": 1, "text": MAIN}
    ]);
    let outcome = call("analyze_project", json!({"project": project(files)}));
    let result = value(&outcome)?;
    assert_eq!(
        result.get("modules"),
        Some(&json!([
            {"path": "app/main", "package": "app", "module": "main"},
            {"path": "geo/vectores", "package": "geo", "module": "vectores"}
        ]))
    );
    assert_eq!(result.get("diagnostics"), Some(&json!([])));
    Ok(())
}

#[test]
fn diagnostics_carry_the_identity_of_their_own_file() -> Result<(), String> {
    let files = json!([
        {"path": "app/main", "source_id": 1, "text": "Importar geo.nada.Doble;\nAlgoritmo P\nFinAlgoritmo\n"},
        {"path": "geo/vectores", "source_id": 2, "text": "Publico SubProceso f(\nFinSubProceso\n"}
    ]);
    let outcome = call(
        "analyze_project",
        json!({"project": project(files), "entry": "app/main"}),
    );
    let diagnostics = value(&outcome)?
        .get("diagnostics")
        .and_then(Value::as_array)
        .ok_or("no diagnostics")?;
    assert!(!diagnostics.is_empty());
    for diagnostic in diagnostics {
        let source = diagnostic
            .pointer("/span/source/source_id")
            .and_then(Value::as_u64);
        assert!(matches!(source, Some(1 | 2)));
        assert_eq!(
            diagnostic.pointer("/span/source/project_id"),
            Some(&json!("1"))
        );
    }
    Ok(())
}

#[test]
fn execute_project_with_diagnostics_does_not_run() -> Result<(), String> {
    let files = json!([
        {"path": "app/main", "source_id": 1, "text": "Importar geo.nada.Doble;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"},
        {"path": "geo/vectores", "source_id": 2, "text": LIBRARY}
    ]);
    let outcome = call(
        "execute_project",
        json!({"project": project(files), "entry": "app/main"}),
    );
    let result = value(&outcome)?;
    assert!(result.get("output").is_none());
    assert_eq!(
        result.pointer("/diagnostics/0/code"),
        Some(&json!("unresolvedModule"))
    );
    Ok(())
}

#[test]
fn execute_project_without_entry_reports_a_project_error() -> Result<(), String> {
    let outcome = call(
        "execute_project",
        json!({"project": project(default_files())}),
    );
    assert_eq!(
        value(&outcome)?.get("project_errors"),
        Some(&json!([{"code": "entryNotSelected"}]))
    );
    Ok(())
}

#[test]
fn malformed_requests_are_usage_failures() {
    let duplicate = json!([
        {"path": "app/main", "source_id": 1, "text": MAIN},
        {"path": "geo/vectores", "source_id": 1, "text": LIBRARY}
    ]);
    let invalid_kind = json!({
        "project_id": "1", "revision_id": "1",
        "packages": [{"name": "app", "root": "app", "kind": "binary"}],
        "files": []
    });
    let bad_identifier = json!({
        "project_id": "01", "revision_id": "1", "packages": [], "files": []
    });
    for arguments in [
        json!({"project": project(duplicate)}),
        json!({"project": invalid_kind}),
        json!({"project": bad_identifier}),
        json!({}),
    ] {
        let outcome = call("analyze_project", arguments);
        assert_eq!(
            outcome.pointer("/failure/family"),
            Some(&json!("usage")),
            "{outcome}"
        );
    }
}

#[test]
fn flexible_strictness_accepts_missing_terminators() -> Result<(), String> {
    let files = json!([
        {"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 7\nFinAlgoritmo\n"},
        {"path": "geo/vectores", "source_id": 2, "text": LIBRARY}
    ]);
    let outcome = call(
        "execute_project",
        json!({"project": project(files), "entry": "app/main", "strictness": "flexible"}),
    );
    assert_eq!(value(&outcome)?.get("output"), Some(&json!("7\n")));
    Ok(())
}

#[test]
fn import_cycle_relates_a_span_in_the_other_file() -> Result<(), String> {
    let files = json!([
        {"path": "app/main", "source_id": 1, "text": "Algoritmo P\nFinAlgoritmo\n"},
        {"path": "geo/a", "source_id": 2, "text": "Importar geo.b;\n"},
        {"path": "geo/b", "source_id": 3, "text": "\n\nImportar geo.a;\n"}
    ]);
    let outcome = call("analyze_project", json!({"project": project(files)}));
    let diagnostics = value(&outcome)?
        .get("diagnostics")
        .and_then(Value::as_array)
        .ok_or("no diagnostics")?;
    let cycle = diagnostics.first().ok_or("no cycle")?;
    assert_eq!(cycle.get("code"), Some(&json!("importCycle")));
    assert_eq!(cycle.pointer("/span/source/source_id"), Some(&json!(2)));
    assert_eq!(
        cycle.pointer("/related/0/source/source_id"),
        Some(&json!(3))
    );
    assert_eq!(cycle.pointer("/related/0/start/line"), Some(&json!(3)));
    Ok(())
}

#[test]
fn package_cycle_is_reported_with_its_chain() -> Result<(), String> {
    let mut cyclic = project(default_files());
    if let Some(package) = cyclic
        .pointer_mut("/packages/1")
        .and_then(Value::as_object_mut)
    {
        package.insert("dependencies".to_owned(), json!({"app": "app"}));
    }
    let outcome = call("analyze_project", json!({"project": cyclic}));
    let errors = value(&outcome)?.get("project_errors");
    assert_eq!(
        errors,
        Some(&json!([
            {"code": "packageCycle", "path": "app", "chain": ["app", "geo", "app"]}
        ]))
    );
    Ok(())
}
