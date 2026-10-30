use crate::document_session::DocumentSession;
use crate::lsp_protocol::{
    failure, lsp_range_from_offsets, position_from_request, success, text_document_uri,
};
use crate::lsp_session::LspServer;
use crate::positions::offset_at;
use crate::symbol_index::NamedOccurrence;
use pseudolearn_lexicon::is_reserved;
use pseudolearn_semantic::ServiceSymbolTarget;
use pseudolearn_source::IdentifierNormalizer;
use serde_json::{Value, json};

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
        if self.workspace_session.is_some()
            && let Some(response) = self.prepare_project_rename(uri, message)
        {
            return response;
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
        if self.workspace_session.is_some()
            && let Some(response) = self.rename_project_symbol(uri, message)
        {
            return response;
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
    session
        .index
        .occurrences_of(occurrence.target)
        .into_iter()
        .map(|candidate| {
            json!({
                "range":lsp_range_from_offsets(
                    session.text(),
                    usize::try_from(candidate.span.start).unwrap_or(0),
                    usize::try_from(candidate.span.ending).unwrap_or(0)
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
        ServiceSymbolTarget::Builtin(_) => None,
    }
}

fn document_collision(
    session: &DocumentSession,
    occurrence: &NamedOccurrence,
    new_name: &str,
) -> bool {
    match occurrence.target {
        ServiceSymbolTarget::Local(identifier) => local_collision(session, identifier, new_name),
        ServiceSymbolTarget::Function(identifier) => {
            function_collision(session, identifier, new_name)
        }
        ServiceSymbolTarget::Class(identifier) => class_collision(session, identifier, new_name),
        ServiceSymbolTarget::Field(identifier) => field_collision(session, identifier, new_name),
        ServiceSymbolTarget::Builtin(_) => true,
    }
}

fn local_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::LocalId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    let Some(current) = session.analysis.module.locals.get(position) else {
        return true;
    };
    session
        .analysis
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

fn function_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::FunctionId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    let Some(current) = session.analysis.module.functions.get(position) else {
        return true;
    };
    session
        .analysis
        .module
        .functions
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && candidate.owner == current.owner
                && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn class_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::ClassId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    session
        .analysis
        .module
        .classes
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn field_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::FieldId,
    new_name: &str,
) -> bool {
    session.analysis.module.classes.iter().any(|class| {
        class.fields.iter().any(|candidate| {
            candidate.id != identifier && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
    })
}
