use crate::ApiError;
use crate::edit_session_wire::{
    candidate_json, change_json, failed, insertion_json, offset_text, parse_changes, revision_of,
};
use crate::execution_resource::usage;
use crate::resources::{ApiSession, Resource, identifier, parse_analysis};
use pseudolearn_lexicon::Profile;
use pseudolearn_service::{Acceptance, EditSession, StopDirection, StopNavigation};
use serde_json::{Value, json};

impl ApiSession {
    pub(crate) fn open_edit_session(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        for name in ["program", "profile", "strictness"] {
            if arguments.get(name).and_then(Value::as_str).is_none() {
                return Err(usage(&format!("missing {name}")));
            }
        }
        let request = parse_analysis(arguments)?;
        let profile =
            Profile::from_name(&request.profile).ok_or_else(|| usage("invalid profile"))?;
        if !matches!(request.strictness.as_str(), "strict" | "flexible") {
            return Err(usage("invalid strictness"));
        }
        let strict = request.strictness == "strict";
        let session = EditSession::new(request.program, profile, strict);
        let revision = session.revision;
        let resource = self.insert(Resource::Editing(Box::new(session)))?;
        Ok(json!({ "resource": resource, "revision": revision.to_string() }))
    }

    pub(crate) fn edit_operation(
        &mut self,
        operation: &str,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        let Some(Resource::Editing(session)) = self.resources.get_mut(&identifier(arguments)?)
        else {
            return Err(usage("invalid edit session"));
        };
        let revision = revision_of(arguments)?;
        match operation {
            "apply_edit" => apply_edit(session, revision, arguments),
            "edit_complete" => complete(session, revision, arguments),
            "edit_accept" => accept(session, revision, arguments),
            "edit_insert_template" => insert_template(session, revision, arguments),
            "edit_on_type" => typed(session, revision, arguments),
            _ => navigate(session, revision, arguments),
        }
    }
}

fn apply_edit(
    session: &mut EditSession,
    revision: u64,
    arguments: &Value,
) -> Result<Value, ApiError> {
    let edits = parse_changes(arguments)?;
    match session.apply_edits(revision, &edits) {
        Ok(next) => Ok(json!({
            "revision": next.to_string(),
            "template_active": session.template_active()
        })),
        Err(error) => failed(error),
    }
}

fn complete(
    session: &mut EditSession,
    revision: u64,
    arguments: &Value,
) -> Result<Value, ApiError> {
    let cursor = offset_text(arguments, "cursor_utf8")?;
    match session.complete(revision, cursor) {
        Ok(result) => {
            let rows: Vec<Value> = result
                .entries
                .iter()
                .enumerate()
                .map(|(slot, entry)| candidate_json(slot, entry))
                .collect();
            Ok(json!({
                "revision": revision.to_string(),
                "text_edit": {
                    "start_utf8": result.text_edit.start_utf8.to_string(),
                    "end_utf8": result.text_edit.end_utf8.to_string()
                },
                "candidates": rows
            }))
        }
        Err(error) => failed(error),
    }
}

fn accept(session: &mut EditSession, revision: u64, arguments: &Value) -> Result<Value, ApiError> {
    let candidate = offset_text(arguments, "candidate_id")?;
    match session.accept(revision, Acceptance::Candidate(candidate)) {
        Ok(accepted) => {
            let active = session.template_active();
            Ok(insertion_json(
                &accepted.insertion,
                accepted.revision,
                active,
            ))
        }
        Err(error) => failed(error),
    }
}

fn insert_template(
    session: &mut EditSession,
    revision: u64,
    arguments: &Value,
) -> Result<Value, ApiError> {
    let construction = arguments
        .get("construction")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing construction"))?;
    let acceptance = Acceptance::Template {
        construction,
        start: offset_text(arguments, "start_utf8")?,
        end: offset_text(arguments, "end_utf8")?,
    };
    match session.accept(revision, acceptance) {
        Ok(accepted) => {
            let active = session.template_active();
            Ok(insertion_json(
                &accepted.insertion,
                accepted.revision,
                active,
            ))
        }
        Err(error) => failed(error),
    }
}

fn typed(session: &mut EditSession, revision: u64, arguments: &Value) -> Result<Value, ApiError> {
    let cursor = offset_text(arguments, "cursor_utf8")?;
    let character = arguments
        .get("character")
        .and_then(Value::as_str)
        .and_then(|value| value.chars().next())
        .ok_or_else(|| usage("missing character"))?;
    match session.on_type(revision, cursor, character) {
        Ok((next, outcome)) => {
            let edits: Vec<Value> = outcome.edits.iter().map(change_json).collect();
            Ok(json!({
                "revision": next.to_string(),
                "template_active": session.template_active(),
                "edits": edits,
                "cursor_utf8": outcome.cursor.to_string()
            }))
        }
        Err(error) => failed(error),
    }
}

fn navigate(
    session: &mut EditSession,
    revision: u64,
    arguments: &Value,
) -> Result<Value, ApiError> {
    let direction = match arguments.get("direction").and_then(Value::as_str) {
        Some("next") => StopDirection::Next,
        Some("previous") => StopDirection::Previous,
        Some("exit") => StopDirection::Exit,
        _ => return Err(usage("invalid direction")),
    };
    match session.navigate_stop(revision, direction) {
        Ok(StopNavigation::Selected {
            index,
            start,
            end,
            role,
        }) => Ok(json!({
            "selection": {
                "index": index,
                "role": role.name(),
                "start_utf8": start.to_string(),
                "end_utf8": end.to_string()
            }
        })),
        Ok(StopNavigation::Exited { caret }) => {
            Ok(json!({ "exited": { "caret_utf8": caret.to_string() } }))
        }
        Err(error) => failed(error),
    }
}
