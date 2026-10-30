use crate::document_session::DocumentOptions;
use crate::lsp_session::LspServer;
use pseudolearn_lexicon::Profile;
use serde_json::Value;

struct RequestedConfiguration {
    profile: Option<Profile>,
    strict: Option<bool>,
}

impl LspServer {
    pub(crate) fn handle_configuration_change(&mut self, message: &Value) -> Vec<Value> {
        let requested = requested_configuration(message);
        self.apply_workspace_configuration(requested);
        self.refresh_configuration_diagnostics()
    }

    fn apply_workspace_configuration(&mut self, requested: RequestedConfiguration) {
        if let Some(profile) = requested.profile {
            self.profile = profile;
        }
        if let Some(strict) = requested.strict {
            self.strict = strict;
        }
        if let Some(workspace) = self.workspace_session.as_mut() {
            let _ = workspace.update_configuration(self.profile, self.strict);
        }
    }

    fn refresh_configuration_diagnostics(&mut self) -> Vec<Value> {
        let documents = self.open_document_settings();
        self.reopen_documents(&documents);
        self.publish_configuration_diagnostics(documents)
    }

    fn open_document_settings(&self) -> Vec<(String, String, Profile)> {
        self.service
            .documents()
            .map(|(uri, session)| {
                let text = session.text().to_owned();
                let profile = crate::lsp_documents::detect_document_profile(&text, self.profile);
                (uri.to_owned(), text, profile)
            })
            .collect()
    }

    fn reopen_documents(&mut self, documents: &[(String, String, Profile)]) {
        for (uri, text, profile) in documents {
            self.service.open_document(
                uri.clone(),
                text.clone(),
                DocumentOptions {
                    profile: *profile,
                    strict: self.strict,
                },
            );
        }
    }

    fn publish_configuration_diagnostics(
        &self,
        documents: Vec<(String, String, Profile)>,
    ) -> Vec<Value> {
        let mut notifications = self.workspace_diagnostics_notifications();
        notifications.extend(documents.iter().filter_map(|(uri, _, _)| {
            self.path_for_uri(uri)
                .is_none()
                .then(|| self.diagnostics_notification(uri))
                .flatten()
        }));
        notifications
    }
}

fn requested_configuration(message: &Value) -> RequestedConfiguration {
    let settings = message.pointer("/params/settings/pseudolearn");
    let profile = settings
        .and_then(|value| value.get("profile"))
        .and_then(Value::as_str)
        .and_then(Profile::from_name);
    let strict = match settings
        .and_then(|value| value.get("strictness"))
        .and_then(Value::as_str)
    {
        Some("strict") => Some(true),
        Some("flexible") => Some(false),
        _ => None,
    };
    RequestedConfiguration { profile, strict }
}
