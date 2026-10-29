use crate::program_view::ViewNode;
use crate::program_view_annotations::{AnnotationContext, Attributes, first_token};
use pseudolearn_abi::{CapabilityKind, EFFECT_OPERATIONS};
use pseudolearn_semantic::capability_types::find_capability_kind;
use serde_json::json;

pub(crate) fn type_attributes(
    node: &ViewNode,
    context: &AnnotationContext<'_>,
) -> Option<Attributes> {
    let token = first_token(context.tree, node.syntax_index)?;
    let name = context.tree.tokens.text(context.source.as_str(), token)?;
    if let Some(kind) = find_capability_kind(name) {
        return Some(vec![("capability_type", json!(capability_identity(kind)))]);
    }
    match name {
        "Bytes" | "bytes" => Some(vec![("builtin_type", json!("bytes"))]),
        "ErrorES" | "IoError" => Some(vec![("builtin_type", json!("io_error"))]),
        "PeticionHttp" | "HttpRequest" => Some(vec![("builtin_type", json!("http_request"))]),
        "RespuestaHttp" | "HttpResponse" => Some(vec![("builtin_type", json!("http_response"))]),
        "MetodoHttp" | "HttpMethod" => Some(vec![("builtin_type", json!("http_method"))]),
        _ => None,
    }
}

pub(crate) fn operation_identity(operation: u32) -> Option<&'static str> {
    EFFECT_OPERATIONS
        .iter()
        .find(|candidate| candidate.id == operation)
        .map(|candidate| candidate.identity)
}

fn capability_identity(kind: CapabilityKind) -> &'static str {
    match kind {
        CapabilityKind::Console => "console",
        CapabilityKind::Arguments => "arguments",
        CapabilityKind::Directory => "directory",
        CapabilityKind::File => "file",
        CapabilityKind::Clock => "clock",
        CapabilityKind::Timer => "timer",
        CapabilityKind::Network => "network",
    }
}
