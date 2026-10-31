use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/vector.pseudo";
const MAIN: &str =
    "Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n";
const LIBRARY: &str = "Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n";

fn initialized_server(capabilities: Value) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":capabilities}
    }));
    server
}

fn workspace_message(main: &str, library: &str) -> Value {
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":[
                {"path":"app/main","source_id":1,"text":main},
                {"path":"geo/vector","source_id":2,"text":library}
            ]},
            "uris":{"app/main":APP_URI,"geo/vector":LIBRARY_URI}
        }
    })
}

fn open_document(server: &mut LspServer, uri: &str, version: i64, text: &str) {
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":uri,"languageId":"pseudolearn","version":version,"text":text}}
    }));
}

fn rename_capabilities() -> Value {
    json!({"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}})
}

fn rename(server: &mut LspServer, id: u64, new_name: &str) -> Vec<Value> {
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":id,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"newName":new_name}
    }))
}

fn has_error(response: &[Value]) -> bool {
    response
        .first()
        .is_some_and(|answer| answer.get("error").is_some())
}

#[test]
fn project_rename_requires_transactional_client_support() {
    let mut unsupported = LspServer::new();
    let initialize = unsupported.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}
    }));
    assert!(initialize.first().is_some_and(|answer| {
        answer
            .pointer("/result/capabilities/renameProvider")
            .is_none()
    }));
    let prepare = unsupported.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/prepareRename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":0,"character":0}}
    }));
    assert!(has_error(&prepare));
}

#[test]
fn project_rename_returns_versions_for_every_affected_document() {
    let mut server = initialized_server(rename_capabilities());
    server.handle_message(&workspace_message(MAIN, LIBRARY));
    open_document(&mut server, APP_URI, 2, MAIN);
    open_document(&mut server, LIBRARY_URI, 5, LIBRARY);
    let response = rename(&mut server, 3, "Twice");
    let changes = response
        .first()
        .and_then(|answer| answer.pointer("/result/documentChanges"))
        .and_then(Value::as_array);
    assert_eq!(changes.map(Vec::len), Some(2));
    assert!(changes.is_some_and(|items| has_document_version(items, APP_URI, 2)));
    assert!(changes.is_some_and(|items| has_document_version(items, LIBRARY_URI, 5)));
}

fn has_document_version(changes: &[Value], uri: &str, version: i64) -> bool {
    changes.iter().any(|change| {
        change.pointer("/textDocument/uri") == Some(&json!(uri))
            && change.pointer("/textDocument/version") == Some(&json!(version))
    })
}

#[test]
fn project_rename_rejects_collisions_reserved_names_and_closed_dependents() {
    let main = "Algoritmo Main\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable other Como Entero <- 1;\nDefinir Mutable súma Como Entero <- 2;\nFinAlgoritmo\n";
    let mut server = initialized_server(rename_capabilities());
    server.handle_message(&workspace_message(main, LIBRARY));
    open_document(&mut server, APP_URI, 4, main);
    assert!(has_error(&rename_at(&mut server, 1, 1, 16, "other")));
    assert!(has_error(&rename_at(&mut server, 2, 1, 16, "súma")));
    assert!(has_error(&rename_at(&mut server, 3, 1, 16, "Mientras")));
    let mut closed = initialized_server(rename_capabilities());
    closed.handle_message(&workspace_message(MAIN, LIBRARY));
    open_document(&mut closed, APP_URI, 1, MAIN);
    assert!(has_error(&rename(&mut closed, 4, "Twice")));
}

fn rename_at(server: &mut LspServer, id: u64, line: u64, character: u64, name: &str) -> Vec<Value> {
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":id,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":line,"character":character},"newName":name}
    }))
}
