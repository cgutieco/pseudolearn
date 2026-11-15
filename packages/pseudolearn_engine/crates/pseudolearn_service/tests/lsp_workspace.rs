use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/vector.pseudo";
const MAIN: &str = "Algoritmo Main\nFinAlgoritmo\n";
const LIBRARY: &str = "Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n";

fn snapshot(uris: Value) -> Value {
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":[
                {"path":"app/main","source_id":1,"text":MAIN},
                {"path":"geo/vector","source_id":2,"text":LIBRARY}
            ]},
            "uris":uris
        }
    })
}

fn ready_server() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{}}
    }));
    server
}

fn open(server: &mut LspServer, uri: &str, version: i64) {
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":uri,"languageId":"pseudolearn","version":version,"text":MAIN}}
    }));
}

#[test]
fn a_snapshot_with_distinct_uris_is_accepted() {
    let mut server = ready_server();
    let uris = json!({"app/main":APP_URI,"geo/vector":LIBRARY_URI});
    let published = server.handle_message(&snapshot(uris));
    assert!(!published.is_empty());
}

#[test]
fn a_snapshot_mapping_two_paths_to_one_uri_is_rejected() {
    let mut server = ready_server();
    let uris = json!({"app/main":APP_URI,"geo/vector":APP_URI});
    assert!(server.handle_message(&snapshot(uris)).is_empty());
    assert!(server.workspace_session.is_none());
}

#[test]
fn a_rejected_duplicate_snapshot_keeps_the_previous_workspace() {
    let mut server = ready_server();
    server.handle_message(&snapshot(
        json!({"app/main":APP_URI,"geo/vector":LIBRARY_URI}),
    ));
    let duplicate = json!({"app/main":APP_URI,"geo/vector":APP_URI});
    assert!(server.handle_message(&snapshot(duplicate)).is_empty());
    assert!(server.workspace_session.is_some());
    assert_eq!(server.workspace_uris.len(), 2);
}

#[test]
fn a_resync_drops_state_of_documents_that_left_the_workspace() {
    let mut server = ready_server();
    server.handle_message(&snapshot(
        json!({"app/main":APP_URI,"geo/vector":LIBRARY_URI}),
    ));
    open(&mut server, APP_URI, 3);
    open(&mut server, LIBRARY_URI, 4);
    server.handle_message(&snapshot(json!({"app/main":APP_URI})));
    assert!(server.versions.contains_key(APP_URI));
    assert!(!server.versions.contains_key(LIBRARY_URI));
    assert!(server.service.session(LIBRARY_URI).is_none());
}

#[test]
fn a_resync_keeps_standalone_documents_that_were_never_in_the_workspace() {
    let mut server = ready_server();
    open(&mut server, "file:///loose.pseudo", 2);
    server.handle_message(&snapshot(
        json!({"app/main":APP_URI,"geo/vector":LIBRARY_URI}),
    ));
    assert!(server.versions.contains_key("file:///loose.pseudo"));
    assert!(server.service.session("file:///loose.pseudo").is_some());
}
