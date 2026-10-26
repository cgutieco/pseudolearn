use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///prueba.pseudo";

fn initialize(server: &mut LspServer, locale: &str) -> Vec<Value> {
    server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "locale": locale }
    }))
}

fn open(server: &mut LspServer, text: &str) -> Vec<Value> {
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": { "textDocument": { "uri": URI, "languageId": "pseudolearn", "version": 1, "text": text } }
    }))
}

fn request(server: &mut LspServer, id: u64, method: &str, parameters: Value) -> Value {
    server
        .handle_message(
            &json!({ "jsonrpc": "2.0", "id": id, "method": method, "params": parameters }),
        )
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn cursor_at(line: u32, character: u32) -> Value {
    json!({ "textDocument": { "uri": URI }, "position": { "line": line, "character": character } })
}

fn ready_server(text: &str) -> LspServer {
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    open(&mut server, text);
    server
}

const PROGRAM: &str = "Algoritmo Principal\n  Definir Mutable total Como Entero <- 0;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n";

#[test]
fn announces_every_capability_and_shuts_down_cleanly() {
    let mut server = LspServer::new();
    let answers = initialize(&mut server, "es");
    let capabilities = answers
        .first()
        .and_then(|answer| answer.pointer("/result/capabilities"))
        .cloned()
        .unwrap_or(Value::Null);
    for name in [
        "textDocumentSync",
        "completionProvider",
        "hoverProvider",
        "signatureHelpProvider",
        "definitionProvider",
        "referencesProvider",
        "documentHighlightProvider",
        "documentSymbolProvider",
        "documentFormattingProvider",
    ] {
        assert!(capabilities.get(name).is_some(), "{name}");
    }
    assert_eq!(
        capabilities.pointer("/textDocumentSync/change"),
        Some(&json!(2))
    );
    assert_eq!(
        capabilities.pointer("/completionProvider/resolveProvider"),
        Some(&json!(false))
    );
    server.handle_message(&json!({"jsonrpc":"2.0","method":"initialized","params":{}}));
    let shutdown = request(&mut server, 2, "shutdown", Value::Null);
    assert_eq!(shutdown.get("result"), Some(&Value::Null));
    server.handle_message(&json!({"jsonrpc":"2.0","method":"exit"}));
    assert!(server.is_finished());
    assert_eq!(server.exit_code, Some(0));
}

#[test]
fn exit_without_shutdown_reports_failure() {
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    server.handle_message(&json!({"jsonrpc":"2.0","method":"exit"}));
    assert_eq!(server.exit_code, Some(1));
}

#[test]
fn rejects_requests_before_initialize_and_after_shutdown() {
    let mut server = LspServer::new();
    let early = request(&mut server, 1, "textDocument/hover", cursor_at(0, 0));
    assert_eq!(early.pointer("/error/code"), Some(&json!(-32002)));
    initialize(&mut server, "es");
    request(&mut server, 2, "shutdown", Value::Null);
    let late = request(&mut server, 3, "textDocument/hover", cursor_at(0, 0));
    assert_eq!(late.pointer("/error/code"), Some(&json!(-32600)));
}

#[test]
fn unknown_requests_fail_and_unknown_notifications_are_ignored() {
    let mut server = ready_server(PROGRAM);
    let unknown = request(&mut server, 9, "workspace/unknown", json!({}));
    assert_eq!(unknown.pointer("/error/code"), Some(&json!(-32601)));
    let ignored =
        server.handle_message(&json!({"jsonrpc":"2.0","method":"$/cancelRequest","params":{}}));
    assert!(ignored.is_empty());
}

#[test]
fn publishes_localized_diagnostics_with_zero_based_ranges() {
    let wrong = "Algoritmo Principal\n  Definir Mutable x Como Entero <- 0;\n  x <- \"error\";\nFinAlgoritmo\n";
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    let published = open(&mut server, wrong);
    let first = published
        .first()
        .and_then(|note| note.pointer("/params/diagnostics/0"))
        .cloned()
        .unwrap_or(Value::Null);
    assert_eq!(first.pointer("/range/start/line"), Some(&json!(2)));
    assert_eq!(first.get("severity"), Some(&json!(1)));
    assert_eq!(first.get("source"), Some(&json!("pseudolearn")));
    let spanish_message = first
        .get("message")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned();
    assert!(!spanish_message.is_empty());

    let mut english = LspServer::new();
    initialize(&mut english, "en");
    let published = open(&mut english, wrong);
    let message = published
        .first()
        .and_then(|note| note.pointer("/params/diagnostics/0/message"))
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned();
    assert_ne!(message, spanish_message);
}

#[test]
fn reports_syntax_errors_and_clears_them_when_fixed() {
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    let published = open(&mut server, "Algoritmo Principal\n  Si x >\nFinAlgoritmo\n");
    let count = published
        .first()
        .and_then(|note| note.pointer("/params/diagnostics"))
        .and_then(Value::as_array)
        .map_or(0, Vec::len);
    assert!(count > 0);
    let fixed = server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didChange",
        "params": {
            "textDocument": { "uri": URI, "version": 2 },
            "contentChanges": [{ "text": "Algoritmo Principal\nFinAlgoritmo\n" }]
        }
    }));
    let remaining = fixed
        .first()
        .and_then(|note| note.pointer("/params/diagnostics"))
        .and_then(Value::as_array)
        .map_or(usize::MAX, Vec::len);
    assert_eq!(remaining, 0);
}

