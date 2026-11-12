use crate::lsp_line_indexes::LineIndexCache;
use crate::lsp_project_selection::{
    SelectedSymbol, identifier_range, lsp_range, to_index, whole_identifier,
};
use crate::lsp_protocol::failure;
use crate::lsp_session::LspServer;
use crate::workspace_session::WorkspaceSession;
use pseudolearn_lexicon::{Profile, is_reserved};
use pseudolearn_semantic::{ServiceAnalysis, ServiceSymbolTarget};
use pseudolearn_source::IdentifierNormalizer;
use serde_json::{Value, json};
use std::collections::BTreeSet;

struct ProjectRenameContext<'request> {
    server: &'request LspServer,
    workspace: &'request WorkspaceSession,
    selected: &'request SelectedSymbol,
    new_name: &'request str,
    message: &'request Value,
}

struct VersionedRenameEdit<'edit> {
    document_uri: &'edit str,
    version: i64,
    range: Value,
    new_name: &'edit str,
}

impl LspServer {
    pub(crate) fn prepare_project_rename(&self, uri: &str, message: &Value) -> Option<Value> {
        let selected = self.selected_project_symbol(uri, message)?;
        let (_, text) = self
            .workspace_session
            .as_ref()?
            .file_by_source_id(selected.source_id.value())?;
        Some(json!({
            "jsonrpc":"2.0",
            "id":message.get("id"),
            "result":{"range":lsp_range(text, selected.range.0, selected.range.1),"placeholder":selected.name}
        }))
    }

    pub(crate) fn rename_project_symbol(&self, uri: &str, message: &Value) -> Option<Value> {
        if !self.client_document_changes || !self.client_transactional_edits {
            return Some(request_failed(
                message,
                "client cannot apply a transactional document edit",
            ));
        }
        let selected = self.selected_project_symbol(uri, message)?;
        let new_name = message.pointer("/params/newName").and_then(Value::as_str)?;
        if !IdentifierNormalizer::is_valid_identifier(new_name)
            || self.reserved_in_affected_profiles(&selected, new_name)
        {
            return Some(reject_invalid_arguments(
                message,
                "new name is invalid or reserved",
            ));
        }
        if self.project_name_collides(selected.target, new_name) {
            return Some(reject_invalid_arguments(
                message,
                "new name collides with a visible symbol",
            ));
        }
        Some(
            match self.build_project_document_changes(&selected, new_name, message) {
                Ok(edits) => edits,
                Err(response) => response,
            },
        )
    }

    fn build_project_document_changes(
        &self,
        selected: &SelectedSymbol,
        new_name: &str,
        message: &Value,
    ) -> Result<Value, Value> {
        let workspace = self
            .workspace_session
            .as_ref()
            .ok_or_else(|| request_failed(message, "workspace snapshot is unavailable"))?;
        let analysis = workspace
            .result()
            .service_analysis
            .as_ref()
            .ok_or_else(|| request_failed(message, "workspace analysis is unavailable"))?;
        let context = ProjectRenameContext {
            server: self,
            workspace,
            selected,
            new_name,
            message,
        };
        let edits = collect_document_changes(&context, analysis)?;
        Ok(json!({"jsonrpc":"2.0","id":message.get("id"),"result":{"documentChanges":edits}}))
    }

    fn reserved_in_affected_profiles(&self, selected: &SelectedSymbol, new_name: &str) -> bool {
        let Some(analysis) = self
            .workspace_session
            .as_ref()
            .and_then(|workspace| workspace.result().service_analysis.as_ref())
        else {
            return true;
        };
        analysis
            .references_for_target(selected.target)
            .iter()
            .any(|reference| {
                let profile = analysis
                    .module
                    .source_profiles
                    .get(&reference.span.source_id)
                    .copied()
                    .unwrap_or(Profile::Spanish);
                is_reserved(new_name, profile)
            })
    }

