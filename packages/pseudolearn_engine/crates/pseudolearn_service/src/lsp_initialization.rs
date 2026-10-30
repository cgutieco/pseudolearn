use crate::lsp_help::EXPLAIN_COMMAND;
use crate::lsp_protocol::{INVALID_REQUEST, success};
use crate::lsp_session::{Lifecycle, LspServer, SEMANTIC_TOKEN_TYPES};
use pseudolearn_lexicon::Profile;
use serde_json::{Value, json};

impl LspServer {
    pub(crate) fn handle_initialize(&mut self, message: &Value) -> Value {
        if self.lifecycle != Lifecycle::Uninitialized {
            return crate::lsp_protocol::failure(
                message,
                INVALID_REQUEST,
                "initialize already received",
            );
        }
        self.negotiate_client_capabilities(message.pointer("/params/capabilities"));
        self.configure_initialization(message);
        self.lifecycle = Lifecycle::Running;
        success(
            message,
            json!({
                "capabilities": self.server_capabilities(),
                "serverInfo": { "name": "pseudolearn" }
            }),
        )
    }

    fn negotiate_client_capabilities(&mut self, client: Option<&Value>) {
        let client = client.unwrap_or(&Value::Null);
        self.client_snippets = capability_boolean(
            client,
            "/textDocument/completion/completionItem/snippetSupport",
        );
        self.client_related_information = capability_boolean(
            client,
            "/textDocument/publishDiagnostics/relatedInformation",
        );
        self.client_document_changes =
            capability_boolean(client, "/workspace/workspaceEdit/documentChanges");
        self.client_transactional_edits = client
            .pointer("/workspace/workspaceEdit/failureHandling")
            .and_then(Value::as_str)
            .is_some_and(|mode| matches!(mode, "transactional" | "textOnlyTransactional"));
        self.client_workspace_folders =
            capability_boolean(client, "/workspace/workspaceFolders/supported");
        self.client_semantic_tokens = client.pointer("/textDocument/semanticTokens").is_some();
    }

    fn configure_initialization(&mut self, message: &Value) {
        if let Some(locale) = initialization_locale(message) {
            self.locale = locale;
        }
        if let Some(strictness) = message
            .pointer("/params/initializationOptions/strictness")
            .and_then(Value::as_str)
        {
            self.strict = strictness != "flexible";
        }
        if let Some(profile) = message
            .pointer("/params/initializationOptions/profile")
            .and_then(Value::as_str)
            .and_then(Profile::from_name)
        {
            self.profile = profile;
        }
    }

    fn server_capabilities(&self) -> Value {
        let mut capabilities = base_capabilities();
        if self.client_document_changes && self.client_transactional_edits {
            insert_capability(
                &mut capabilities,
                "renameProvider",
                json!({"prepareProvider":true}),
            );
        }
        if let Some(values) = capabilities.as_object_mut()
            && !self.client_semantic_tokens
        {
            values.remove("semanticTokensProvider");
        }
        if self.client_workspace_folders {
            insert_capability(
                &mut capabilities,
                "workspace",
                json!({"workspaceFolders":{"supported":true,"changeNotifications":true}}),
            );
        }
        capabilities
    }
}

fn insert_capability(capabilities: &mut Value, name: &str, capability: Value) {
    if let Some(values) = capabilities.as_object_mut() {
        values.insert(name.to_owned(), capability);
    }
}

fn capability_boolean(client: &Value, path: &str) -> bool {
    client
        .pointer(path)
        .and_then(Value::as_bool)
        .unwrap_or(false)
}

fn initialization_locale(message: &Value) -> Option<String> {
    let locale = message
        .pointer("/params/locale")
        .and_then(Value::as_str)
        .or_else(|| {
            message
                .pointer("/params/initializationOptions/locale")
                .and_then(Value::as_str)
        })?;
    Some(if locale.starts_with("en") { "en" } else { "es" }.to_owned())
}

fn base_capabilities() -> Value {
    json!({
        "textDocumentSync": { "openClose": true, "change": 2, "save": {"includeText": false} },
        "completionProvider": { "triggerCharacters": ["."], "resolveProvider": false },
        "hoverProvider": true,
        "signatureHelpProvider": { "triggerCharacters": ["(", ","] },
        "definitionProvider": true,
        "referencesProvider": true,
        "documentHighlightProvider": true,
        "documentSymbolProvider": true,
        "workspaceSymbolProvider": true,
        "documentFormattingProvider": true,
        "semanticTokensProvider": {
            "legend": {"tokenTypes": SEMANTIC_TOKEN_TYPES, "tokenModifiers": []},
            "full": true
        },
        "executeCommandProvider": { "commands": [EXPLAIN_COMMAND] },
        "onTypeFormattingProvider": {
            "firstTriggerCharacter": "\n",
            "moreTriggerCharacter": [" ", ";", "(", "[", ")", "]", "\"", "'"]
        }
    })
}