#[test]
fn applies_incremental_changes_measured_in_utf16_units() {
    let text = "Algoritmo Principal\n  Escribir \"ñ😀\"; Escribir 1;\nFinAlgoritmo\n";
    let mut server = ready_server(text);
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didChange",
        "params": {
            "textDocument": { "uri": URI, "version": 2 },
            "contentChanges": [{
                "range": { "start": { "line": 1, "character": 27 }, "end": { "line": 1, "character": 28 } },
                "text": "2"
            }]
        }
    }));
    let current = server
        .service
        .session(URI)
        .map(|session| session.text().to_owned());
    assert_eq!(
        current.as_deref(),
        Some("Algoritmo Principal\n  Escribir \"ñ😀\"; Escribir 2;\nFinAlgoritmo\n")
    );
}

#[test]
fn closing_a_document_clears_its_diagnostics_and_session() {
    let mut server = ready_server("Algoritmo Principal\n  Si x >\nFinAlgoritmo\n");
    let closed = server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didClose",
        "params": { "textDocument": { "uri": URI } }
    }));
    assert_eq!(
        closed
            .first()
            .and_then(|note| note.pointer("/params/diagnostics")),
        Some(&json!([]))
    );
    assert!(server.service.session(URI).is_none());
    assert!(server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didClose", "params": { "textDocument": { "uri": URI } }
    })).is_empty());
}

#[test]
fn answers_completion_hover_definition_references_and_highlights() {
    let mut server = ready_server(PROGRAM);
    let completion = request(&mut server, 2, "textDocument/completion", cursor_at(3, 12));
    let labels: Vec<&str> = completion
        .pointer("/result/items")
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .filter_map(|entry| entry.get("label").and_then(Value::as_str))
                .collect()
        })
        .unwrap_or_default();
    assert!(labels.contains(&"total"));
    let hover = request(&mut server, 3, "textDocument/hover", cursor_at(3, 12));
    let text = hover
        .pointer("/result/contents/value")
        .and_then(Value::as_str)
        .unwrap_or("");
    assert!(text.contains("total"), "{text}");
    let definition = request(&mut server, 4, "textDocument/definition", cursor_at(3, 12));
    assert_eq!(
        definition.pointer("/result/range/start"),
        Some(&json!({"line": 1, "character": 18}))
    );
    let references = request(
        &mut server,
        5,
        "textDocument/references",
        json!({
            "textDocument": { "uri": URI },
            "position": { "line": 3, "character": 12 },
            "context": { "includeDeclaration": false }
        }),
    );
    assert_eq!(
        references
            .get("result")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(2)
    );
    let highlights = request(
        &mut server,
        6,
        "textDocument/documentHighlight",
        cursor_at(3, 12),
    );
    let kinds: Vec<u64> = highlights
        .get("result")
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .filter_map(|entry| entry.get("kind").and_then(Value::as_u64))
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(kinds, vec![3, 3, 2]);
}

#[test]
fn answers_signature_help_and_document_symbols() {
    let code = "SubProceso Sumar(a, b)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(1, );\nFinAlgoritmo\n";
    let mut server = ready_server(code);
    let help = request(
        &mut server,
        2,
        "textDocument/signatureHelp",
        cursor_at(4, 11),
    );
    assert_eq!(help.pointer("/result/activeParameter"), Some(&json!(1)));
    assert_eq!(
        help.pointer("/result/signatures/0/label"),
        Some(&json!("Sumar(a Por Valor, b Por Valor)"))
    );
    let symbols = request(
        &mut server,
        3,
        "textDocument/documentSymbol",
        json!({"textDocument":{"uri":URI}}),
    );
    let names: Vec<&str> = symbols
        .get("result")
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .filter_map(|entry| entry.get("name").and_then(Value::as_str))
                .collect()
        })
        .unwrap_or_default();
    assert!(names.contains(&"Sumar"));
}

#[test]
fn formatting_returns_one_full_document_edit_or_nothing() {
    let mut server = ready_server("algoritmo Principal\ndefinir mutable x como entero <- 0\nfinalgoritmo");
    let edits = request(
        &mut server,
        2,
        "textDocument/formatting",
        json!({"textDocument":{"uri":URI},"options":{}}),
    );
    let first = edits
        .pointer("/result/0/newText")
        .and_then(Value::as_str)
        .unwrap_or("");
    assert_eq!(
        first,
        "Algoritmo Principal\n  Definir Mutable x Como Entero <- 0;\nFinAlgoritmo\n"
    );
    let mut clean = ready_server(PROGRAM);
    let none = request(
        &mut clean,
        2,
        "textDocument/formatting",
        json!({"textDocument":{"uri":URI},"options":{}}),
    );
    assert_eq!(none.get("result"), Some(&json!([])));
    let mut broken = ready_server("Algoritmo Principal\n  Si x >\nFinAlgoritmo\n");
    let refused = request(
        &mut broken,
        2,
        "textDocument/formatting",
        json!({"textDocument":{"uri":URI},"options":{}}),
    );
    assert_eq!(refused.get("result"), Some(&json!([])));
}

#[test]
fn queries_on_unknown_documents_return_null_or_empty() {
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    let hover = request(&mut server, 2, "textDocument/hover", cursor_at(0, 0));
    assert_eq!(hover.get("result"), Some(&Value::Null));
    let items = request(&mut server, 3, "textDocument/completion", cursor_at(0, 0));
    assert_eq!(items.pointer("/result/items"), Some(&json!([])));
}

#[test]
fn detects_the_document_profile_from_its_first_keyword() {
    let mut server = LspServer::new();
    initialize(&mut server, "es");
    open(&mut server, "algorithm Main\nendalgorithm\n");
    let profile = server
        .service
        .session(URI)
        .map(|session| session.profile.as_str());
    assert_eq!(profile, Some("en"));
}
