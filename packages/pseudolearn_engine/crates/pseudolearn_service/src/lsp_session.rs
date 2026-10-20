use crate::document_session::LanguageService;
use crate::lsp_protocol::{
    INVALID_REQUEST, METHOD_NOT_FOUND, SERVER_NOT_INITIALIZED, failure, success,
};
use serde_json::{Value, json};

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
    pub strict: bool,
    pub exit_code: Option<i32>,
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
            strict: true,
            exit_code: None,
        }
    }

    pub fn is_finished(&self) -> bool {
        self.lifecycle == Lifecycle::Exited
    }

    pub fn handle_message(&mut self, message: &Value) -> Vec<Value> {
        let Some(method) = message.get("method").and_then(Value::as_str) else {
            return Vec::new();
        };
        let is_request = message.get("id").is_some();
        match method {
            "exit" => {
                self.exit_code = Some(if self.lifecycle == Lifecycle::ShuttingDown {
                    0
                } else {
                    1
                });
                self.lifecycle = Lifecycle::Exited;
                Vec::new()
            }
            "initialize" => vec![self.handle_initialize(message)],
            _ if self.lifecycle == Lifecycle::Uninitialized => refuse(
                message,
                is_request,
                SERVER_NOT_INITIALIZED,
                "server not initialized",
            ),
            _ if self.lifecycle != Lifecycle::Running => refuse(
                message,
                is_request,
                INVALID_REQUEST,
                "server is shutting down",
            ),
            "initialized" => Vec::new(),
            "shutdown" => {
                self.lifecycle = Lifecycle::ShuttingDown;
                vec![success(message, Value::Null)]
            }
            "textDocument/didOpen" => self.handle_did_open(message),
            "textDocument/didChange" => self.handle_did_change(message),
            "textDocument/didClose" => self.handle_did_close(message),
            _ => self.route_request(method, message, is_request),
        }
    }

    fn route_request(&mut self, method: &str, message: &Value, is_request: bool) -> Vec<Value> {
        let answer = match method {
            "textDocument/completion" => self.handle_completion(message),
            "textDocument/hover" => self.handle_hover(message),
            "textDocument/signatureHelp" => self.handle_signature_help(message),
            "textDocument/definition" => self.handle_definition(message),
            "textDocument/references" => self.handle_references(message),
            "textDocument/documentHighlight" => self.handle_highlight(message),
            "textDocument/documentSymbol" => self.handle_document_symbols(message),
            "textDocument/formatting" => self.handle_formatting(message),
            "textDocument/onTypeFormatting" => self.handle_on_type_formatting(message),
            _ => return refuse(message, is_request, METHOD_NOT_FOUND, "method not found"),
        };
        vec![answer]
    }

    fn handle_initialize(&mut self, message: &Value) -> Value {
        if let Some(locale) = message.pointer("/params/locale").and_then(Value::as_str) {
            self.locale = if locale.starts_with("en") { "en" } else { "es" }.to_owned();
        }
        if let Some(mode) = message
            .pointer("/params/initializationOptions/strictness")
            .and_then(Value::as_str)
        {
            self.strict = mode != "flexible";
        }
        self.lifecycle = Lifecycle::Running;
        success(
            message,
            json!({
                "capabilities": {
                    "textDocumentSync": { "openClose": true, "change": 2 },
                    "completionProvider": { "triggerCharacters": ["."], "resolveProvider": false },
                    "hoverProvider": true,
                    "signatureHelpProvider": { "triggerCharacters": ["(", ","] },
                    "definitionProvider": true,
                    "referencesProvider": true,
                    "documentHighlightProvider": true,
                    "documentSymbolProvider": true,
                    "documentFormattingProvider": true,
                    "onTypeFormattingProvider": {
                        "firstTriggerCharacter": "\n",
                        "moreTriggerCharacter": [" ", ";", "(", "[", ")", "]", "\"", "'"]
                    }
                },
                "serverInfo": { "name": "pseudolearn" }
            }),
        )
    }
}

fn refuse(message: &Value, is_request: bool, code: i64, text: &str) -> Vec<Value> {
    if is_request {
        vec![failure(message, code, text)]
    } else {
        Vec::new()
    }
}
