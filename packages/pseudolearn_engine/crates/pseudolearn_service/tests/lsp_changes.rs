use pseudolearn_service::LspServer;
use pseudolearn_service::lsp_changes::apply_content_changes;
use serde_json::{Value, json};

const URI: &str = "file:///changes.pseudo";
const PROGRAM: &str = "Algoritmo Main\nFinAlgoritmo\n";

fn server_with_program() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,"text":PROGRAM}}
    }));
    server
}

fn change(server: &mut LspServer, version: i64, changes: Value) {
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didChange",
        "params":{"textDocument":{"uri":URI,"version":version},"contentChanges":changes}
    }));
}

fn symbol_names(server: &mut LspServer) -> Vec<String> {
    let answer = server.handle_message(&json!({
        "jsonrpc":"2.0","id":7,"method":"textDocument/documentSymbol",
        "params":{"textDocument":{"uri":URI}}
    }));
    answer
        .first()
        .and_then(|response| response.get("result"))
        .and_then(Value::as_array)
        .map(|symbols| {
            symbols
                .iter()
                .filter_map(|symbol| symbol.get("name").and_then(Value::as_str))
                .map(str::to_owned)
                .collect()
        })
        .unwrap_or_default()
}

fn rename_main(server: &mut LspServer, version: i64, start: Value, ending: Value, text: Value) {
    change(
        server,
        version,
        json!([{ "range": {"start": start, "end": ending}, "text": text }]),
    );
}

#[test]
fn a_valid_range_change_replaces_the_selected_text() {
    let mut server = server_with_program();
    rename_main(
        &mut server,
        2,
        json!({"line":0,"character":10}),
        json!({"line":0,"character":14}),
        json!("Other"),
    );
    assert_eq!(symbol_names(&mut server), vec!["Other".to_owned()]);
}

#[test]
fn a_full_text_change_replaces_the_document() {
    let mut server = server_with_program();
    change(
        &mut server,
        2,
        json!([{ "text": "Algoritmo Whole\nFinAlgoritmo\n" }]),
    );
    assert_eq!(symbol_names(&mut server), vec!["Whole".to_owned()]);
}

#[test]
fn negative_or_non_integer_coordinates_reject_the_whole_change() {
    let mut server = server_with_program();
    let end = json!({"line":0,"character":14});
    rename_main(
        &mut server,
        2,
        json!({"line":0,"character":-1}),
        end.clone(),
        json!("Bad"),
    );
    rename_main(
        &mut server,
        3,
        json!({"line":"0","character":10}),
        end.clone(),
        json!("Bad"),
    );
    rename_main(
        &mut server,
        4,
        json!({"line":0,"character":1.5}),
        end,
        json!("Bad"),
    );
    assert_eq!(symbol_names(&mut server), vec!["Main".to_owned()]);
}

#[test]
fn a_line_beyond_u32_or_a_missing_coordinate_rejects_the_change() {
    let mut server = server_with_program();
    let end = json!({"line":0,"character":14});
    rename_main(
        &mut server,
        2,
        json!({"line":4294967296u64,"character":0}),
        end.clone(),
        json!("Bad"),
    );
    rename_main(&mut server, 3, json!({"line":0}), end, json!("Bad"));
    assert_eq!(symbol_names(&mut server), vec!["Main".to_owned()]);
}

#[test]
fn missing_or_non_string_text_rejects_the_change() {
    let mut server = server_with_program();
    let range = json!({"start":{"line":0,"character":10},"end":{"line":0,"character":14}});
    change(&mut server, 2, json!([{ "range": range.clone() }]));
    change(&mut server, 3, json!([{ "range": range, "text": 5 }]));
    assert_eq!(symbol_names(&mut server), vec!["Main".to_owned()]);
}

#[test]
fn one_malformed_change_discards_the_valid_changes_before_it() {
    let mut server = server_with_program();
    change(
        &mut server,
        2,
        json!([
            {"range":{"start":{"line":0,"character":10},"end":{"line":0,"character":14}},"text":"Other"},
            {"range":{"start":{"line":-1,"character":0},"end":{"line":0,"character":0}},"text":"x"}
        ]),
    );
    assert_eq!(symbol_names(&mut server), vec!["Main".to_owned()]);
}

#[test]
fn an_oversized_character_clamps_to_the_end_of_the_line() {
    let mut server = server_with_program();
    let far = json!({"line":0,"character":4294967296u64});
    rename_main(&mut server, 2, far.clone(), far, json!("X"));
    assert_eq!(symbol_names(&mut server), vec!["MainX".to_owned()]);
}

#[test]
fn applying_changes_directly_reports_malformed_input_as_none() {
    let good = json!({"text":"abc"});
    assert_eq!(
        apply_content_changes("old", &[good]),
        Some("abc".to_owned())
    );
    assert_eq!(apply_content_changes("old", &[json!({})]), None);
    assert_eq!(apply_content_changes("old", &[]), Some("old".to_owned()));
    let null_range = json!({"range":null,"text":"abc"});
    assert_eq!(apply_content_changes("old", &[null_range]), None);
}
