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

fn workspace_message(files: Vec<Value>, uris: Value) -> Value {
    json!({
        "jsonrpc":"2.0",
        "method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":files},
            "uris":uris
        }
    })
}

fn query(
    server: &mut LspServer,
    id: u64,
    method: &str,
    uri: &str,
    line: u64,
    character: u64,
) -> Value {
    server
        .handle_message(&json!({
            "jsonrpc":"2.0","id":id,"method":method,
            "params":{"textDocument":{"uri":uri},"position":{"line":line,"character":character}}
        }))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn project_files(main: &str, library: &str) -> Vec<Value> {
    vec![
        json!({"path":"app/main","source_id":1,"text":main}),
        json!({"path":"geo/vector","source_id":2,"text":library}),
    ]
}

fn project_uris() -> Value {
    json!({"app/main":APP_URI,"geo/vector":LIBRARY_URI})
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

#[test]
fn project_definition_and_references_include_closed_source_files() {
    let mut server = initialized_server(json!({}));
    server.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    open_document(&mut server, APP_URI, 1, MAIN);
    let definition = query(&mut server, 2, "textDocument/definition", APP_URI, 2, 9);
    assert_eq!(definition.pointer("/result/uri"), Some(&json!(LIBRARY_URI)));
    let references = server
        .handle_message(&json!({
            "jsonrpc":"2.0","id":3,"method":"textDocument/references",
            "params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}
        }))
        .into_iter()
        .next()
        .unwrap_or(Value::Null);
    let locations = references.pointer("/result").and_then(Value::as_array);
    assert_eq!(locations.map(Vec::len), Some(2));
    assert!(locations.is_some_and(|items| {
        items
            .iter()
            .any(|candidate| candidate.pointer("/uri") == Some(&json!(LIBRARY_URI)))
    }));
}

#[test]
fn body_edit_queries_and_rename_edits_match_a_cold_workspace() {
    let body = LIBRARY.replace("value * 2", "value * 3");
    let mut incremental = initialized_server(rename_capabilities());
    incremental.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    open_document(&mut incremental, APP_URI, 1, MAIN);
    open_document(&mut incremental, LIBRARY_URI, 1, LIBRARY);
    incremental.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didChange",
        "params":{"textDocument":{"uri":LIBRARY_URI,"version":2},"contentChanges":[{"text":body}]}
    }));
    let mut cold = initialized_server(rename_capabilities());
    cold.handle_message(&workspace_message(
        project_files(MAIN, &body),
        project_uris(),
    ));
    open_document(&mut cold, APP_URI, 1, MAIN);
    open_document(&mut cold, LIBRARY_URI, 2, &body);
    assert!(
        incremental
            .workspace_session
            .as_ref()
            .is_some_and(|value| value.matches_cold_analysis())
    );
    for message in query_messages() {
        let expected = cold
            .handle_message(&message)
            .into_iter()
            .next()
            .unwrap_or(Value::Null);
        let actual = incremental
            .handle_message(&message)
            .into_iter()
            .next()
            .unwrap_or(Value::Null);
        assert_eq!(actual, expected);
    }
}

fn query_messages() -> [Value; 3] {
    [
        json!({"jsonrpc":"2.0","id":30,"method":"workspace/symbol","params":{"query":"Double"}}),
        json!({"jsonrpc":"2.0","id":31,"method":"textDocument/references","params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}}),
        json!({"jsonrpc":"2.0","id":32,"method":"textDocument/rename","params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"newName":"Twice"}}),
    ]
}

#[test]
fn project_navigation_maps_utf16_positions_and_nfc_identifiers() {
    let source = "Importar geo.vector.Double;\nAlgoritmo Main\nDefinir café Como Entero <- 1;\nEscribir \"😀\", café;\nFinAlgoritmo\n";
    let mut server = initialized_server(json!({}));
    server.handle_message(&workspace_message(
        project_files(source, LIBRARY),
        project_uris(),
    ));
    open_document(&mut server, APP_URI, 1, source);
    let line_prefix = "Escribir \"😀\", ";
    let character = u64::try_from(line_prefix.encode_utf16().count()).unwrap_or(u64::MAX);
    let definition = query(
        &mut server,
        2,
        "textDocument/definition",
        APP_URI,
        3,
        character,
    );
    assert_eq!(definition.pointer("/result/uri"), Some(&json!(APP_URI)));
    assert_eq!(
        definition.pointer("/result/range/start/character"),
        Some(&json!(8))
    );
    assert_eq!(
        definition.pointer("/result/range/end/character"),
        Some(&json!(12))
    );
}

#[test]
fn project_overlay_changes_feed_incremental_queries_and_close_restores_snapshot() {
    let mut server = initialized_server(json!({}));
    server.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    open_document(&mut server, APP_URI, 1, MAIN);
    let semantic = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/semanticTokens/full",
        "params":{"textDocument":{"uri":APP_URI}}
    }));
    assert!(
        semantic
            .first()
            .and_then(|answer| answer.pointer("/result/data"))
            .is_some()
    );
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didChange",
        "params":{"textDocument":{"uri":APP_URI,"version":2},"contentChanges":[{"text":"@"}]}
    }));
    let changed = server
        .service
        .session(APP_URI)
        .map(|session| session.text());
    assert_eq!(changed, Some("@"));
    assert!(
        server
            .workspace_session
            .as_ref()
            .is_some_and(|workspace| !workspace.result().diagnostics.is_empty())
    );
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didClose",
        "params":{"textDocument":{"uri":APP_URI}}
    }));
    assert!(server.service.session(APP_URI).is_none());
    assert!(
        server
            .workspace_session
            .as_ref()
            .is_some_and(|workspace| workspace.result().diagnostics.is_empty())
    );
}

#[test]
fn semantic_tokens_use_utf16_lengths_and_require_negotiation() {
    let text = "algorithm Main\nwrite \"😀\";\nendAlgorithm\n";
    let mut server =
        initialized_server(json!({"textDocument":{"semanticTokens":{"requests":{"full":true}}}}));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":"file:///unicode.pseudo","languageId":"pseudolearn","version":1,"text":text}}
    }));
    let answer = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/semanticTokens/full",
        "params":{"textDocument":{"uri":"file:///unicode.pseudo"}}
    }));
    let encoded_tokens = answer
        .first()
        .and_then(|candidate| candidate.pointer("/result/data"))
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    assert_eq!(encoded_tokens.len() % 5, 0);
    assert!(encoded_tokens.chunks(5).any(|token| {
        token.get(2).and_then(Value::as_u64) == Some(4)
            && token.get(3).and_then(Value::as_u64) == Some(3)
    }));
    assert!(
        encoded_tokens
            .chunks(5)
            .any(|token| { token.get(1).and_then(Value::as_u64) == Some(6) })
    );

    let mut unsupported = LspServer::new();
    let initialize = unsupported.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"initialize","params":{"capabilities":{}}
    }));
    assert!(
        initialize
            .first()
            .and_then(|candidate| candidate.pointer("/result/capabilities/semanticTokensProvider"))
            .is_none()
    );
}
