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
    let (transcript, exit_code) = transcript(messages);
    projection(request, &transcript, exit_code)
}

fn transcript(messages: &[Value]) -> (Transcript, Option<i32>) {
    let mut server = LspServer::new();
    let transcript = Transcript {
        answers: messages
            .iter()
            .map(|message| (message.clone(), server.handle_message(message)))
            .collect(),
    };
    (transcript, server.exit_code)
}

fn projection(request: &Value, transcript: &Transcript, exit_code: Option<i32>) -> Value {
    match request
        .get("proyeccion")
        .and_then(Value::as_str)
        .unwrap_or("")
    {
        "capacidades" => json!({
            "capacidades_anunciadas": transcript.announced_all_providers(),
            "cierre_limpio": transcript.shutdown_answered_null() && exit_code == Some(0),
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
        "ayuda" => transcript.help_projection(request),
        "capacidades_ayuda" => json!({
            "comandos": transcript.capability("executeCommandProvider/commands"),
        }),
        "capacidades_proyecto" => transcript.project_capabilities(),
        "navegacion_proyecto" => transcript.project_navigation(),
        "rename" => transcript.rename_projection(),
        "rename_rejected" => transcript.rename_rejected(),
        "semantic_tokens" => transcript.semantic_tokens_projection(),
        "cancelacion" => json!({
            "cancelacion_silenciosa": transcript.responses_to("$/cancelRequest").is_empty(),
        }),
        "consultas" => json!({ "consultas_respondidas": transcript.all_queries_answered() }),
        other => json!({ "error": format!("unsupported projection: {other}") }),
    }
}

impl Transcript {
    fn project_capabilities(&self) -> Value {
        let capabilities = self
            .responses_to("initialize")
            .iter()
            .find_map(|reply| reply.pointer("/result/capabilities"));
        json!({
            "workspace_folders": capabilities
                .and_then(|value| value.pointer("/workspace/workspaceFolders/supported"))
                .and_then(Value::as_bool)
                .unwrap_or(false),
            "prepare_rename": capabilities
                .and_then(|value| value.pointer("/renameProvider/prepareProvider"))
                .and_then(Value::as_bool)
                .unwrap_or(false),
            "semantic_tokens_full": capabilities
                .and_then(|value| value.pointer("/semanticTokensProvider/full"))
                .and_then(Value::as_bool)
                .unwrap_or(false),
        })
    }

    fn project_navigation(&self) -> Value {
        let definitions = self.responses_to("textDocument/definition");
        let definition = definitions.first();
        let references = self
            .responses_to("textDocument/references")
            .first()
            .and_then(|reply| reply.pointer("/result"))
            .and_then(Value::as_array);
        json!({
            "definicion_uri": definition
                .and_then(|reply| reply.pointer("/result/uri")),
            "referencias": references.map_or(0, Vec::len),
        })
    }

    fn rename_projection(&self) -> Value {
        let range = self
            .responses_to("textDocument/prepareRename")
            .first()
            .and_then(|reply| reply.pointer("/result/range"));
        let edits = self
            .responses_to("textDocument/rename")
            .first()
            .and_then(|reply| reply.pointer("/result/documentChanges"))
            .and_then(Value::as_array);
        let edit_count = edits.map_or(0, |documents| {
            documents
                .iter()
                .filter_map(|document| document.pointer("/edits").and_then(Value::as_array))
                .map(Vec::len)
                .sum()
        });
        json!({
            "prepare_range": range,
            "rename_edits": edit_count,
        })
    }

    fn rename_rejected(&self) -> Value {
        json!({
            "rename_rejected": self.responses_to("textDocument/rename").first()
                .is_some_and(|reply| reply.get("error").is_some())
        })
    }

    fn semantic_tokens_projection(&self) -> Value {
        let encoded_tokens = self
            .responses_to("textDocument/semanticTokens/full")
            .first()
            .and_then(|reply| reply.pointer("/result/data"))
            .and_then(Value::as_array);
        json!({
            "semantic_token_count": encoded_tokens.map_or(0, |tokens| tokens.len() / 5),
            "token_encoding": "relative-utf16",
        })
    }

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

    fn help_projection(&self, request: &Value) -> Value {
        let Some(reply) = self
            .answers
            .iter()
            .rev()
            .find(|(message, _)| message.get("id").is_some())
            .and_then(|(_, replies)| replies.first())
        else {
            return json!({ "error": "missing reply" });
        };
        if let Some(code) = reply.pointer("/error/code") {
            return json!({ "codigo_error": code });
        }
        let Some(contents) = reply.pointer("/result/contents") else {
            return json!({ "resultado": null });
        };
        let text = contents.get("value").and_then(Value::as_str).unwrap_or("");
        let fragments = request
            .get("contiene")
            .and_then(Value::as_array)
            .map_or(&[][..], Vec::as_slice);
        json!({
            "formato": contents.get("kind"),
            "contenido_completo": fragments
                .iter()
                .filter_map(Value::as_str)
                .all(|fragment| text.contains(fragment)),
            "rango": reply.pointer("/result/range"),
        })
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
