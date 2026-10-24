#![cfg(feature = "native")]

use pseudolearn_api::{
    ExecutionLimits, NativeBuildFailure, NativeBuildRequest, build_native_project_object,
};
use serde_json::{Value, json};

const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";
const MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n";

fn request() -> NativeBuildRequest {
    NativeBuildRequest {
        program: String::new(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        seed: 42,
        forced_collection: false,
        limits: ExecutionLimits::default(),
        source_name: "project".to_owned(),
        source: None,
        locale: "es".to_owned(),
        error_template: "{path}\n".to_owned(),
        warning_template: "{path}\n".to_owned(),
        information_template: "{path}\n".to_owned(),
        exhausted_template: "{path}\n".to_owned(),
    }
}

fn arguments(main: &str, entry: &str) -> Value {
    json!({
        "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
                {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
                {"name": "geo", "root": "geo", "kind": "library"}
            ],
            "files": [
                {"path": "app/main", "source_id": 1, "text": main},
                {"path": "geo/vectores", "source_id": 2, "text": LIBRARY}
            ]
        },
        "entry": entry
    })
}

fn contains(haystack: &[u8], needle: &[u8]) -> bool {
    haystack
        .windows(needle.len())
        .any(|window| window == needle)
}

#[test]
fn a_valid_project_becomes_one_object_with_the_runtime_main() -> Result<(), String> {
    let object = build_native_project_object(&arguments(MAIN, "app/main"), &request(), &[])
        .map_err(|error| format!("{error:?}"))?;
    assert!(contains(&object.bytes, b"pseudolearn_aot_main"));
    assert!(object.warnings.is_empty());
    Ok(())
}

#[test]
fn an_unknown_entry_is_a_project_rejection_without_an_object() -> Result<(), String> {
    match build_native_project_object(&arguments(MAIN, "app/missing"), &request(), &[]) {
        Err(NativeBuildFailure::ProjectRejected(failure)) => {
            assert_eq!(failure.get("diagnostics"), Some(&json!([])));
            assert_eq!(
                failure.pointer("/project_errors/0/code"),
                Some(&json!("entryNotFound"))
            );
            Ok(())
        }
        other => Err(format!("{other:?}")),
    }
}

#[test]
fn a_semantic_error_keeps_its_real_source_identity() -> Result<(), String> {
    let broken = "Algoritmo P\nEscribir sinDeclarar;\nFinAlgoritmo\n";
    match build_native_project_object(&arguments(broken, "app/main"), &request(), &[]) {
        Err(NativeBuildFailure::ProjectRejected(failure)) => {
            assert_eq!(
                failure.pointer("/diagnostics/0/span/source/source_id"),
                Some(&json!(1))
            );
            Ok(())
        }
        other => Err(format!("{other:?}")),
    }
}
