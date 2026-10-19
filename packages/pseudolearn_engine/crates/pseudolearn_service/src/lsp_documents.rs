use crate::document_session::DocumentOptions;
use crate::lsp_changes::apply_content_changes;
use crate::lsp_protocol::{lsp_range_from_offsets, text_document_uri};
use crate::lsp_session::LspServer;
use pseudolearn_diagnostics::{DiagnosticSeverity, render::render};
use pseudolearn_lexicon::{Profile, detect_opener};
use serde_json::{Value, json};

impl LspServer {
    pub(crate) fn handle_did_open(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        let Some(text) = message
            .pointer("/params/textDocument/text")
            .and_then(Value::as_str)
        else {
            return Vec::new();
        };
        let profile = detect_document_profile(text, self.locale_profile());
        self.service.open_document(
            uri.clone(),
            text.to_owned(),
            DocumentOptions {
                profile,
                strict: self.strict,
            },
        );
        self.diagnostics_notification(&uri).into_iter().collect()
    }

    pub(crate) fn handle_did_change(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        let Some(changes) = message
            .pointer("/params/contentChanges")
            .and_then(Value::as_array)
        else {
            return Vec::new();
        };
        let Some(current) = self
            .service
            .session(&uri)
            .map(|session| session.text().to_owned())
        else {
            return Vec::new();
        };
        let updated = apply_content_changes(&current, changes);
        self.service.edit_document(&uri, updated);
        self.diagnostics_notification(&uri).into_iter().collect()
    }

    pub(crate) fn handle_did_close(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        if !self.service.close_document(&uri) {
            return Vec::new();
        }
        vec![publish(&uri, Vec::new())]
    }

    fn diagnostics_notification(&self, uri: &str) -> Option<Value> {
        let session = self.service.session(uri)?;
        let text = session.text();
        let locale = self.locale.as_str();
        let items: Vec<Value> = session
            .diagnostics()
            .iter()
            .map(|diagnostic| {
                let start = usize::try_from(diagnostic.span.start).unwrap_or(0);
                let ending = usize::try_from(diagnostic.span.ending).unwrap_or(start);
                json!({
                    "range": lsp_range_from_offsets(text, start, ending),
                    "severity": severity_code(diagnostic.severity),
                    "code": diagnostic.code.as_str(),
                    "message": render(diagnostic, locale),
                    "source": "pseudolearn"
                })
            })
            .collect();
        Some(publish(uri, items))
    }

    pub(crate) fn locale_profile(&self) -> Profile {
        Profile::from_name(&self.locale).unwrap_or(Profile::Spanish)
    }
}

fn publish(uri: &str, diagnostics: Vec<Value>) -> Value {
    json!({
        "jsonrpc": "2.0",
        "method": "textDocument/publishDiagnostics",
        "params": { "uri": uri, "diagnostics": diagnostics }
    })
}

fn severity_code(severity: DiagnosticSeverity) -> u32 {
    match severity {
        DiagnosticSeverity::Error => 1,
        DiagnosticSeverity::Warning => 2,
        DiagnosticSeverity::Information => 3,
    }
}

pub fn detect_document_profile(text: &str, fallback: Profile) -> Profile {
    let mut rest = text.trim_start_matches('\u{FEFF}');
    loop {
        rest = rest.trim_start();
        if let Some(after) = rest.strip_prefix("//") {
            rest = after.split_once('\n').map_or("", |(_, tail)| tail);
        } else if let Some(after) = rest.strip_prefix("/*") {
            rest = after.split_once("*/").map_or("", |(_, tail)| tail);
        } else {
            break;
        }
    }
    let first_word: String = rest
        .chars()
        .take_while(|glyph| glyph.is_alphanumeric() || *glyph == '_')
        .collect();
    if first_word.is_empty() {
        return fallback;
    }
    detect_opener(&first_word).unwrap_or(fallback)
}
