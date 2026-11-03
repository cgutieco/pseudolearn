use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const OPEN_FILE: &str = "Algoritmo Main\nSegun SolicitarDirectorio(\"root\") Hacer\nExito(directory):\nSegun directory.Abrir(\"a\", \"lectura\") Hacer\nExito(file): Escribir \"open\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn run(faults: Value) -> Value {
    ApiSession::default().call(
        "record",
        &json!({"request": {
            "program": OPEN_FILE,
            "profile": "es",
            "strictness": "flexible",
            "host": {"faults":faults, "files": {"a": [1]}}
        }, "options": {"capture_states": false}}),
    )
}

#[test]
fn a_directory_capability_opens_a_file_without_grants() {
    let recorded = run(json!([]));
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("open\n")),
        "{recorded}"
    );
}

#[test]
fn a_real_platform_denial_is_returned_to_the_program() {
    let recorded = run(json!([{ "operation":"request_directory", "code":"permiso_denegado" }]));
    assert_eq!(
        recorded.pointer("/value/output"),
        Some(&json!("permiso_denegado\n")),
        "{recorded}"
    );
}