    fn project_name_collides(&self, target: ServiceSymbolTarget, new_name: &str) -> bool {
        let Some(analysis) = self
            .workspace_session
            .as_ref()
            .and_then(|workspace| workspace.result().service_analysis.as_ref())
        else {
            return true;
        };
        crate::lsp_project_collisions::target_collides(analysis, target, new_name)
    }
}

#[derive(Default)]
struct EditCollector {
    changes: Vec<Value>,
    seen: BTreeSet<(u32, usize, usize)>,
    indexes: LineIndexCache,
}

fn collect_document_changes(
    context: &ProjectRenameContext<'_>,
    analysis: &ServiceAnalysis,
) -> Result<Vec<Value>, Value> {
    let mut collector = EditCollector::default();
    for reference in analysis.references_for_target(context.selected.target) {
        if context.server.request_cancelled() {
            return Err(failure(context.message, -32800, "request cancelled"));
        }
        append_versioned_edit(context, &reference, &mut collector)?;
    }
    Ok(collector.changes)
}

fn append_versioned_edit(
    context: &ProjectRenameContext<'_>,
    reference: &pseudolearn_semantic::ServiceReference,
    collector: &mut EditCollector,
) -> Result<(), Value> {
    let source_id = reference.span.source_id.value();
    let (text, document_uri, version) = affected_document(context, source_id)?;
    let edit_range = reference_edit_range(text, reference, context.selected).map_err(|()| {
        request_failed(
            context.message,
            "a reference span does not hold an identifier",
        )
    })?;
    let Some((start, ending)) = edit_range else {
        return Ok(());
    };
    if !collector.seen.insert((source_id, start, ending)) {
        return Ok(());
    }
    let range = collector.indexes.range(source_id, text, (start, ending));
    add_versioned_edit(
        &mut collector.changes,
        VersionedRenameEdit {
            document_uri,
            version,
            range,
            new_name: context.new_name,
        },
    );
    Ok(())
}

fn affected_document<'context>(
    context: &ProjectRenameContext<'context>,
    source_id: u32,
) -> Result<(&'context str, &'context str, i64), Value> {
    let Some((path, text)) = context.workspace.file_by_source_id(source_id) else {
        return Err(request_failed(
            context.message,
            "workspace snapshot has no source for an affected reference",
        ));
    };
    let Some(document_uri) = context.server.uri_for_path(path) else {
        return Err(request_failed(
            context.message,
            "workspace snapshot has no document uri",
        ));
    };
    let Some(version) = context.server.versions.get(document_uri).copied() else {
        return Err(request_failed(
            context.message,
            "all affected documents must be synchronized and open",
        ));
    };
    Ok((text, document_uri, version))
}

fn reference_edit_range(
    text: &str,
    reference: &pseudolearn_semantic::ServiceReference,
    selected: &SelectedSymbol,
) -> Result<Option<(usize, usize)>, ()> {
    let span = (
        to_index(reference.span.start),
        to_index(reference.span.ending),
    );
    let exact = identifier_range(text, span, &selected.name, !reference.is_declaration);
    if exact.is_some() {
        return Ok(exact);
    }
    if whole_identifier(text, span).is_some() {
        return Ok(None);
    }
    Err(())
}

fn add_versioned_edit(changes: &mut Vec<Value>, request: VersionedRenameEdit<'_>) {
    let edit = json!({"range":request.range,"newText":request.new_name});
    let existing = changes.iter_mut().find(|change| {
        change.pointer("/textDocument/uri").and_then(Value::as_str) == Some(request.document_uri)
    });
    if let Some(change) = existing {
        if let Some(edits) = change["edits"].as_array_mut() {
            edits.push(edit);
        }
    } else {
        changes.push(json!({
            "textDocument":{"uri":request.document_uri,"version":request.version},
            "edits":[edit]
        }));
    }
}

fn request_failed(message: &Value, text: &str) -> Value {
    json!({"jsonrpc":"2.0","id":message.get("id"),"error":{"code":-32803,"message":text}})
}

fn reject_invalid_arguments(message: &Value, text: &str) -> Value {
    json!({"jsonrpc":"2.0","id":message.get("id"),"error":{"code":-32602,"message":text}})
}
