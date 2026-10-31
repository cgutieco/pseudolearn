use crate::document_session::LanguageService;
use crate::request_cancellation::RequestCancellation;
use crate::workspace_session::WorkspaceSession;
use pseudolearn_lexicon::Profile;
use serde_json::Value;
use std::collections::BTreeMap;

pub const SEMANTIC_TOKEN_TYPES: [&str; 11] = [
    "keyword",
    "operator",
    "number",
    "string",
    "comment",
    "variable",
    "function",
    "class",
    "property",
    "parameter",
    "type",
];

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Lifecycle {
    Uninitialized,
    Running,
    ShuttingDown,
    Exited,
}

pub struct LspServer {
    pub service: LanguageService,
    pub lifecycle: Lifecycle,
    pub locale: String,
    pub profile: Profile,
    pub versions: BTreeMap<String, i64>,
    pub strict: bool,
    pub exit_code: Option<i32>,
    pub workspace_session: Option<WorkspaceSession>,
    pub workspace_uris: BTreeMap<String, String>,
    pub workspace_paths: BTreeMap<String, String>,
    pub client_snippets: bool,
    pub client_related_information: bool,
    pub client_document_changes: bool,
    pub client_transactional_edits: bool,
    pub client_workspace_folders: bool,
    pub client_semantic_tokens: bool,
    pub(crate) active_cancellation: Option<RequestCancellation>,
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
            lifecycle: Lifecycle::Uninitialized,
            locale: String::from("es"),
            profile: Profile::Spanish,
            versions: BTreeMap::new(),
            strict: true,
            exit_code: None,
            workspace_session: None,
            workspace_uris: BTreeMap::new(),
            workspace_paths: BTreeMap::new(),
            client_snippets: false,
            client_related_information: false,
            client_document_changes: false,
            client_transactional_edits: false,
            client_workspace_folders: false,
            client_semantic_tokens: false,
            active_cancellation: None,
        }
    }

    pub fn is_finished(&self) -> bool {
        self.lifecycle == Lifecycle::Exited
    }

    pub fn handle_message(&mut self, message: &Value) -> Vec<Value> {
        let Some(method) = valid_method(message) else {
            return vec![crate::lsp_protocol::failure(
                message,
                crate::lsp_protocol::INVALID_REQUEST,
                "invalid request",
            )];
        };
        self.handle_valid_message(method, message)
    }

    fn handle_valid_message(&mut self, method: &str, message: &Value) -> Vec<Value> {
        if method == "exit" {
            self.finish();
            return Vec::new();
        }
        if method == "initialize" {
            return vec![self.handle_initialize(message)];
        }
        self.handle_running_message(method, message)
    }

    fn handle_running_message(&mut self, method: &str, message: &Value) -> Vec<Value> {
        let is_request = message.get("id").is_some();
        if self.lifecycle == Lifecycle::Uninitialized {
            return refuse(
                message,
                is_request,
                crate::lsp_protocol::SERVER_NOT_INITIALIZED,
                "server not initialized",
            );
        }
        if self.lifecycle != Lifecycle::Running {
            return refuse(
                message,
                is_request,
                crate::lsp_protocol::INVALID_REQUEST,
                "server is shutting down",
            );
        }
        match method {
            "initialized" => Vec::new(),
            "shutdown" => {
                self.lifecycle = Lifecycle::ShuttingDown;
                vec![crate::lsp_protocol::success(message, Value::Null)]
            }
            "textDocument/didOpen" => self.handle_did_open(message),
            "textDocument/didChange" => self.handle_did_change(message),
            "textDocument/didClose" => self.handle_did_close(message),
            "textDocument/didSave" | "workspace/didChangeWorkspaceFolders" => Vec::new(),
            "pseudolearn/workspaceSnapshot" => self.handle_workspace_snapshot(message),
            "workspace/didChangeConfiguration" => self.handle_configuration_change(message),
            _ => self.route_request(method, message, is_request),
        }
    }

    fn finish(&mut self) {
        self.exit_code = Some(if self.lifecycle == Lifecycle::ShuttingDown {
            0
        } else {
            1
        });
        self.lifecycle = Lifecycle::Exited;
    }

    fn handle_workspace_snapshot(&mut self, message: &Value) -> Vec<Value> {
        let Some(request_parameters) = message.get("params") else {
            return Vec::new();
        };
        if crate::lsp_workspace::install_snapshot(self, request_parameters).is_err() {
            return Vec::new();
        }
        self.workspace_diagnostics_notifications()
    }

    pub fn handle_cancellable_message(
        &mut self,
        message: &Value,
        cancellation: RequestCancellation,
    ) -> Vec<Value> {
        self.active_cancellation = Some(cancellation);
        let responses = self.handle_message(message);
        self.active_cancellation = None;
        responses
    }

    pub(crate) fn request_cancelled(&self) -> bool {
        self.active_cancellation
            .as_ref()
            .is_some_and(RequestCancellation::is_cancelled)
    }
}

fn valid_method(message: &Value) -> Option<&str> {
    if message.get("jsonrpc").and_then(Value::as_str) != Some("2.0") {
        return None;
    }
    message.get("method").and_then(Value::as_str)
}

pub(crate) fn refuse(message: &Value, is_request: bool, code: i64, text: &str) -> Vec<Value> {
    if is_request {
        vec![crate::lsp_protocol::failure(message, code, text)]
    } else {
        Vec::new()
    }
}
