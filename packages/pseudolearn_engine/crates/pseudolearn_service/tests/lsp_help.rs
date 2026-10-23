use pseudolearn_service::LspServer;
use pseudolearn_service::help_catalog::{HelpLocale, cards};
use serde_json::{Value, json};

const URI: &str = "file:///ayuda.pseudo";
const PROGRAM: &str = "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n";

fn ready_server(locale: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "locale": locale }
    }));
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": { "textDocument": { "uri": URI, "languageId": "pseudolearn", "version": 1, "text": PROGRAM } }
    }));
    server
}

fn request(server: &mut LspServer, method: &str, parameters: Value) -> Value {
    server
        .handle_message(
            &json!({ "jsonrpc": "2.0", "id": 9, "method": method, "params": parameters }),
        )
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn explain(server: &mut LspServer, arguments: Value) -> Value {
    request(
        server,
        "workspace/executeCommand",
        json!({ "command": "pseudolearn.explain", "arguments": [arguments] }),
    )
}

fn hover(server: &mut LspServer, line: u32, character: u32) -> Value {
    request(
        server,
        "textDocument/hover",
        json!({ "textDocument": { "uri": URI }, "position": { "line": line, "character": character } }),
    )
}

fn while_summary(locale: HelpLocale) -> Option<&'static str> {
    cards()
        .iter()
        .find(|card| card.id == "help.while")
        .map(|card| card.content(locale).summary)
}

#[test]
fn hover_carries_the_card_and_the_full_token_range() -> Result<(), String> {
    let mut server = ready_server("es");
    let answer = hover(&mut server, 1, 4);
    let text = answer
        .pointer("/result/contents/value")
        .and_then(Value::as_str)
        .ok_or("missing hover text")?;
    assert!(text.contains("Bucle Mientras"));
    assert_eq!(
        answer.pointer("/result/range"),
        Some(&json!({"start":{"line":1,"character":2},"end":{"line":1,"character":10}}))
    );
    Ok(())
}

#[test]
fn interface_locale_is_independent_from_the_document_profile() -> Result<(), String> {
    let mut server = ready_server("en");
    let answer = explain(
        &mut server,
        json!({"uri": URI, "version": 1, "position": {"line": 1, "character": 4}, "format": "plaintext"}),
    );
    let text = answer
        .pointer("/result/contents/value")
        .and_then(Value::as_str)
        .ok_or("missing explanation")?;
    assert!(text.contains(while_summary(HelpLocale::English).ok_or("missing card")?));
    Ok(())
}

#[test]
fn explain_matches_hover_content_and_range() {
    let mut server = ready_server("es");
    let hovered = hover(&mut server, 1, 4);
    let explained = explain(
        &mut server,
        json!({"uri": URI, "version": 1, "position": {"line": 1, "character": 4}}),
    );
    assert_eq!(hovered.get("result"), explained.get("result"));
}

#[test]
fn stale_version_is_content_modified_and_unknown_command_is_invalid() {
    let mut server = ready_server("es");
    let stale = explain(
        &mut server,
        json!({"uri": URI, "version": 2, "position": {"line": 1, "character": 4}}),
    );
    assert_eq!(stale.pointer("/error/code"), Some(&json!(-32801)));
    let unknown = request(
        &mut server,
        "workspace/executeCommand",
        json!({ "command": "pseudolearn.other", "arguments": [] }),
    );
    assert_eq!(unknown.pointer("/error/code"), Some(&json!(-32602)));
    let missing = explain(
        &mut server,
        json!({"uri": URI, "position": {"line": 1, "character": 4}}),
    );
    assert_eq!(missing.pointer("/error/code"), Some(&json!(-32602)));
}

#[test]
fn version_follows_changes_and_closing_forgets_it() {
    let mut server = ready_server("es");
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didChange",
        "params": { "textDocument": { "uri": URI, "version": 2 },
            "contentChanges": [{ "text": PROGRAM }] }
    }));
    let old = explain(
        &mut server,
        json!({"uri": URI, "version": 1, "position": {"line": 1, "character": 4}}),
    );
    assert_eq!(old.pointer("/error/code"), Some(&json!(-32801)));
    let current = explain(
        &mut server,
        json!({"uri": URI, "version": 2, "position": {"line": 1, "character": 4}}),
    );
    assert!(current.pointer("/result/contents/value").is_some());
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didClose",
        "params": { "textDocument": { "uri": URI } }
    }));
    let closed = explain(
        &mut server,
        json!({"uri": URI, "version": 2, "position": {"line": 1, "character": 4}}),
    );
    assert_eq!(closed.pointer("/error/code"), Some(&json!(-32801)));
}

#[test]
fn positions_without_help_answer_null() {
    let mut server = ready_server("es");
    assert_eq!(hover(&mut server, 1, 1).get("result"), Some(&Value::Null));
    let blank = explain(
        &mut server,
        json!({"uri": URI, "version": 1, "position": {"line": 1, "character": 1}}),
    );
    assert_eq!(blank.get("result"), Some(&Value::Null));
}

#[test]
fn user_names_are_escaped_as_markdown_text() -> Result<(), String> {
    let mut server = LspServer::new();
    server.handle_message(
        &json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}),
    );
    let program = "Algoritmo Principal\n  Definir a_b Como Entero;\n  a_b <- 1;\nFinAlgoritmo\n";
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": { "textDocument": { "uri": URI, "languageId": "pseudolearn", "version": 1, "text": program } }
    }));
    let answer = hover(&mut server, 2, 3);
    let text = answer
        .pointer("/result/contents/value")
        .and_then(Value::as_str)
        .ok_or("missing hover text")?;
    assert!(text.contains("a\\_b"));
    Ok(())
}
