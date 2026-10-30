use crate::service_completion_edits::{handle_accept, handle_on_type, handle_stops};
use crate::service_edits::{handle_incremental, handle_node_identity, handle_random_probe};
use crate::service_queries::{
    handle_completion, handle_definition, handle_highlight, handle_hover, handle_references,
    handle_signature_help,
};
use crate::service_request::ServiceRequest;
use crate::service_text::{
    handle_format, handle_template, handle_template_validity, handle_translate,
    handle_translate_roundtrip,
};
use serde_json::{Value, json};

pub fn handle_service_request(raw: &Value) -> Value {
    let request = ServiceRequest::new(raw);
    match request.text("suboperacion") {
        "format" => handle_format(&request),
        "translate" => handle_translate(&request),
        "translate_roundtrip" => handle_translate_roundtrip(&request),
        "completion_template" => handle_template(&request),
        "template_validity" => handle_template_validity(&request),
        "completion" => handle_completion(&request),
        "completion_stops" => handle_stops(&request),
        "completion_accept" => handle_accept(&request),
        "on_type" => handle_on_type(&request),
        "hover" => handle_hover(&request),
        "signature_help" => handle_signature_help(&request),
        "definition" => handle_definition(&request),
        "references" => handle_references(&request),
        "highlight" => handle_highlight(&request),
        "incremental" => handle_incremental(&request),
        "node_identity" => handle_node_identity(&request),
        "random_probe" => handle_random_probe(&request),
        "workspace" => crate::service_workspace::handle(&request),
        "lsp" => crate::lsp_handler::handle_lsp(raw),
        other => json!({ "error": format!("unsupported service operation: {other}") }),
    }
}
