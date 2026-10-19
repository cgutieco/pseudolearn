use pseudolearn_api::service::LspServer;
use serde_json::{Value, json};

struct LspProgress {
    had_capabilities: bool,
    initial_diagnostics_count: usize,
    corrected_diagnostics_count: usize,
    answered_queries: bool,
}

pub fn handle_lsp(request: &Value) -> Value {
    let mut server = LspServer::new();
    let Some(messages) = request.get("mensajes").and_then(Value::as_array) else {
        return json!({});
    };

    let mut progress = LspProgress {
        had_capabilities: false,
        initial_diagnostics_count: 0,
        corrected_diagnostics_count: 0,
        answered_queries: false,
    };

    for message in messages {
        process_lsp_step(&mut server, message, &mut progress);
    }

    if messages
        .iter()
        .any(|message| message.get("method").and_then(Value::as_str) == Some("shutdown"))
    {
        json!({ "capacidades_anunciadas": progress.had_capabilities, "cierre_limpio": true })
    } else if progress.answered_queries {
        json!({ "consultas_respondidas": true })
    } else {
        json!({
            "diagnosticos_iniciales": progress.initial_diagnostics_count,
            "diagnosticos_corregidos": progress.corrected_diagnostics_count,
        })
    }
}

fn process_lsp_step(server: &mut LspServer, message: &Value, progress: &mut LspProgress) {
    let response_option = server.handle_message(message);
    let method = message.get("method").and_then(Value::as_str);

    match method {
        Some("initialize") => {
            if let Some(response) = &response_option {
                progress.had_capabilities = response.pointer("/result/capabilities").is_some();
            }
        }
        Some("textDocument/didOpen") => {
            if let Some(notification) = &response_option
                && let Some(diagnostics) = notification
                    .pointer("/params/diagnostics")
                    .and_then(Value::as_array)
            {
                progress.initial_diagnostics_count = diagnostics.len();
            }
        }
        Some("textDocument/didChange") => {
            if let Some(notification) = &response_option
                && let Some(diagnostics) = notification
                    .pointer("/params/diagnostics")
                    .and_then(Value::as_array)
            {
                progress.corrected_diagnostics_count = diagnostics.len();
            }
        }
        Some("textDocument/definition") | Some("textDocument/hover") => {
            if let Some(response) = &response_option
                && !response.get("result").unwrap_or(&Value::Null).is_null()
            {
                progress.answered_queries = true;
            }
        }
        _ => {}
    }
}
