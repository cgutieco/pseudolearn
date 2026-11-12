use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/tipos.pseudo";

const LIBRARY: &str = "Publico Constante Limite Como Entero <- 7;\nPublico Enumerado Color\nRojo, Verde\nFinEnumerado\nPublico Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nPublico Interfaz Medible\nMetodo Medida() Como Entero;\nFinInterfaz\n";

const MAIN: &str = "Importar geo.tipos.Limite;\nImportar geo.tipos.Color;\nImportar geo.tipos.Punto;\nImportar geo.tipos.Medible;\nClase Caja Realiza Medible\nMetodo Medida() Como Entero\nRetornar Limite;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Color <- Color.Verde;\nDefinir p Como Punto <- Punto(1, 2);\nEscribir c, p.x;\nFinAlgoritmo\n";

fn rename_capabilities() -> Value {
    json!({"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}})
}

fn server_with(main: &str, library: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":rename_capabilities()}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":[
                {"path":"app/main","source_id":1,"text":main},
                {"path":"geo/tipos","source_id":2,"text":library}
            ]},
            "uris":{"app/main":APP_URI,"geo/tipos":LIBRARY_URI}
        }
    }));
    for (uri, text) in [(APP_URI, main), (LIBRARY_URI, library)] {
        server.handle_message(&json!({
            "jsonrpc":"2.0","method":"textDocument/didOpen",
            "params":{"textDocument":{"uri":uri,"languageId":"pseudolearn","version":1,"text":text}}
        }));
    }
    server
}

fn position_of(text: &str, needle: &str, occurrence: usize) -> Value {
    let offset = text
        .match_indices(needle)
        .nth(occurrence)
        .map_or(0, |(index, _)| index);
    let before = text.get(..offset).unwrap_or("");
    let line = before.matches('\n').count();
    let character = before
        .rsplit('\n')
        .next()
        .map_or(0, |last| last.chars().count());
    json!({"line":line,"character":character})
}

fn request(server: &mut LspServer, method: &str, payload: Value) -> Value {
    server
        .handle_message(&json!({"jsonrpc":"2.0","id":9,"method":method,"params":payload}))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn document_at(uri: &str, position: Value) -> Value {
    json!({"textDocument":{"uri":uri},"position":position})
}

fn with_field(mut base: Value, key: &str, value: Value) -> Value {
    if let Some(map) = base.as_object_mut() {
        map.insert(key.to_owned(), value);
    }
    base
}

fn references(server: &mut LspServer, uri: &str, position: Value) -> Vec<Value> {
    let payload = with_field(
        document_at(uri, position),
        "context",
        json!({"includeDeclaration":true}),
    );
    request(server, "textDocument/references", payload)
        .pointer("/result")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default()
}

fn rename(server: &mut LspServer, position: Value, new_name: &str) -> Value {
    let payload = with_field(document_at(APP_URI, position), "newName", json!(new_name));
    request(server, "textDocument/rename", payload)
}

fn uris_of(locations: &[Value]) -> Vec<&str> {
    locations
        .iter()
        .filter_map(|location| location.pointer("/uri").and_then(Value::as_str))
        .collect()
}

#[test]
fn definition_of_each_imported_symbol_jumps_into_the_library() {
    let mut server = server_with(MAIN, LIBRARY);
    for (needle, occurrence, expected_line) in [
        ("Limite;\nFinMetodo", 0, 0),
        ("Color <- Color.Verde", 0, 1),
        ("Punto <- Punto(1", 0, 4),
        ("Medible\nMetodo", 0, 7),
    ] {
        let answer = request(
            &mut server,
            "textDocument/definition",
            document_at(APP_URI, position_of(MAIN, needle, occurrence)),
        );
        assert_eq!(
            answer.pointer("/result/uri"),
            Some(&json!(LIBRARY_URI)),
            "{needle}"
        );
        let line = answer
            .pointer("/result/range/start/line")
            .and_then(Value::as_u64);
        assert_eq!(line, Some(expected_line), "{needle}");
    }
}

#[test]
fn references_of_each_imported_symbol_cross_files_and_include_the_import_path() {
    let mut server = server_with(MAIN, LIBRARY);
    for (needle, expected) in [
        ("Limite;\nFinMetodo", 3),
        ("Color <- Color.Verde", 4),
        ("Punto <- Punto(1", 4),
        ("Medible\nMetodo", 3),
    ] {
        let found = references(&mut server, APP_URI, position_of(MAIN, needle, 0));
        assert_eq!(found.len(), expected, "{needle}: {found:?}");
        assert!(uris_of(&found).contains(&LIBRARY_URI), "{needle}");
        assert!(uris_of(&found).contains(&APP_URI), "{needle}");
    }
}

#[test]
fn references_from_the_declaration_in_the_library_reach_the_consumer() {
    let mut server = server_with(MAIN, LIBRARY);
    let found = references(&mut server, LIBRARY_URI, position_of(LIBRARY, "Punto", 0));
    assert_eq!(found.len(), 4);
    assert!(uris_of(&found).contains(&APP_URI));
}

fn edits_of<'answer>(answer: &'answer Value, uri: &str) -> Vec<&'answer Value> {
    answer
        .pointer("/result/documentChanges")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|change| change.pointer("/textDocument/uri") == Some(&json!(uri)))
        .flat_map(|change| change.pointer("/edits").and_then(Value::as_array))
        .flatten()
        .collect()
}

