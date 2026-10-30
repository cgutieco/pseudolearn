use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///cases.pseudo";
const PROGRAM: &str = "Algoritmo P\n// nota\nDefinir texto Como Cadena <- \"hola\";\nDefinir Mutable x Como Entero <- 0;\nEscribir trunc(2.5), x, \"\u{1F600}\", x;\nSi x > 1 Entonces\nSino\nFinSi\nFinAlgoritmo\n";

fn open(program: &str, locale: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "locale": locale }
    }));
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": { "textDocument": { "uri": URI, "languageId": "pseudolearn", "version": 1, "text": program } }
    }));
    server
}

fn ask(server: &mut LspServer, method: &str, parameters: Value) -> Value {
    server
        .handle_message(
            &json!({ "jsonrpc": "2.0", "id": 9, "method": method, "params": parameters }),
        )
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn hover(server: &mut LspServer, line: u32, character: u32) -> Value {
    ask(
        server,
        "textDocument/hover",
        json!({ "textDocument": { "uri": URI }, "position": { "line": line, "character": character } }),
    )
}

fn explain(server: &mut LspServer, line: u32, character: u32, version: i64) -> Value {
    ask(
        server,
        "workspace/executeCommand",
        json!({ "command": "pseudolearn.explain", "arguments": [{
            "uri": URI, "version": version, "position": { "line": line, "character": character }
        }] }),
    )
}

fn text_of(answer: &Value) -> String {
    answer
        .pointer("/result/contents/value")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned()
}

#[test]
fn hover_and_explain_agree_on_every_probed_position() {
    let mut server = open(PROGRAM, "en");
    let positions = [
        (1, 4),
        (2, 30),
        (4, 11),
        (4, 21),
        (5, 0),
        (5, 6),
        (6, 0),
        (7, 0),
        (3, 8),
    ];
    for (line, character) in positions {
        let hovered = hover(&mut server, line, character);
        let explained = explain(&mut server, line, character, 1);
        assert_eq!(
            hovered.get("result"),
            explained.get("result"),
            "{line}:{character}"
        );
    }
}

#[test]
fn comments_strings_and_empty_programs_have_no_card() {
    let mut server = open(PROGRAM, "en");
    assert_eq!(hover(&mut server, 1, 4).get("result"), Some(&Value::Null));
    assert_eq!(hover(&mut server, 2, 30).get("result"), Some(&Value::Null));
    let mut empty = open("", "es");
    assert_eq!(hover(&mut empty, 0, 0).get("result"), Some(&Value::Null));
}

#[test]
fn library_function_user_symbol_and_compound_keywords_have_help() {
    let mut server = open(PROGRAM, "en");
    assert!(text_of(&hover(&mut server, 4, 11)).contains("trunc(Real) Como Entero"));
    assert!(text_of(&hover(&mut server, 4, 21)).contains("Entero"));
    for (line, character) in [(5, 0), (6, 0), (7, 0), (3, 8)] {
        assert!(!text_of(&hover(&mut server, line, character)).is_empty());
    }
    assert!(text_of(&hover(&mut server, 5, 6)).contains("Comparisons"));
}

#[test]
fn utf16_ranges_survive_non_bmp_characters_before_the_token() {
    let mut server = open(PROGRAM, "en");
    let answer = hover(&mut server, 4, 30);
    assert_eq!(
        answer.pointer("/result/range/start/character"),
        Some(&json!(30))
    );
    assert_eq!(
        answer.pointer("/result/range/end/character"),
        Some(&json!(31))
    );
}

#[test]
fn incomplete_program_still_explains_the_keyword_in_the_interface_locale() {
    let mut spanish = open("Algoritmo P\nMientras\n", "es");
    let mut english = open("Algoritmo P\nMientras\n", "en");
    let spanish_text = text_of(&hover(&mut spanish, 1, 2));
    let english_text = text_of(&hover(&mut english, 1, 2));
    assert!(spanish_text.contains("Bucle Mientras"));
    assert!(english_text.contains("Mientras"));
    assert_ne!(spanish_text, english_text);
}

#[test]
fn stale_explain_request_is_rejected_after_an_edit() {
    let mut server = open(PROGRAM, "en");
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didChange",
        "params": { "textDocument": { "uri": URI, "version": 2 },
                    "contentChanges": [{ "text": "Algoritmo P\nFinAlgoritmo\n" }] }
    }));
    let stale = explain(&mut server, 4, 11, 1);
    assert!(stale.get("error").is_some());
    assert!(explain(&mut server, 0, 2, 2).get("error").is_none());
}
