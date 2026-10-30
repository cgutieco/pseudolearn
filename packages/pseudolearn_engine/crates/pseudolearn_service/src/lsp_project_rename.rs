use crate::lsp_project_selection::{SelectedSymbol, identifier_range, lsp_range, to_index};
use crate::lsp_protocol::failure;
use crate::lsp_session::LspServer;
use crate::workspace_session::WorkspaceSession;
use pseudolearn_lexicon::{Profile, is_reserved};
use pseudolearn_semantic::{
    ClassId, FieldId, FunctionId, LocalId, ServiceAnalysis, ServiceSymbolTarget,
};
use pseudolearn_source::IdentifierNormalizer;
use serde_json::{Value, json};

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
        match target {
            ServiceSymbolTarget::Local(local) => local_collision(analysis, local, new_name),
            ServiceSymbolTarget::Function(function) => {
                function_collision(analysis, function, new_name)
            }
            ServiceSymbolTarget::Class(class) => class_collision(analysis, class, new_name),
            ServiceSymbolTarget::Field(field) => field_collision(analysis, field, new_name),
            ServiceSymbolTarget::Builtin(_) => true,
        }
    }
}

fn collect_document_changes(
    context: &ProjectRenameContext<'_>,
    analysis: &ServiceAnalysis,
) -> Result<Vec<Value>, Value> {
    let mut changes = Vec::new();
    for reference in analysis.references_for_target(context.selected.target) {
        if context.server.request_cancelled() {
            return Err(failure(context.message, -32800, "request cancelled"));
        }
        append_versioned_edit(context, &reference, &mut changes)?;
    }
    Ok(changes)
}

fn append_versioned_edit(
    context: &ProjectRenameContext<'_>,
    reference: &pseudolearn_semantic::ServiceReference,
    changes: &mut Vec<Value>,
) -> Result<(), Value> {
    let Some((path, text)) = context
        .workspace
        .file_by_source_id(reference.span.source_id.value())
    else {
        return Ok(());
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
    let Some(edit_range) = reference_edit_range(text, reference, context.selected) else {
        return Ok(());
    };
    add_versioned_edit(
        changes,
        VersionedRenameEdit {
            document_uri,
            version,
            range: edit_range,
            new_name: context.new_name,
        },
    );
    Ok(())
}

fn reference_edit_range(
    text: &str,
    reference: &pseudolearn_semantic::ServiceReference,
    selected: &SelectedSymbol,
) -> Option<Value> {
    let (start, ending) = identifier_range(
        text,
        (
            to_index(reference.span.start),
            to_index(reference.span.ending),
        ),
        &selected.name,
        !reference.is_declaration,
    )?;
    Some(lsp_range(text, start, ending))
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

fn local_collision(analysis: &ServiceAnalysis, local: LocalId, new_name: &str) -> bool {
    let position = to_index(local.0);
    let Some(current) = analysis.module.locals.get(position) else {
        return true;
    };
    analysis
        .module
        .locals
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && candidate.scope == current.scope
                && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn function_collision(analysis: &ServiceAnalysis, function: FunctionId, new_name: &str) -> bool {
    let position = to_index(function.0);
    let Some(current) = analysis.module.functions.get(position) else {
        return true;
    };
    let unit = analysis.module.units.function_unit(function);
    analysis
        .module
        .functions
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && IdentifierNormalizer::equals(&candidate.name, new_name)
                && candidate.owner == current.owner
                && analysis
                    .module
                    .units
                    .function_unit(FunctionId(u32::try_from(index).unwrap_or(u32::MAX)))
                    == unit
        })
}

fn class_collision(analysis: &ServiceAnalysis, class: ClassId, new_name: &str) -> bool {
    let position = to_index(class.0);
    let unit = analysis.module.units.class_unit(class);
    analysis
        .module
        .classes
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && IdentifierNormalizer::equals(&candidate.name, new_name)
                && analysis
                    .module
                    .units
                    .class_unit(ClassId(u32::try_from(index).unwrap_or(u32::MAX)))
                    == unit
        })
}

fn field_collision(analysis: &ServiceAnalysis, field: FieldId, new_name: &str) -> bool {
    analysis.module.classes.iter().any(|class| {
        class.fields.iter().any(|candidate| {
            candidate.id != field && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
    })
}

fn request_failed(message: &Value, text: &str) -> Value {
    json!({"jsonrpc":"2.0","id":message.get("id"),"error":{"code":-32803,"message":text}})
}

fn reject_invalid_arguments(message: &Value, text: &str) -> Value {
    json!({"jsonrpc":"2.0","id":message.get("id"),"error":{"code":-32602,"message":text}})
}
