use crate::document_session::{DocumentOptions, LanguageService};
use crate::formatter::FormatOptions;
use crate::lsp_changes::apply_content_changes;
use crate::lsp_protocol::{map_completion_kind_code, parse_lsp_position};
use crate::navigation::Position;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::LineIndex;
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub struct LspServer {
    pub service: LanguageService,
    documents_text: BTreeMap<String, String>,
    pub is_initialized: bool,
    pub is_shutdown: bool,
    pub locale: String,
}

impl Default for LspServer {
    fn default() -> Self {
        Self::new()
    }
}

impl LspServer {
    pub fn new() -> Self {
        Self {
            service: LanguageService::new(),
            documents_text: BTreeMap::new(),
            is_initialized: false,
            is_shutdown: false,
            locale: String::from("es"),
        }
    }

    pub fn handle_message(&mut self, message: &Value) -> Option<Value> {
        let method = message.get("method").and_then(Value::as_str);
        match method {
            Some("initialize") => Some(self.handle_initialize(message)),
            Some("initialized") => {
                self.is_initialized = true;
                None
            }
            Some("shutdown") => Some(self.handle_shutdown(message)),
            Some("exit") => None,
            Some("textDocument/didOpen") => self.handle_did_open(message),
            Some("textDocument/didChange") => self.handle_did_change(message),
            Some("textDocument/definition") => Some(self.handle_definition(message)),
            Some("textDocument/hover") => Some(self.handle_hover(message)),
            Some("textDocument/completion") => Some(self.handle_completion(message)),
            Some("textDocument/formatting") => Some(self.handle_formatting(message)),
            _ => None,
        }
    }

    fn handle_initialize(&mut self, message: &Value) -> Value {
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        if let Some(locale) = message.pointer("/params/locale").and_then(Value::as_str) {
            self.locale = locale.to_owned();
        }
        json!({
            "jsonrpc": "2.0",
            "id": identifier,
            "result": {
                "capabilities": {
                    "textDocumentSync": 1,
                    "completionProvider": { "triggerCharacters": [".", ":", " "] },
                    "hoverProvider": true,
                    "signatureHelpProvider": { "triggerCharacters": ["(", ","] },
                    "definitionProvider": true,
                    "referencesProvider": true,
                    "documentHighlightProvider": true,
                    "documentSymbolProvider": true,
                    "documentFormattingProvider": true
                }
            }
        })
    }

    fn handle_shutdown(&mut self, message: &Value) -> Value {
        self.is_shutdown = true;
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        json!({
            "jsonrpc": "2.0",
            "id": identifier,
            "result": Value::Null
        })
    }

    fn handle_did_open(&mut self, message: &Value) -> Option<Value> {
        let uri = message.pointer("/params/textDocument/uri")?.as_str()?;
        let text = message.pointer("/params/textDocument/text")?.as_str()?;
        self.documents_text.insert(uri.to_owned(), text.to_owned());
        let profile = if self.locale == "en" {
            Profile::English
        } else {
            Profile::Spanish
        };
        self.service.open_document(
            uri.to_owned(),
            text.to_owned(),
            DocumentOptions {
                profile,
                strict: true,
            },
        );
        self.build_diagnostics_notification(uri)
    }

    fn handle_did_change(&mut self, message: &Value) -> Option<Value> {
        let uri = message.pointer("/params/textDocument/uri")?.as_str()?;
        let changes = message.pointer("/params/contentChanges")?.as_array()?;
        let current_text = self.documents_text.get(uri)?.clone();
        let new_text = apply_content_changes(&current_text, changes);
        self.documents_text.insert(uri.to_owned(), new_text.clone());
        self.service.edit_document(uri, new_text);
        self.build_diagnostics_notification(uri)
    }

    fn handle_definition(&self, message: &Value) -> Value {
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        let uri = message
            .pointer("/params/textDocument/uri")
            .and_then(Value::as_str)
            .unwrap_or("");
        let line = message
            .pointer("/params/position/line")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let character = message
            .pointer("/params/position/character")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let position = Position {
            line: u32::try_from(line.saturating_add(1)).unwrap_or(1),
            column: u32::try_from(character.saturating_add(1)).unwrap_or(1),
        };

        let result = self.service.session(uri).and_then(|session| {
            let definition_range = session.definition(position)?;
            Some(json!({
                "uri": uri,
                "range": {
                    "start": { "line": definition_range.start.line.saturating_sub(1), "character": definition_range.start.column.saturating_sub(1) },
                    "end": { "line": definition_range.end.line.saturating_sub(1), "character": definition_range.end.column.saturating_sub(1) }
                }
            }))
        });
        json!({ "jsonrpc": "2.0", "id": identifier, "result": result })
    }

