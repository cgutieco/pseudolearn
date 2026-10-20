use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///edicion.pseudo";

fn ready_server(text: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": { "locale": "es" }
    }));
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": { "textDocument": { "uri": URI, "languageId": "pseudolearn", "version": 1, "text": text } }
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

fn entry_with(rows: &Value, label: &str) -> Option<Value> {
    rows.as_array()?
        .iter()
        .find(|entry| entry.get("label") == Some(&json!(label)))
        .cloned()
}

#[test]
fn structured_candidates_are_snippets_and_plain_ones_are_text() -> Result<(), String> {
    let mut server = ready_server("Algoritmo P\n  Es\nFinAlgoritmo\n");
    let answer = ask(
        &mut server,
        "textDocument/completion",
        json!({ "textDocument": { "uri": URI }, "position": { "line": 1, "character": 4 } }),
    );
    let rows = answer
        .pointer("/result/items")
        .cloned()
        .unwrap_or(Value::Null);
    let plain = entry_with(&rows, "Escribir").ok_or("Escribir missing")?;
    assert_eq!(plain.get("insertTextFormat"), Some(&json!(1)));
    let mut structured = ready_server("Algoritmo P\n  Si\nFinAlgoritmo\n");
    let answer = ask(
        &mut structured,
        "textDocument/completion",
        json!({ "textDocument": { "uri": URI }, "position": { "line": 1, "character": 4 } }),
    );
    let rows = answer
        .pointer("/result/items")
        .cloned()
        .unwrap_or(Value::Null);
    let snippet = entry_with(&rows, "Si").ok_or("Si missing")?;
    assert_eq!(snippet.get("insertTextFormat"), Some(&json!(2)));
    assert_eq!(
        snippet.get("insertText"),
        Some(&json!("Si ${1:condicion} Entonces\n  $0\nSino\n  \nFinSi"))
    );
    Ok(())
}

#[test]
fn on_type_formatting_returns_the_closing_edits_in_lsp_coordinates() {
    let mut server = ready_server("Algoritmo P\n  Mientras 1 = 1 Hacer\n\nFinAlgoritmo\n");
    let answer = ask(
        &mut server,
        "textDocument/onTypeFormatting",
        json!({
            "textDocument": { "uri": URI },
            "position": { "line": 2, "character": 0 },
            "ch": "\n",
            "options": { "tabSize": 2, "insertSpaces": true }
        }),
    );
    let edits = answer
        .get("result")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    assert_eq!(edits.len(), 1);
    let first = edits.first().cloned().unwrap_or(Value::Null);
    assert_eq!(first.pointer("/range/start/line"), Some(&json!(2)));
    let text = first.get("newText").and_then(Value::as_str).unwrap_or("");
    assert_eq!(text, "    \n  FinMientras");
}

#[test]
fn on_type_formatting_answers_empty_for_unknown_documents_and_characters() {
    let mut server = ready_server("Algoritmo P\nFinAlgoritmo\n");
    let unknown = ask(
        &mut server,
        "textDocument/onTypeFormatting",
        json!({ "textDocument": { "uri": "file:///otro" }, "position": { "line": 0, "character": 0 }, "ch": "\n" }),
    );
    assert_eq!(unknown.get("result"), Some(&json!([])));
    let letter = ask(
        &mut server,
        "textDocument/onTypeFormatting",
        json!({ "textDocument": { "uri": URI }, "position": { "line": 0, "character": 1 }, "ch": "a" }),
    );
    assert_eq!(letter.get("result"), Some(&json!([])));
    let missing = ask(
        &mut server,
        "textDocument/onTypeFormatting",
        json!({ "textDocument": { "uri": URI }, "position": { "line": 0, "character": 1 } }),
    );
    assert_eq!(missing.get("result"), Some(&json!([])));
}

#[test]
fn announces_on_type_formatting_and_completion_triggers() {
    let mut server = LspServer::new();
    let answers = server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}
    }));
    let capabilities = answers
        .first()
        .and_then(|answer| answer.pointer("/result/capabilities"))
        .cloned()
        .unwrap_or(Value::Null);
    assert_eq!(
        capabilities.pointer("/onTypeFormattingProvider/firstTriggerCharacter"),
        Some(&json!("\n"))
    );
    assert_eq!(
        capabilities.pointer("/completionProvider/triggerCharacters"),
        Some(&json!(["."]))
    );
}
