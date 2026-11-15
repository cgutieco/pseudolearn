use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const OTHER_URI: &str = "file:///app/otro.pseudo";
const LIBRARY_URI: &str = "file:///geo/tipos.pseudo";

const LIBRARY: &str = "Publico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\n";

const MAIN: &str = "Importar geo.tipos.Par;\nImportar geo.tipos.identidad;\nAlgoritmo P\nDefinir p Como Par<Entero> <- Par(1, 2);\nEscribir identidad(p.primero);\nFinAlgoritmo\n";

const OTHER: &str = "Importar geo.tipos.Par;\nPublico SubProceso crear() Como Par<Cadena>\nRetornar Par(\"ab\", \"cd\");\nFinSubProceso\n";

fn rename_capabilities() -> Value {
    json!({"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}})
}

fn server() -> LspServer {
    let (main, library, other) = (MAIN, LIBRARY, OTHER);
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
                {"path":"geo/tipos","source_id":2,"text":library},
                {"path":"app/otro","source_id":3,"text":other}
            ]},
            "uris":{"app/main":APP_URI,"geo/tipos":LIBRARY_URI,"app/otro":OTHER_URI}
        }
    }));
    for (uri, text) in [(APP_URI, main), (LIBRARY_URI, library), (OTHER_URI, other)] {
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
fn references_from_the_library_template_reach_both_consumer_modules() {
    let mut server = server();
    let found = references(&mut server, LIBRARY_URI, position_of(LIBRARY, "Par<T>", 0));
    let uris = uris_of(&found);
    assert_eq!(found.len(), 7, "{found:?}");
    assert!(uris.contains(&APP_URI) && uris.contains(&OTHER_URI));
}

#[test]
fn definition_of_an_instantiated_use_jumps_to_the_template_in_the_library() {
    let mut server = server();
    let answer = request(
        &mut server,
        "textDocument/definition",
        document_at(APP_URI, position_of(MAIN, "identidad(p", 0)),
    );
    assert_eq!(
        answer.pointer("/result/uri"),
        Some(&json!(LIBRARY_URI)),
        "{answer}"
    );
    assert_eq!(
        answer
            .pointer("/result/range/start/line")
            .and_then(Value::as_u64),
        Some(3)
    );
}

#[test]
fn renaming_the_template_edits_every_module() {
    let mut server = server();
    let answer = rename(&mut server, position_of(MAIN, "Par<Entero>", 0), "Pareja");
    assert_eq!(edits_of(&answer, APP_URI).len(), 3, "{answer}");
    assert_eq!(edits_of(&answer, OTHER_URI).len(), 3, "{answer}");
    assert_eq!(edits_of(&answer, LIBRARY_URI).len(), 1, "{answer}");
}
