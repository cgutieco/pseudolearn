use crate::document_session::DocumentSession;
use crate::lsp_document_collisions::document_collision;
use crate::lsp_protocol::{
    failure, lsp_range_from_offsets, lsp_range_from_offsets_with_index, position_from_request,
    success, text_document_uri,
};
use crate::lsp_session::LspServer;
use crate::positions::offset_at;
use crate::symbol_index::NamedOccurrence;
use pseudolearn_lexicon::is_reserved;
use pseudolearn_semantic::ServiceSymbolTarget;
use pseudolearn_source::{IdentifierNormalizer, LineIndex};
use serde_json::{Value, json};
use std::collections::BTreeSet;

impl LspServer {
    pub(crate) fn handle_prepare_rename(&self, message: &Value) -> Value {
        if !self.client_document_changes || !self.client_transactional_edits {
            return failure(
                message,
                -32803,
                "client cannot apply a transactional document edit",
            );
        }
        let uri = text_document_uri(message);
        if self.workspace_session.is_some() && self.path_for_uri(uri).is_some() {
            return self
                .prepare_project_rename(uri, message)
                .unwrap_or_else(|| success(message, Value::Null));
        }
        let result = self.service.session(uri).and_then(|session| {
            let position = position_from_request(session.text(), message);
            let offset = offset_at(session.text(), position);
            let occurrence = session.index.at_offset(offset)?;
            let declaration = session.index.declaration_of(occurrence.target)?;
            let name = symbol_name(session, occurrence.target)?;
            Some(json!({
                "range":lsp_range_from_offsets(
                    session.text(),
                    usize::try_from(declaration.span.start).unwrap_or(0),
                    usize::try_from(declaration.span.ending).unwrap_or(0)
                ),
                "placeholder":name
            }))
        });
        success(message, result.unwrap_or(Value::Null))
    }

    pub(crate) fn handle_rename(&self, message: &Value) -> Value {
        if !self.client_document_changes || !self.client_transactional_edits {
            return failure(
                message,
                -32803,
                "client cannot apply a transactional document edit",
            );
        }
        let uri = text_document_uri(message);
        if self.workspace_session.is_some() && self.path_for_uri(uri).is_some() {
            return self.rename_project_symbol(uri, message).unwrap_or_else(|| {
                failure(
                    message,
                    -32602,
                    "no renamable symbol or new name at the position",
                )
            });
        }
        let result = self.service.session(uri).and_then(|session| {
            let version = self.versions.get(uri).copied()?;
            document_rename_result(session, message, uri, version)
        });
        match result {
            Some(edit) => success(message, edit),
            None => failure(
                message,
                -32602,
                "new name is invalid, reserved, or collides",
            ),
        }
    }
}

fn document_rename_result(
    session: &DocumentSession,
    message: &Value,
    uri: &str,
    version: i64,
) -> Option<Value> {
    let new_name = message.pointer("/params/newName")?.as_str()?;
    if !IdentifierNormalizer::is_valid_identifier(new_name)
        || is_reserved(new_name, session.profile)
    {
        return None;
    }
    let occurrence = selected_occurrence(session, message)?;
    if document_collision(session, occurrence, new_name) {
        return None;
    }
    Some(json!({"documentChanges":[{
        "textDocument":{"uri":uri,"version":version},
        "edits":document_edits(session, occurrence, new_name)
    }]}))
}

fn selected_occurrence<'session>(
    session: &'session DocumentSession,
    message: &Value,
) -> Option<&'session NamedOccurrence> {
    let position = position_from_request(session.text(), message);
    let offset = offset_at(session.text(), position);
    session.index.at_offset(offset)
}

fn document_edits(
    session: &DocumentSession,
    occurrence: &NamedOccurrence,
    new_name: &str,
) -> Vec<Value> {
    let index = LineIndex::build(session.text());
    let mut seen = BTreeSet::new();
    session
        .index
        .occurrences_of(occurrence.target)
        .into_iter()
        .filter(|candidate| seen.insert((candidate.span.start, candidate.span.ending)))
        .map(|candidate| {
            json!({
                "range":lsp_range_from_offsets_with_index(
                    session.text(),
                    usize::try_from(candidate.span.start).unwrap_or(0),
                    usize::try_from(candidate.span.ending).unwrap_or(0),
                    &index
                ),
                "newText":new_name
            })
        })
        .collect()
}

fn symbol_name(session: &DocumentSession, target: ServiceSymbolTarget) -> Option<String> {
    match target {
        ServiceSymbolTarget::Local(identifier) => session
            .analysis
            .module
            .locals
            .get(usize::try_from(identifier.0).ok()?)
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Function(identifier) => session
            .analysis
            .module
            .functions
            .get(usize::try_from(identifier.0).ok()?)
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Class(identifier) => session
            .analysis
            .module
            .classes
            .get(usize::try_from(identifier.0).ok()?)
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Field(identifier) => session
            .analysis
            .module
            .classes
            .iter()
            .flat_map(|candidate| &candidate.fields)
            .find(|candidate| candidate.id == identifier)
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Record(_)
        | ServiceSymbolTarget::Enum(_)
        | ServiceSymbolTarget::Interface(_)
        | ServiceSymbolTarget::Constant(_)
        | ServiceSymbolTarget::Template(_)
        | ServiceSymbolTarget::TypeParameter(_, _) => {
            crate::declared_names::declared_name(&session.analysis, target)
        }
        ServiceSymbolTarget::Builtin(_) => None,
    }
}