    fn handle_hover(&self, message: &Value) -> Value {
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        let uri = message
            .pointer("/params/textDocument/uri")
            .and_then(Value::as_str)
            .unwrap_or("");
        let line = message
            .pointer("/params/position/line")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let character = message
            .pointer("/params/position/character")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let position = Position {
            line: u32::try_from(line.saturating_add(1)).unwrap_or(1),
            column: u32::try_from(character.saturating_add(1)).unwrap_or(1),
        };

        let result = self.service.session(uri).and_then(|session| {
            let hover_outcome = session.hover(position)?;
            let text = if let Some(signature) = hover_outcome.signature {
                format!("{signature}\n{}", hover_outcome.type_name)
            } else {
                format!("{}: {}", hover_outcome.identifier, hover_outcome.type_name)
            };
            Some(json!({
                "contents": {
                    "kind": "markdown",
                    "value": text
                }
            }))
        });
        json!({ "jsonrpc": "2.0", "id": identifier, "result": result })
    }

    fn handle_completion(&self, message: &Value) -> Value {
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        let uri = message
            .pointer("/params/textDocument/uri")
            .and_then(Value::as_str)
            .unwrap_or("");
        let position = parse_lsp_position(message);
        let candidates = self.collect_completion_candidates(uri, position);
        json!({ "jsonrpc": "2.0", "id": identifier, "result": candidates })
    }

    fn collect_completion_candidates(&self, uri: &str, position: Position) -> Vec<Value> {
        let Some(session) = self.service.session(uri) else {
            return Vec::new();
        };
        session
            .complete(position)
            .into_iter()
            .map(|entry| {
                json!({
                    "label": entry.label,
                    "kind": map_completion_kind_code(entry.kind),
                    "detail": entry.detail
                })
            })
            .collect()
    }

    fn handle_formatting(&self, message: &Value) -> Value {
        let identifier = message.get("id").cloned().unwrap_or(Value::Null);
        let uri = message
            .pointer("/params/textDocument/uri")
            .and_then(Value::as_str)
            .unwrap_or("");
        let text = self
            .documents_text
            .get(uri)
            .map(String::as_str)
            .unwrap_or("");
        let profile = if self.locale == "en" {
            Profile::English
        } else {
            Profile::Spanish
        };
        let formatted = self.service.format_text(
            text,
            FormatOptions {
                profile,
                strict: true,
                indent_size: 2,
            },
        );
        let lines_count = u32::try_from(text.lines().count()).unwrap_or(1);
        json!({
            "jsonrpc": "2.0",
            "id": identifier,
            "result": [
                {
                    "range": {
                        "start": { "line": 0, "character": 0 },
                        "end": { "line": lines_count, "character": 0 }
                    },
                    "newText": formatted
                }
            ]
        })
    }

    fn build_diagnostics_notification(&self, uri: &str) -> Option<Value> {
        let session = self.service.session(uri)?;
        let indexer = LineIndex::build(session.source.as_str());
        let mut lsp_diagnostics = Vec::new();
        for diagnostic in &session.analysis.diagnostics {
            let (start_line, start_col) =
                indexer.line_and_column(session.source.as_str(), diagnostic.span.start);
            let (end_line, end_col) =
                indexer.line_and_column(session.source.as_str(), diagnostic.span.ending);
            lsp_diagnostics.push(json!({
                "range": {
                    "start": { "line": start_line.saturating_sub(1), "character": start_col.saturating_sub(1) },
                    "end": { "line": end_line.saturating_sub(1), "character": end_col.saturating_sub(1) }
                },
                "severity": 1,
                "message": format!("{:?}", diagnostic.code),
                "source": "pseudolearn"
            }));
        }
        Some(json!({
            "jsonrpc": "2.0",
            "method": "textDocument/publishDiagnostics",
            "params": {
                "uri": uri,
                "diagnostics": lsp_diagnostics
            }
        }))
    }
}
