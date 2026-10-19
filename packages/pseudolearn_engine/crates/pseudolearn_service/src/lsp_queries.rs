use crate::formatter::{FormatOptions, format_checked};
use crate::lsp_protocol::{
    completion_kind_code, lsp_range, lsp_range_from_offsets, position_from_request, success,
    text_document_uri,
};
use crate::lsp_session::LspServer;
use crate::navigation::{HighlightKind, SymbolCategory};
use serde_json::{Value, json};

impl LspServer {
    pub(crate) fn handle_completion(&self, message: &Value) -> Value {
        let uri = text_document_uri(message);
        let items: Vec<Value> = self
            .service
            .session(uri)
            .map(|session| {
                let position = position_from_request(session.text(), message);
                session
                    .queries()
                    .complete_with_edit(position)
                    .entries
                    .into_iter()
                    .enumerate()
                    .map(|(rank, entry)| {
                        json!({
                            "label": entry.label,
                            "kind": completion_kind_code(entry.kind),
                            "detail": entry.detail,
                            "insertText": entry.insert_text.clone().unwrap_or_else(|| entry.label.clone()),
                            "sortText": format!("{rank:05}")
                        })
                    })
                    .collect()
            })
            .unwrap_or_default();
        success(message, json!({ "isIncomplete": false, "items": items }))
    }

    pub(crate) fn handle_hover(&self, message: &Value) -> Value {
        let result = self
            .service
            .session(text_document_uri(message))
            .and_then(|session| {
                let position = position_from_request(session.text(), message);
                let outcome = session.queries().hover(position)?;
                let mut lines = Vec::new();
                match &outcome.signature {
                    Some(signature) => lines.push(format!("```\n{signature}\n```")),
                    None if outcome.type_name.is_empty() => lines.push(outcome.identifier.clone()),
                    None => lines.push(format!("{}: {}", outcome.identifier, outcome.type_name)),
                }
                if let Some(description) = &outcome.description {
                    lines.push(description.clone());
                }
                Some(json!({ "contents": { "kind": "markdown", "value": lines.join("\n\n") } }))
            });
        success(message, result.unwrap_or(Value::Null))
    }

    pub(crate) fn handle_signature_help(&self, message: &Value) -> Value {
        let result = self
            .service
            .session(text_document_uri(message))
            .and_then(|session| {
                let position = position_from_request(session.text(), message);
                let help = session.queries().signature_help(position)?;
                let parameters: Vec<Value> = help
                    .parameters
                    .iter()
                    .map(|label| json!({ "label": label }))
                    .collect();
                Some(json!({
                    "signatures": [{ "label": help.signature, "parameters": parameters }],
                    "activeSignature": 0,
                    "activeParameter": help.active_parameter
                }))
            });
        success(message, result.unwrap_or(Value::Null))
    }

    pub(crate) fn handle_definition(&self, message: &Value) -> Value {
        let uri = text_document_uri(message);
        let result = self.service.session(uri).and_then(|session| {
            let position = position_from_request(session.text(), message);
            let range = session.queries().definition(position)?;
            Some(json!({ "uri": uri, "range": lsp_range(session.text(), range) }))
        });
        success(message, result.unwrap_or(Value::Null))
    }

    pub(crate) fn handle_references(&self, message: &Value) -> Value {
        let uri = text_document_uri(message);
        let include_declaration = message
            .pointer("/params/context/includeDeclaration")
            .and_then(Value::as_bool)
            .unwrap_or(true);
        let locations: Vec<Value> = self
            .service
            .session(uri)
            .map(|session| {
                let position = position_from_request(session.text(), message);
                let declaration = session.queries().definition(position);
                session
                    .queries()
                    .references(position)
                    .into_iter()
                    .filter(|range| include_declaration || Some(*range) != declaration)
                    .map(|range| json!({ "uri": uri, "range": lsp_range(session.text(), range) }))
                    .collect()
            })
            .unwrap_or_default();
        success(message, Value::Array(locations))
    }

    pub(crate) fn handle_highlight(&self, message: &Value) -> Value {
        let highlights: Vec<Value> = self
            .service
            .session(text_document_uri(message))
            .map(|session| {
                let position = position_from_request(session.text(), message);
                session
                    .queries()
                    .highlights(position)
                    .into_iter()
                    .map(|entry| {
                        let kind = match entry.kind {
                            HighlightKind::Read => 2,
                            HighlightKind::Write => 3,
                        };
                        json!({ "range": lsp_range(session.text(), entry.range), "kind": kind })
                    })
                    .collect()
            })
            .unwrap_or_default();
        success(message, Value::Array(highlights))
    }

    pub(crate) fn handle_document_symbols(&self, message: &Value) -> Value {
        let uri = text_document_uri(message);
        let symbols: Vec<Value> = self
            .service
            .session(uri)
            .map(|session| {
                session
                    .queries()
                    .symbols()
                    .into_iter()
                    .map(|entry| {
                        let kind = match entry.category {
                            SymbolCategory::Class => 5,
                            SymbolCategory::Method => 6,
                            SymbolCategory::Field => 8,
                            SymbolCategory::Function => 12,
                            SymbolCategory::Variable => 13,
                        };
                        json!({
                            "name": entry.name,
                            "kind": kind,
                            "containerName": entry.container,
                            "location": { "uri": uri, "range": lsp_range(session.text(), entry.range) }
                        })
                    })
                    .collect()
            })
            .unwrap_or_default();
        success(message, Value::Array(symbols))
    }

    pub(crate) fn handle_formatting(&self, message: &Value) -> Value {
        let edits = self
            .service
            .session(text_document_uri(message))
            .and_then(|session| {
                let formatted = format_checked(
                    session.text(),
                    FormatOptions {
                        profile: session.profile,
                        strict: session.strict,
                        indent_size: 2,
                    },
                )?;
                if formatted == session.text() {
                    return None;
                }
                let end = session.text().len();
                Some(json!([{
                    "range": lsp_range_from_offsets(session.text(), 0, end),
                    "newText": formatted
                }]))
            });
        success(message, edits.unwrap_or_else(|| json!([])))
    }
}
