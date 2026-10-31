use pseudolearn_service::{LspServer, RequestCancellation};
use serde_json::{Value, json};

const APP_URI: &str = "file:///app/main.pseudo";
const LIBRARY_URI: &str = "file:///geo/vector.pseudo";
const MAIN: &str =
    "Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n";
const LIBRARY: &str = "Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n";

fn initialized_server() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":{}}
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

#[test]
fn workspace_symbols_use_short_names_and_point_to_closed_definitions() -> Result<(), String> {
    let mut server = initialized_server();
    server.handle_message(&workspace_message(MAIN, LIBRARY));
    let response = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"workspace/symbol","params":{"query":"Double"}
    }));
    let rows = response
        .first()
        .and_then(|answer| answer.pointer("/result"))
        .and_then(Value::as_array)
        .ok_or("workspace/symbol returned no array")?;
    let symbol = rows
        .iter()
        .find(|candidate| candidate.get("name") == Some(&json!("Double")))
        .ok_or("workspace/symbol omitted the imported definition")?;
    assert_eq!(symbol.pointer("/location/uri"), Some(&json!(LIBRARY_URI)));
    Ok::<(), String>(())
}

#[test]
fn workspace_symbols_reuse_one_line_index_for_multiple_definitions() -> Result<(), String> {
    let mut library = String::from(LIBRARY);
    library.push_str(
        "Publico SubProceso Triple(value Como Entero) Como Entero\nRetornar value * 3;\nFinSubProceso\n",
    );
    let mut server = initialized_server();
    server.handle_message(&workspace_message(MAIN, &library));
    let response = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"workspace/symbol","params":{"query":""}
    }));
    let rows = response
        .first()
        .and_then(|answer| answer.pointer("/result"))
        .and_then(Value::as_array)
        .ok_or("workspace/symbol returned no array")?;
    let double = rows
        .iter()
        .find(|candidate| candidate.get("name") == Some(&json!("Double")))
        .ok_or("workspace/symbol omitted Double")?;
    let triple = rows
        .iter()
        .find(|candidate| candidate.get("name") == Some(&json!("Triple")))
        .ok_or("workspace/symbol omitted Triple")?;
    assert_eq!(double.pointer("/location/uri"), Some(&json!(LIBRARY_URI)));
    assert_eq!(triple.pointer("/location/uri"), Some(&json!(LIBRARY_URI)));
    assert_eq!(
        double.pointer("/location/range/start/line"),
        Some(&json!(0))
    );
    assert_eq!(
        triple.pointer("/location/range/start/line"),
        Some(&json!(3))
    );
    Ok(())
}

#[test]
fn workspace_symbol_queries_without_matches_return_an_empty_array() {
    let mut server = initialized_server();
    server.handle_message(&workspace_message(MAIN, LIBRARY));
    let response = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"workspace/symbol","params":{"query":"MissingSymbol"}
    }));
    assert_eq!(
        response
            .first()
            .and_then(|answer| answer.pointer("/result")),
        Some(&json!([]))
    );
}

#[test]
fn workspace_document_symbols_are_created_for_the_first_document_query() {
    let mut server = initialized_server();
    server.handle_message(&workspace_message(MAIN, LIBRARY));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":APP_URI,"languageId":"pseudolearn","version":1,"text":MAIN}}
    }));
    let response = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/documentSymbol",
        "params":{"textDocument":{"uri":APP_URI}}
    }));
    assert!(response.first().is_some_and(|answer| {
        answer
            .pointer("/result")
            .and_then(Value::as_array)
            .is_some_and(|rows| {
                rows.iter()
                    .any(|row| row.get("name") == Some(&json!("Main")))
            })
    }));
}

#[test]
fn workspace_symbol_requests_observe_cooperative_cancellation() {
    let mut server = initialized_server();
    server.handle_message(&workspace_message(MAIN, LIBRARY));
    let cancellation = RequestCancellation::new();
    cancellation.cancel();
    let response = server.handle_cancellable_message(
        &json!({"jsonrpc":"2.0","id":2,"method":"workspace/symbol","params":{"query":""}}),
        cancellation,
    );
    assert_eq!(
        response
            .first()
            .and_then(|answer| answer.pointer("/error/code")),
        Some(&json!(-32800))
    );
}
