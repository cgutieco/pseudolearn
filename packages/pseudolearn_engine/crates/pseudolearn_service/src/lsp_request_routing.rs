use crate::lsp_protocol::METHOD_NOT_FOUND;
use crate::lsp_session::{LspServer, refuse};
use serde_json::Value;

impl LspServer {
    pub(crate) fn route_request(
        &mut self,
        method: &str,
        message: &Value,
        is_request: bool,
    ) -> Vec<Value> {
        let response = match method {
            "textDocument/completion" => self.handle_completion(message),
            "textDocument/hover" => self.handle_hover(message),
            "textDocument/signatureHelp" => self.handle_signature_help(message),
            "textDocument/definition" => self.handle_definition(message),
            "textDocument/references" => self.handle_references(message),
            "textDocument/documentHighlight" => self.handle_highlight(message),
            "textDocument/documentSymbol" => self.handle_document_symbols(message),
            "workspace/symbol" => self.project_workspace_symbols(message),
            "textDocument/prepareRename" => self.handle_prepare_rename(message),
            "textDocument/rename" => self.handle_rename(message),
            "textDocument/semanticTokens/full" => self.handle_semantic_tokens(message),
            "textDocument/formatting" => self.handle_formatting(message),
            "textDocument/onTypeFormatting" => self.handle_on_type_formatting(message),
            "workspace/executeCommand" => self.handle_execute_command(message),
            _ => return refuse(message, is_request, METHOD_NOT_FOUND, "method not found"),
        };
        vec![response]
    }
}
