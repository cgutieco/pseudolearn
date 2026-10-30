use crate::document_session::DocumentOptions;
use crate::lsp_changes::apply_content_changes;
use crate::lsp_protocol::text_document_uri;
use crate::lsp_session::LspServer;
use pseudolearn_lexicon::{Profile, detect_opener};
use serde_json::Value;

impl LspServer {
    pub(crate) fn handle_did_open(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        let Some((text, version)) = opened_document(message) else {
            return Vec::new();
        };
        if let Some(path) = self.path_for_uri(&uri) {
            return self.open_workspace_document(OpenDocumentRequest {
                uri: &uri,
                path,
                text,
                version,
            });
        }
        self.open_standalone_document(&uri, text, version)
    }

    pub(crate) fn handle_did_change(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        let Some(mut request) = document_change_request(message, &uri) else {
            return Vec::new();
        };
        request.path = self.path_for_uri(&uri);
        let Some(current) = self.current_document_text(&request) else {
            return Vec::new();
        };
        if self
            .versions
            .get(&request.uri)
            .is_some_and(|previous| request.version <= *previous)
        {
            return Vec::new();
        }
        let updated = apply_content_changes(&current, request.changes);
        self.commit_document_change(request, updated)
    }

    pub(crate) fn handle_did_close(&mut self, message: &Value) -> Vec<Value> {
        let uri = text_document_uri(message).to_owned();
        self.versions.remove(&uri);
        if let Some(path) = self.path_for_uri(&uri)
            && let Some(workspace) = self.workspace_session.as_mut()
            && workspace.close_document(&path).is_ok()
        {
            self.service.close_document(&uri);
            return self.workspace_diagnostics_notifications();
        }
        if !self.service.close_document(&uri) {
            return Vec::new();
        }
        vec![crate::lsp_diagnostics::publish(&uri, Vec::new())]
    }

    pub(crate) fn locale_profile(&self) -> Profile {
        Profile::from_name(&self.locale).unwrap_or(Profile::Spanish)
    }

    pub(crate) fn path_for_uri(&self, uri: &str) -> Option<String> {
        self.workspace_uris
            .iter()
            .find(|(_, candidate)| candidate.as_str() == uri)
            .map(|(path, _)| path.clone())
    }

    pub(crate) fn uri_for_path(&self, path: &str) -> Option<&str> {
        self.workspace_uris.get(path).map(String::as_str)
    }

    fn open_workspace_document(&mut self, request: OpenDocumentRequest<'_>) -> Vec<Value> {
        let Ok(workspace_version) = u64::try_from(request.version) else {
            return Vec::new();
        };
        let result = self.workspace_session.as_mut().map(|workspace| {
            workspace.open_document(&request.path, workspace_version, request.text.to_owned())
        });
        if result.is_some_and(|outcome| outcome.is_err()) {
            return Vec::new();
        }
        let profile = self
            .workspace_session
            .as_ref()
            .and_then(|workspace| workspace.profile_for_path(&request.path))
            .unwrap_or_else(|| detect_document_profile(request.text, self.locale_profile()));
        let strict = self
            .workspace_session
            .as_ref()
            .is_none_or(crate::workspace_session::WorkspaceSession::strict);
        self.service.open_document(
            request.uri.to_owned(),
            request.text.to_owned(),
            DocumentOptions { profile, strict },
        );
        self.versions
            .insert(request.uri.to_owned(), request.version);
        self.workspace_diagnostics_notifications()
    }

    fn open_standalone_document(&mut self, uri: &str, text: &str, version: i64) -> Vec<Value> {
        self.versions.insert(uri.to_owned(), version);
        let profile = detect_document_profile(text, self.locale_profile());
        self.service.open_document(
            uri.to_owned(),
            text.to_owned(),
            DocumentOptions {
                profile,
                strict: self.strict,
            },
        );
        self.diagnostics_notification(uri).into_iter().collect()
    }

    fn current_document_text(&self, request: &DocumentChangeRequest<'_>) -> Option<String> {
        request
            .path
            .as_deref()
            .and_then(|path| {
                self.workspace_session
                    .as_ref()
                    .and_then(|workspace| workspace.file_by_path(path))
                    .map(|(_, text)| text.to_owned())
            })
            .or_else(|| {
                self.service
                    .session(&request.uri)
                    .map(|session| session.text().to_owned())
            })
    }

    fn commit_document_change(
        &mut self,
        request: DocumentChangeRequest<'_>,
        updated: String,
    ) -> Vec<Value> {
        if let Some(path) = request.path {
            if !self.change_workspace_document(&path, request.version, &updated) {
                return Vec::new();
            }
            self.service.edit_document(&request.uri, updated);
            self.versions.insert(request.uri, request.version);
            return self.workspace_diagnostics_notifications();
        }
        self.service.edit_document(&request.uri, updated);
        self.versions.insert(request.uri.clone(), request.version);
        self.diagnostics_notification(&request.uri)
            .into_iter()
            .collect()
    }

    fn change_workspace_document(&mut self, path: &str, version: i64, text: &str) -> bool {
        let result = self.workspace_session.as_mut().map(|workspace| {
            u64::try_from(version)
                .map_err(|_| crate::workspace_model::WorkspaceError::DocumentVersionDidNotAdvance)
                .and_then(|version| workspace.change_document(path, version, text.to_owned()))
        });
        !result.is_some_and(|outcome| outcome.is_err())
    }
}

struct DocumentChangeRequest<'request> {
    uri: String,
    path: Option<String>,
    version: i64,
    changes: &'request [Value],
}

struct OpenDocumentRequest<'document> {
    uri: &'document str,
    path: String,
    text: &'document str,
    version: i64,
}

fn opened_document(message: &Value) -> Option<(&str, i64)> {
    let text = message
        .pointer("/params/textDocument/text")
        .and_then(Value::as_str)?;
    let version = message
        .pointer("/params/textDocument/version")
        .and_then(Value::as_i64)?;
    Some((text, version))
}

fn document_change_request<'request>(
    message: &'request Value,
    uri: &str,
) -> Option<DocumentChangeRequest<'request>> {
    let changes = message
        .pointer("/params/contentChanges")
        .and_then(Value::as_array)?;
    let version = message
        .pointer("/params/textDocument/version")
        .and_then(Value::as_i64)?;
    Some(DocumentChangeRequest {
        uri: uri.to_owned(),
        path: None,
        version,
        changes,
    })
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