#[test]
fn renaming_an_imported_record_edits_the_import_path_the_uses_and_the_declaration() {
    let mut server = server_with(MAIN, LIBRARY);
    let answer = rename(
        &mut server,
        position_of(MAIN, "Punto <- Punto(1", 0),
        "Marco",
    );
    assert_eq!(edits_of(&answer, APP_URI).len(), 3, "{answer}");
    assert_eq!(edits_of(&answer, LIBRARY_URI).len(), 1, "{answer}");
}

#[test]
fn renaming_an_imported_constant_and_enum_edits_every_file() {
    let mut server = server_with(MAIN, LIBRARY);
    let constant = rename(
        &mut server,
        position_of(MAIN, "Limite;\nFinMetodo", 0),
        "Tope",
    );
    assert_eq!(edits_of(&constant, APP_URI).len(), 2, "{constant}");
    assert_eq!(edits_of(&constant, LIBRARY_URI).len(), 1, "{constant}");
    let enumeration = rename(
        &mut server,
        position_of(MAIN, "Color <- Color.Verde", 0),
        "Paleta",
    );
    assert_eq!(edits_of(&enumeration, APP_URI).len(), 3, "{enumeration}");
    assert_eq!(
        edits_of(&enumeration, LIBRARY_URI).len(),
        1,
        "{enumeration}"
    );
}

#[test]
fn renaming_an_interface_edits_the_realization_and_the_declaration() {
    let mut server = server_with(MAIN, LIBRARY);
    let answer = rename(
        &mut server,
        position_of(MAIN, "Medible\nMetodo", 0),
        "Calculable",
    );
    assert_eq!(edits_of(&answer, APP_URI).len(), 2, "{answer}");
    assert_eq!(edits_of(&answer, LIBRARY_URI).len(), 1, "{answer}");
}

fn is_rejected(answer: &Value) -> bool {
    answer.get("error").is_some()
}

#[test]
fn renaming_onto_a_visible_declaration_or_a_reserved_word_is_rejected() {
    let mut server = server_with(MAIN, LIBRARY);
    let punto = position_of(MAIN, "Punto <- Punto(1", 0);
    assert!(is_rejected(&rename(&mut server, punto.clone(), "Color")));
    assert!(is_rejected(&rename(&mut server, punto.clone(), "Caja")));
    assert!(is_rejected(&rename(&mut server, punto.clone(), "Mientras")));
    assert!(is_rejected(&rename(&mut server, punto, "1Marco")));
    let limite = position_of(MAIN, "Limite;\nFinMetodo", 0);
    assert!(is_rejected(&rename(&mut server, limite, "Caja")));
}

#[test]
fn an_aliased_use_keeps_its_alias_when_the_symbol_is_renamed() {
    let main = "Importar geo.tipos.Punto Como P;\nAlgoritmo A\nDefinir q Como P <- P(3, 4);\nEscribir q.x;\nFinAlgoritmo\n";
    let mut server = server_with(main, LIBRARY);
    let found = references(&mut server, LIBRARY_URI, position_of(LIBRARY, "Punto", 0));
    assert_eq!(found.len(), 4, "{found:?}");
    assert_eq!(
        uris_of(&found)
            .iter()
            .filter(|uri| **uri == APP_URI)
            .count(),
        3
    );
    let payload = with_field(
        document_at(LIBRARY_URI, position_of(LIBRARY, "Punto", 0)),
        "newName",
        json!("Marco"),
    );
    let answer = request(&mut server, "textDocument/rename", payload);
    assert_eq!(edits_of(&answer, APP_URI).len(), 1, "{answer}");
    assert_eq!(edits_of(&answer, LIBRARY_URI).len(), 1, "{answer}");
}

#[test]
fn a_symbol_without_other_files_has_only_its_own_occurrences() {
    let main = "Algoritmo A\nFinAlgoritmo\n";
    let mut server = server_with(main, LIBRARY);
    let found = references(&mut server, LIBRARY_URI, position_of(LIBRARY, "Medible", 0));
    assert_eq!(found.len(), 1);
    assert_eq!(uris_of(&found), vec![LIBRARY_URI]);
}
