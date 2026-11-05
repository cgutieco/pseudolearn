use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn project(main: &str, library: &str) -> Value {
    json!({
        "entry": "app/main",
        "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
                {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
                {"name": "geo", "root": "geo", "kind": "library"}
            ],
            "files": [
                {"path": "app/main", "source_id": 1, "text": main},
                {"path": "geo/tipos", "source_id": 2, "text": library}
            ]
        }
    })
}

fn execute(main: &str, library: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let outcome = session.call("start_project", &project(main, library));
    let resource = outcome
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("no resource: {outcome}"))?;
    let advanced = session.call(
        "advance",
        &json!({"resource": resource, "batch_size": 4096}),
    );
    advanced
        .get("value")
        .cloned()
        .ok_or_else(|| format!("no value: {advanced}"))
}

fn output(response: &Value) -> Option<&str> {
    response.get("output").and_then(Value::as_str)
}

const LIBRARY: &str = "Publico Constante Limite Como Entero <- 7;\nPublico Enumerado Color\nRojo, Verde\nFinEnumerado\nPublico Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nPublico Interfaz Medible\nMetodo Medida() Como Entero;\nFinInterfaz\n";

#[test]
fn a_public_constant_is_imported_and_folded() -> Result<(), String> {
    let main = "Importar geo.tipos.Limite;\nAlgoritmo P\nEscribir Limite + 1;\nFinAlgoritmo\n";
    let response = execute(main, LIBRARY)?;
    assert_eq!(output(&response), Some("8\n"), "{response}");
    Ok(())
}

#[test]
fn a_public_enum_is_imported_with_its_members() -> Result<(), String> {
    let main = "Importar geo.tipos.Color;\nAlgoritmo P\nDefinir c Como Color <- Color.Verde;\nEscribir c;\nFinAlgoritmo\n";
    let response = execute(main, LIBRARY)?;
    assert_eq!(output(&response), Some("Verde\n"), "{response}");
    Ok(())
}

#[test]
fn a_public_record_is_imported_and_aliased() -> Result<(), String> {
    let main = "Importar geo.tipos.Punto Como P;\nAlgoritmo A\nDefinir q Como P <- P(3, 4);\nEscribir q.x + q.z;\nFinAlgoritmo\n";
    let response = execute(main, LIBRARY)?;
    assert_eq!(output(&response), Some("7\n"), "{response}");
    Ok(())
}

#[test]
fn a_public_interface_is_realized_by_a_consumer_class() -> Result<(), String> {
    let main = "Importar geo.tipos.Medible;\nClase Caja Realiza Medible\nMetodo Medida() Como Entero\nRetornar 5;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nEscribir c.Medida();\nFinAlgoritmo\n";
    let response = execute(main, LIBRARY)?;
    assert_eq!(output(&response), Some("5\n"), "{response}");
    Ok(())
}

#[test]
fn a_private_type_cannot_be_imported() -> Result<(), String> {
    let library = "Registro Oculto\nDefinir x Como Entero;\nFinRegistro\n";
    let main = "Importar geo.tipos.Oculto;\nAlgoritmo P\nFinAlgoritmo\n";
    match execute(main, library) {
        Err(message) => assert!(message.contains("privateImport"), "{message}"),
        Ok(response) => return Err(format!("expected a rejected import: {response}")),
    }
    Ok(())
}
