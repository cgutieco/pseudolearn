use pseudolearn_service::{LspServer, RequestCancellation};
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

fn cycle_workspace_message() -> Value {
    json!({
        "jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot",
        "params":{
            "project":{"project_id":7,"revision_id":1,"packages":[
                {"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},
                {"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}
            ],"files":[
                {"path":"app/main","source_id":1,"text":"Importar geo.a;\nAlgoritmo Main\nFinAlgoritmo\n"},
                {"path":"geo/a","source_id":2,"text":"Importar geo.b;\n"},
                {"path":"geo/b","source_id":3,"text":"Importar geo.a;\n"}
            ]},
            "uris":{"app/main":APP_URI,"geo/a":"file:///geo/a.pseudo","geo/b":"file:///geo/b.pseudo"}
        }
    })
}

fn cycle_diagnostic(notifications: &[Value]) -> Option<&Value> {
    notifications
        .iter()
        .filter_map(|notification| {
            notification
                .pointer("/params/diagnostics")
                .and_then(Value::as_array)
        })
        .flatten()
        .find(|diagnostic| diagnostic.get("code") == Some(&json!("importCycle")))
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
fn workspace_symbols_use_short_names_and_point_to_closed_definitions() {
    let mut server = initialized_server(json!({}));
    server.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    let symbols = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"workspace/symbol",
        "params":{"query":"Double"}
    }));
    let rows = symbols
        .first()
        .and_then(|answer| answer.pointer("/result"))
        .and_then(Value::as_array);
    let symbol = rows.and_then(|items| {
        items
            .iter()
            .find(|candidate| candidate.get("name") == Some(&json!("Double")))
    });
    assert_eq!(
        symbol.and_then(|candidate| candidate.pointer("/location/uri")),
        Some(&json!(LIBRARY_URI))
    );
}

#[test]
fn project_diagnostics_include_related_locations_only_when_negotiated() {
    let cycle = cycle_workspace_message();
    let mut supported = initialized_server(json!({
        "textDocument":{"publishDiagnostics":{"relatedInformation":true}}
    }));
    let supported_notifications = supported.handle_message(&cycle);
    let related = cycle_diagnostic(&supported_notifications)
        .and_then(|diagnostic| diagnostic.pointer("/relatedInformation"))
        .and_then(Value::as_array);
    assert!(related.is_some_and(|items| {
        items.iter().any(|candidate| {
            candidate.pointer("/location/uri") == Some(&json!("file:///geo/b.pseudo"))
        })
    }));

    let mut unsupported = initialized_server(json!({}));
    let unsupported_notifications = unsupported.handle_message(&cycle);
    assert!(
        cycle_diagnostic(&unsupported_notifications)
            .is_some_and(|diagnostic| diagnostic.get("relatedInformation").is_none())
    );
}

#[test]
fn project_requests_observe_cooperative_cancellation() {
    let mut server = initialized_server(json!({}));
    server.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    let cancellation = RequestCancellation::new();
    cancellation.cancel();
    let response = server.handle_cancellable_message(
        &json!({"jsonrpc":"2.0","id":2,"method":"workspace/symbol","params":{"query":""}}),
        cancellation,
    );
    assert_eq!(
        response
            .first()
            .and_then(|candidate| candidate.pointer("/error/code")),
        Some(&json!(-32800))
    );
}

#[test]
fn project_rename_requires_transactional_client_support_and_open_versions() {
    let mut unsupported = LspServer::new();
    let initialize = unsupported.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}
    }));
    assert!(
        initialize
            .first()
            .and_then(|candidate| candidate.pointer("/result/capabilities/renameProvider"))
            .is_none()
    );
    let prepare = unsupported.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/prepareRename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":0,"character":0}}
    }));
    assert!(
        prepare
            .first()
            .and_then(|candidate| candidate.get("error"))
            .is_some()
    );

    let mut server = initialized_server(rename_capabilities());
    server.handle_message(&workspace_message(
        project_files(MAIN, LIBRARY),
        project_uris(),
    ));
    open_document(&mut server, APP_URI, 2, MAIN);
    open_document(&mut server, LIBRARY_URI, 5, LIBRARY);
    let rename = server.handle_message(&json!({
        "jsonrpc":"2.0","id":3,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"newName":"Twice"}
    }));
    let changes = rename
        .first()
        .and_then(|answer| answer.pointer("/result/documentChanges"))
        .and_then(Value::as_array);
    assert_eq!(changes.map(Vec::len), Some(2));
    assert!(changes.is_some_and(|items| items.iter().any(|candidate| {
        candidate.pointer("/textDocument/uri") == Some(&json!(APP_URI))
            && candidate.pointer("/textDocument/version") == Some(&json!(2))
    })));
    assert!(changes.is_some_and(|items| items.iter().any(|candidate| {
        candidate.pointer("/textDocument/uri") == Some(&json!(LIBRARY_URI))
            && candidate.pointer("/textDocument/version") == Some(&json!(5))
    })));
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
fn rename_returns_versioned_edits_and_rejects_collisions_and_closed_files() {
    let main = "Algoritmo Main\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable other Como Entero <- 1;\nDefinir Mutable súma Como Entero <- 2;\nEscribir total, other;\nFinAlgoritmo\n";
    let mut server = initialized_server(rename_capabilities());
    server.handle_message(&workspace_message(
        project_files(main, LIBRARY),
        project_uris(),
    ));
    open_document(&mut server, APP_URI, 4, main);
    let prepared = query(&mut server, 2, "textDocument/prepareRename", APP_URI, 1, 16);
    assert_eq!(
        prepared.pointer("/result/placeholder"),
        Some(&json!("total"))
    );
    let renamed = server.handle_message(&json!({
        "jsonrpc":"2.0","id":3,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":1,"character":16},"newName":"sum"}
    }));
    let edits = renamed
        .first()
        .and_then(|answer| answer.pointer("/result/documentChanges/0"));
    assert_eq!(
        edits.and_then(|value| value.pointer("/textDocument/version")),
        Some(&json!(4))
    );
    assert_eq!(
        edits
            .and_then(|value| value.pointer("/edits"))
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(2)
    );
    let collision = server.handle_message(&json!({
        "jsonrpc":"2.0","id":4,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":1,"character":16},"newName":"other"}
    }));
    assert!(
        collision
            .first()
            .and_then(|answer| answer.get("error"))
            .is_some()
    );
    let normalized_collision = server.handle_message(&json!({
        "jsonrpc":"2.0","id":7,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":1,"character":16},"newName":"súma"}
    }));
    assert!(
        normalized_collision
            .first()
            .and_then(|answer| answer.get("error"))
            .is_some()
    );
    let reserved = server.handle_message(&json!({
        "jsonrpc":"2.0","id":5,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":1,"character":16},"newName":"Mientras"}
    }));
    assert!(
        reserved
            .first()
            .and_then(|answer| answer.get("error"))
            .is_some()
    );

    let main_with_import = MAIN;
    let mut closed = initialized_server(rename_capabilities());
    closed.handle_message(&workspace_message(
        project_files(main_with_import, LIBRARY),
        project_uris(),
    ));
    open_document(&mut closed, APP_URI, 1, main_with_import);
    let stale = closed.handle_message(&json!({
        "jsonrpc":"2.0","id":6,"method":"textDocument/rename",
        "params":{"textDocument":{"uri":APP_URI},"position":{"line":2,"character":9},"newName":"Twice"}
    }));
    assert!(
        stale
            .first()
            .and_then(|answer| answer.get("error"))
            .is_some()
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
