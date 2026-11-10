use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///rename.pseudo";
const PROGRAM: &str = "SubProceso Aux()\nFinSubProceso\nAlgoritmo Main\nDefinir total Como Entero <- 0;\nEscribir total;\nFinAlgoritmo\n";

fn ready_server(text: &str) -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":{"workspace":{"workspaceEdit":
            {"documentChanges":true,"failureHandling":"transactional"}}}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,"text":text}}
    }));
    server
}

fn rename(server: &mut LspServer, line: u64, character: u64, new_name: &str) -> Value {
    server
        .handle_message(&json!({
            "jsonrpc":"2.0","id":2,"method":"textDocument/rename",
            "params":{"textDocument":{"uri":URI},"position":{"line":line,"character":character},"newName":new_name}
        }))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn edit_count(response: &Value) -> usize {
    response
        .pointer("/result/documentChanges/0/edits")
        .and_then(Value::as_array)
        .map_or(0, Vec::len)
}

#[test]
fn renaming_a_local_to_a_free_name_edits_every_occurrence() {
    let mut server = ready_server(PROGRAM);
    let response = rename(&mut server, 3, 9, "fresh");
    assert_eq!(edit_count(&response), 2, "{response}");
}

#[test]
fn renaming_a_local_onto_a_top_level_function_is_rejected() {
    let mut server = ready_server(PROGRAM);
    let response = rename(&mut server, 3, 9, "Aux");
    assert!(response.get("error").is_some(), "{response}");
}

#[test]
fn renaming_a_local_onto_the_enclosing_algorithm_name_is_not_a_function_collision() {
    let mut server = ready_server(PROGRAM);
    let response = rename(&mut server, 3, 9, "Main");
    assert_eq!(edit_count(&response), 2, "{response}");
}

#[test]
fn renaming_a_function_onto_a_class_name_is_rejected() {
    let text =
        "Clase Box\nFinClase\nSubProceso Aux()\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let mut server = ready_server(text);
    assert!(rename(&mut server, 2, 12, "Box").get("error").is_some());
    assert_eq!(edit_count(&rename(&mut server, 2, 12, "Other")), 1);
}

#[test]
fn renaming_a_local_to_its_own_name_is_not_a_collision() {
    let mut server = ready_server(PROGRAM);
    let response = rename(&mut server, 3, 9, "total");
    assert_eq!(edit_count(&response), 2, "{response}");
}
