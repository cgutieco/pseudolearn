use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///routing.pseudo";

fn ready_server() -> LspServer {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,
            "text":"Algoritmo Main\nFinAlgoritmo\n"}}
    }));
    server
}

fn ask(server: &mut LspServer, method: &str, position: Value) -> Value {
    let parameters = if position.is_null() {
        json!({"textDocument":{"uri":URI}})
    } else {
        json!({"textDocument":{"uri":URI},"position":position})
    };
    server
        .handle_message(&json!({"jsonrpc":"2.0","id":5,"method":method,"params":parameters}))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn error_code(response: &Value) -> Option<i64> {
    response.pointer("/error/code").and_then(Value::as_i64)
}

const POSITIONAL_METHODS: [&str; 6] = [
    "textDocument/completion",
    "textDocument/hover",
    "textDocument/definition",
    "textDocument/references",
    "textDocument/documentHighlight",
    "textDocument/signatureHelp",
];

#[test]
fn a_valid_position_is_answered_without_error() {
    let mut server = ready_server();
    for method in POSITIONAL_METHODS {
        let response = ask(&mut server, method, json!({"line":0,"character":10}));
        assert!(response.get("error").is_none(), "{method}: {response}");
    }
}

#[test]
fn a_missing_position_is_rejected_as_invalid_parameters() {
    let mut server = ready_server();
    for method in POSITIONAL_METHODS {
        let response = ask(&mut server, method, Value::Null);
        assert_eq!(error_code(&response), Some(-32602), "{method}: {response}");
    }
}

#[test]
fn negative_or_non_numeric_coordinates_are_rejected_as_invalid_parameters() {
    let mut server = ready_server();
    let malformed = [
        json!({"line":-1,"character":0}),
        json!({"line":0,"character":-3}),
        json!({"line":"0","character":0}),
        json!({"line":0.5,"character":0}),
        json!({"line":0}),
        json!({"character":0}),
    ];
    for position in malformed {
        let response = ask(&mut server, "textDocument/hover", position.clone());
        assert_eq!(
            error_code(&response),
            Some(-32602),
            "{position}: {response}"
        );
    }
}

#[test]
fn an_oversized_coordinate_is_still_a_valid_position() {
    let mut server = ready_server();
    let far = json!({"line":4294967296u64,"character":4294967296u64});
    let response = ask(&mut server, "textDocument/hover", far);
    assert!(response.get("error").is_none(), "{response}");
}

#[test]
fn a_positionless_method_does_not_require_a_position() {
    let mut server = ready_server();
    let response = ask(&mut server, "textDocument/documentSymbol", Value::Null);
    assert!(response.get("error").is_none(), "{response}");
}
