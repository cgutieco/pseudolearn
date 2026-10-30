use crate::lsp_project_selection::{SelectedSymbol, identifier_range, lsp_range, to_index, to_u32};
use crate::lsp_protocol::failure;
use crate::lsp_session::LspServer;
use crate::workspace_session::WorkspaceSession;
use pseudolearn_semantic::{ServiceAnalysis, ServiceReference};
use pseudolearn_source::Span;
use serde_json::{Value, json};

struct ProjectReferenceContext<'request> {
    server: &'request LspServer,
    workspace: &'request WorkspaceSession,
    analysis: &'request ServiceAnalysis,
    selected: &'request SelectedSymbol,
    include_declaration: bool,
}

impl LspServer {
    pub(crate) fn project_definition(&self, uri: &str, message: &Value) -> Option<Value> {
        let selected = self.selected_project_symbol(uri, message)?;
        let workspace = self.workspace_session.as_ref()?;
        let analysis = workspace.result().service_analysis.as_ref()?;
        let definition = analysis.definition_span(selected.target)?;
        let (path, text) = workspace.file_by_source_id(definition.source_id.value())?;
        let definition_range = identifier_range(
            text,
            (to_index(definition.start), to_index(definition.ending)),
            &selected.name,
            false,
        )?;
        let target_uri = self.uri_for_path(path)?;
        Some(json!({
            "jsonrpc":"2.0",
            "id":message.get("id"),
            "result":{"uri":target_uri,"range":lsp_range(text, definition_range.0, definition_range.1)}
        }))
    }

    pub(crate) fn project_references(
        &self,
        uri: &str,
        message: &Value,
        include_declaration: bool,
    ) -> Option<Value> {
        let selected = self.selected_project_symbol(uri, message)?;
        let workspace = self.workspace_session.as_ref()?;
        let analysis = workspace.result().service_analysis.as_ref()?;
        let context = ProjectReferenceContext {
            server: self,
            workspace,
            analysis,
            selected: &selected,
            include_declaration,
        };
        let Some(locations) = collect_project_references(&context) else {
            return Some(failure(message, -32800, "request cancelled"));
        };
        Some(json!({
            "jsonrpc":"2.0",
            "id":message.get("id"),
            "result":locations
        }))
    }
}

fn collect_project_references(context: &ProjectReferenceContext<'_>) -> Option<Vec<Value>> {
    let definition = context.analysis.definition_span(context.selected.target);
    let mut locations = Vec::new();
    for reference in context
        .analysis
        .references_for_target(context.selected.target)
    {
        if context.server.request_cancelled() {
            return None;
        }
        if let Some(location) = project_reference_location(context, &reference, definition) {
            locations.push(location);
        }
    }
    Some(locations)
}

fn project_reference_location(
    context: &ProjectReferenceContext<'_>,
    reference: &ServiceReference,
    definition: Option<Span>,
) -> Option<Value> {
    if !context.include_declaration && reference.is_declaration {
        return None;
    }
    let (path, text) = context
        .workspace
        .file_by_source_id(reference.span.source_id.value())?;
    let (start, ending) = identifier_range(
        text,
        (
            to_index(reference.span.start),
            to_index(reference.span.ending),
        ),
        &context.selected.name,
        !reference.is_declaration,
    )?;
    if !context.include_declaration && definition_contains(definition, reference, start, ending) {
        return None;
    }
    let target_uri = context.server.uri_for_path(path)?;
    Some(json!({"uri":target_uri,"range":lsp_range(text,start,ending)}))
}

fn definition_contains(
    definition: Option<Span>,
    reference: &ServiceReference,
    start: usize,
    ending: usize,
) -> bool {
    definition.is_some_and(|span| {
        span.source_id == reference.span.source_id
            && span.start <= to_u32(start)
            && span.ending >= to_u32(ending)
    })
}
