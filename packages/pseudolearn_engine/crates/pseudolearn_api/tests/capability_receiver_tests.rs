use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const OPEN_FILE: &str = "Algoritmo Main\nSegun SolicitarDirectorio(\"root\") Hacer\nExito(directory):\nSegun directory.Abrir(\"a\", \"lectura\") Hacer\nExito(file): Escribir \"open\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn run(permissions: Value) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": {
            "program": OPEN_FILE,
            "profile": "es",
            "strictness": "flexible",
            "host": {"permissions": permissions, "requested_permissions": permissions, "files": {"a": [1]}}
        }, "options": {"capture_states": false}}),
    )
}

#[test]
fn a_granted_directory_capability_opens_a_file() {
    let recorded = run(json!(["archivos_lectura"]));
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("open\n")),
        "{recorded}"
    );
}

#[test]
fn a_missing_file_permission_denies_the_directory_request() {
    let recorded = run(json!([]));
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("permiso_denegado\n")),
        "{recorded}"
    );
}
