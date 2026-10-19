use pseudolearn_service::LspServer;
use serde_json::json;

#[test]
fn handles_initialize_and_shutdown() {
    let mut server = LspServer::new();
    let initialize_request = json!({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "locale": "es"
        }
    });
    let response = server.handle_message(&initialize_request);
    assert!(response.is_some());
    let Some(initialize_result) = response else {
        return;
    };
    assert!(initialize_result.pointer("/result/capabilities").is_some());

    let initialized_notification = json!({
        "jsonrpc": "2.0",
        "method": "initialized",
        "params": {}
    });
    let initialized_response = server.handle_message(&initialized_notification);
    assert!(initialized_response.is_none());
    assert!(server.is_initialized);

    let shutdown_request = json!({
        "jsonrpc": "2.0",
        "id": 2,
        "method": "shutdown"
    });
    let shutdown_response = server.handle_message(&shutdown_request);
    assert!(shutdown_response.is_some());
    assert!(server.is_shutdown);
}

#[test]
fn publishes_diagnostics_on_open_and_change() {
    let mut server = LspServer::new();
    let initialize_request = json!({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": { "locale": "es" }
    });
    server.handle_message(&initialize_request);

    let open_notification = json!({
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
            "textDocument": {
                "uri": "file:///prueba.pseudo",
                "languageId": "pseudolearn",
                "version": 1,
                "text": "Algoritmo Principal\n  Definir x Como Entero;\n  x <- \"error\";\nFinAlgoritmo\n"
            }
        }
    });
    let open_response = server.handle_message(&open_notification);
    assert!(open_response.is_some());
    let Some(open_value) = open_response else {
        return;
    };
    let initial_diagnostics = open_value
        .pointer("/params/diagnostics")
        .and_then(|entry| entry.as_array())
        .cloned()
        .unwrap_or_default();
    assert_eq!(initial_diagnostics.len(), 1);

    let change_notification = json!({
        "jsonrpc": "2.0",
        "method": "textDocument/didChange",
        "params": {
            "textDocument": {
                "uri": "file:///prueba.pseudo",
                "version": 2
            },
            "contentChanges": [
                {
                    "range": {
                        "start": { "line": 2, "character": 7 },
                        "end": { "line": 2, "character": 14 }
                    },
                    "text": "42"
                }
            ]
        }
    });
    let change_response = server.handle_message(&change_notification);
    assert!(change_response.is_some());
    let Some(change_value) = change_response else {
        return;
    };
    let corrected_diagnostics = change_value
        .pointer("/params/diagnostics")
        .and_then(|entry| entry.as_array())
        .cloned()
        .unwrap_or_default();
    assert_eq!(corrected_diagnostics.len(), 0);
}

#[test]
fn answers_definition_and_hover() {
    let mut server = LspServer::new();
    let initialize_request = json!({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": { "locale": "es" }
    });
    server.handle_message(&initialize_request);

    let open_notification = json!({
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
            "textDocument": {
                "uri": "file:///consultas.pseudo",
                "languageId": "pseudolearn",
                "version": 1,
                "text": "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n"
            }
        }
    });
    server.handle_message(&open_notification);

    let definition_request = json!({
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/definition",
        "params": {
            "textDocument": { "uri": "file:///consultas.pseudo" },
            "position": { "line": 3, "character": 12 }
        }
    });
    let definition_response = server.handle_message(&definition_request);
    assert!(definition_response.is_some());
    let Some(definition_content) = definition_response else {
        return;
    };
    assert!(definition_content.pointer("/result/range").is_some());

    let hover_request = json!({
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/hover",
        "params": {
            "textDocument": { "uri": "file:///consultas.pseudo" },
            "position": { "line": 2, "character": 4 }
        }
    });
    let hover_response = server.handle_message(&hover_request);
    assert!(hover_response.is_some());
    let Some(hover_content) = hover_response else {
        return;
    };
    assert!(hover_content.pointer("/result/contents/value").is_some());
}
