use pseudolearn_api::service::LspServer;
use serde_json::{Value, json};

const PROVIDERS: [&str; 9] = [
    "textDocumentSync",
    "completionProvider",
    "hoverProvider",
    "signatureHelpProvider",
    "definitionProvider",
    "referencesProvider",
    "documentHighlightProvider",
    "documentSymbolProvider",
    "documentFormattingProvider",
];

struct Transcript {
    answers: Vec<(Value, Vec<Value>)>,
}

pub fn handle_lsp(request: &Value) -> Value {
    let Some(messages) = request.get("mensajes").and_then(Value::as_array) else {
        return json!({ "error": "missing messages" });
    };
    let mut server = LspServer::new();
    let transcript = Transcript {
        answers: messages
            .iter()
            .map(|message| (message.clone(), server.handle_message(message)))
            .collect(),
    };
    match request
        .get("proyeccion")
        .and_then(Value::as_str)
        .unwrap_or("")
    {
        "capacidades" => json!({
            "capacidades_anunciadas": transcript.announced_all_providers(),
            "cierre_limpio": transcript.shutdown_answered_null() && server.exit_code == Some(0),
        }),
        "diagnosticos" => json!({
            "diagnosticos_iniciales": transcript.diagnostic_counts().first().copied().unwrap_or(0),
            "diagnosticos_corregidos": transcript.diagnostic_counts().last().copied().unwrap_or(0),
        }),
        "capacidades_edicion" => json!({
            "disparadores_completado": transcript.capability("completionProvider/triggerCharacters"),
            "disparador_escritura": transcript.capability("onTypeFormattingProvider/firstTriggerCharacter"),
        }),
        "fragmento" => transcript.snippet_projection(request),
        "consultas" => json!({ "consultas_respondidas": transcript.all_queries_answered() }),
        other => json!({ "error": format!("unsupported projection: {other}") }),
    }
}

impl Transcript {
    fn capability(&self, pointer: &str) -> Value {
        self.responses_to("initialize")
            .iter()
            .find_map(|reply| reply.pointer(&format!("/result/capabilities/{pointer}")))
            .cloned()
            .unwrap_or(Value::Null)
    }

    fn snippet_projection(&self, request: &Value) -> Value {
        let wanted = request
            .get("etiqueta")
            .and_then(Value::as_str)
            .unwrap_or("");
        let found_row = self
            .responses_to("textDocument/completion")
            .into_iter()
            .filter_map(|reply| reply.pointer("/result/items").and_then(Value::as_array))
            .flatten()
            .find(|row| row.get("label").and_then(Value::as_str) == Some(wanted));
        match found_row {
            Some(found) => json!({
                "etiqueta": wanted,
                "insertTextFormat": found.get("insertTextFormat"),
                "insertText": found.get("insertText")
            }),
            None => json!({}),
        }
    }

    fn responses_to(&self, method: &str) -> Vec<&Value> {
        self.answers
            .iter()
            .filter(|(message, _)| message.get("method").and_then(Value::as_str) == Some(method))
            .flat_map(|(_, replies)| replies.iter())
            .collect()
    }

    fn announced_all_providers(&self) -> bool {
        self.responses_to("initialize").iter().any(|reply| {
            PROVIDERS.iter().all(|name| {
                reply
                    .pointer(&format!("/result/capabilities/{name}"))
                    .is_some()
            })
        })
    }

    fn shutdown_answered_null(&self) -> bool {
        self.responses_to("shutdown")
            .iter()
            .any(|reply| reply.get("result") == Some(&Value::Null))
    }

    fn diagnostic_counts(&self) -> Vec<usize> {
        self.responses_to("textDocument/didOpen")
            .into_iter()
            .chain(self.responses_to("textDocument/didChange"))
            .filter_map(|note| {
                note.pointer("/params/diagnostics")
                    .and_then(Value::as_array)
            })
            .map(Vec::len)
            .collect()
    }

    fn all_queries_answered(&self) -> bool {
        let queries: Vec<&(Value, Vec<Value>)> = self
            .answers
            .iter()
            .filter(|(message, _)| {
                message.get("id").is_some()
                    && !matches!(
                        message.get("method").and_then(Value::as_str),
                        Some("initialize" | "shutdown")
                    )
            })
            .collect();
        !queries.is_empty()
            && queries.iter().all(|(_, replies)| {
                replies.first().is_some_and(|reply| {
                    reply.get("error").is_none()
                        && reply.get("result").is_some_and(|result| !result.is_null())
                })
            })
    }
}
