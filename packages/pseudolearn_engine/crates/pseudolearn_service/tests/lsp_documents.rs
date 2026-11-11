use pseudolearn_lexicon::Profile;
use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///documents.pseudo";
const FIRST: &str = "Algoritmo First\nFinAlgoritmo\n";
const SECOND: &str = "Algoritmo Second\nFinAlgoritmo\n";

fn ready_server() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{}}
    }));
    server
}

fn open(server: &mut LspServer, version: i64, text: &str) {
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":version,"text":text}}
    }));
}

fn first_symbol(server: &mut LspServer) -> Option<String> {
    let answer = server.handle_message(&json!({
        "jsonrpc":"2.0","id":3,"method":"textDocument/documentSymbol",
        "params":{"textDocument":{"uri":URI}}
    }));
    answer
        .first()?
        .pointer("/result/0/name")
        .and_then(Value::as_str)
        .map(str::to_owned)
}

#[test]
fn opening_a_document_registers_its_version() {
    let mut server = ready_server();
    open(&mut server, 4, FIRST);
    assert_eq!(server.versions.get(URI), Some(&4));
    assert_eq!(first_symbol(&mut server).as_deref(), Some("First"));
}

#[test]
fn a_negative_version_is_rejected_for_standalone_documents() {
    let mut server = ready_server();
    open(&mut server, -1, FIRST);
    assert!(server.versions.is_empty());
    assert!(server.service.session(URI).is_none());
}

#[test]
fn a_zero_version_is_accepted() {
    let mut server = ready_server();
    open(&mut server, 0, FIRST);
    assert_eq!(server.versions.get(URI), Some(&0));
}

#[test]
fn reopening_with_a_stale_or_equal_version_is_ignored() {
    let mut server = ready_server();
    open(&mut server, 5, FIRST);
    open(&mut server, 5, SECOND);
    open(&mut server, 2, SECOND);
    assert_eq!(server.versions.get(URI), Some(&5));
    assert_eq!(first_symbol(&mut server).as_deref(), Some("First"));
}

#[test]
fn reopening_with_a_newer_version_replaces_the_document() {
    let mut server = ready_server();
    open(&mut server, 5, FIRST);
    open(&mut server, 6, SECOND);
    assert_eq!(first_symbol(&mut server).as_deref(), Some("Second"));
}

#[test]
fn reopening_after_close_accepts_any_non_negative_version() {
    let mut server = ready_server();
    open(&mut server, 9, FIRST);
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didClose",
        "params":{"textDocument":{"uri":URI}}
    }));
    open(&mut server, 1, SECOND);
    assert_eq!(server.versions.get(URI), Some(&1));
    assert_eq!(first_symbol(&mut server).as_deref(), Some("Second"));
}

fn replace(server: &mut LspServer, version: i64, text: &str) {
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didChange",
        "params":{"textDocument":{"uri":URI,"version":version},"contentChanges":[{"text":text}]}
    }));
}

fn session_profile(server: &LspServer) -> Option<Profile> {
    server.service.session(URI).map(|session| session.profile)
}

#[test]
fn an_empty_document_adopts_the_vocabulary_typed_into_it() {
    let mut server = ready_server();
    open(&mut server, 1, "");
    assert_eq!(session_profile(&server), Some(Profile::Spanish));
    replace(&mut server, 2, "Algorithm Main\nEndAlgorithm\n");
    assert_eq!(session_profile(&server), Some(Profile::English));
}

#[test]
fn removing_the_opener_keeps_the_detected_profile() {
    let mut server = ready_server();
    open(&mut server, 1, "Algoritmo Principal\nFinAlgoritmo\n");
    replace(&mut server, 2, "  \n// pendiente\n");
    assert_eq!(session_profile(&server), Some(Profile::Spanish));
}

#[test]
fn an_edit_within_the_same_vocabulary_keeps_the_profile_and_text() {
    let mut server = ready_server();
    open(&mut server, 1, "Algoritmo Principal\nFinAlgoritmo\n");
    replace(&mut server, 2, "Algoritmo Otro\nFinAlgoritmo\n");
    assert_eq!(session_profile(&server), Some(Profile::Spanish));
    let text = server
        .service
        .session(URI)
        .map(|session| session.text().to_owned());
    assert_eq!(text.as_deref(), Some("Algoritmo Otro\nFinAlgoritmo\n"));
}

#[test]
fn a_stale_change_does_not_switch_the_profile() {
    let mut server = ready_server();
    open(&mut server, 1, "Algoritmo Principal\nFinAlgoritmo\n");
    replace(&mut server, 1, "Algorithm Main\nEndAlgorithm\n");
    assert_eq!(session_profile(&server), Some(Profile::Spanish));
}

fn server_with(initialize_parameters: Value) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":initialize_parameters
    }));
    server
}

#[test]
fn an_empty_document_falls_back_to_the_configured_profile_not_the_interface_locale() {
    let mut server = server_with(json!({
        "locale":"es","capabilities":{},"initializationOptions":{"profile":"en"}
    }));
    open(&mut server, 1, "");
    assert_eq!(session_profile(&server), Some(Profile::English));
}

#[test]
fn without_a_configured_profile_an_empty_document_falls_back_to_spanish() {
    let mut server = server_with(json!({"locale":"en","capabilities":{}}));
    open(&mut server, 1, "");
    assert_eq!(session_profile(&server), Some(Profile::Spanish));
}

#[test]
fn a_profile_changed_by_configuration_applies_to_documents_opened_later() {
    let mut server = server_with(json!({"locale":"es","capabilities":{}}));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"workspace/didChangeConfiguration",
        "params":{"settings":{"pseudolearn":{"profile":"en"}}}
    }));
    open(&mut server, 1, "// pending\n");
    assert_eq!(session_profile(&server), Some(Profile::English));
}
