use crate::errors::ApiError;
use pseudolearn_lexicon::Profile;
use pseudolearn_service::{
    DocumentSession, Position, get_template, template_constructions, template_parses_cleanly,
};
use pseudolearn_source::SourceText;
use serde_json::{Value, json};

struct CompletionRequest<'source> {
    program: &'source str,
    profile: Profile,
    strict: bool,
    revision: u64,
    position: Position,
}

pub(crate) fn complete(arguments: &Value) -> Result<Value, ApiError> {
    let request = completion_request(arguments)?;
    let session = DocumentSession::new(request.program.to_owned(), request.profile, request.strict);
    let result = session.queries().complete_with_edit(request.position);
    let candidates = serde_json::to_value(result.entries).map_err(serialization)?;
    Ok(json!({
        "revision": request.revision.to_string(),
        "text_edit": {
            "start_utf8": result.text_edit.start_utf8.to_string(),
            "end_utf8": result.text_edit.end_utf8.to_string()
        },
        "candidates": candidates
    }))
}

fn completion_request(arguments: &Value) -> Result<CompletionRequest<'_>, ApiError> {
    let program = arguments
        .get("program")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing program"))?;
    let profile_name = arguments
        .get("profile")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing profile"))?;
    let profile = Profile::from_name(profile_name).ok_or_else(|| usage("invalid profile"))?;
    let strictness = arguments
        .get("strictness")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing strictness"))?;
    if !matches!(strictness, "strict" | "flexible") {
        return Err(usage("invalid strictness"));
    }
    let revision = arguments
        .get("revision")
        .and_then(Value::as_str)
        .and_then(|value| value.parse::<u64>().ok())
        .ok_or_else(|| usage("invalid revision"))?;
    let position = completion_position(arguments, program)?;
    Ok(CompletionRequest {
        program,
        profile,
        strict: strictness == "strict",
        revision,
        position,
    })
}

fn completion_position(arguments: &Value, program: &str) -> Result<Position, ApiError> {
    let cursor = arguments
        .get("cursor_utf8")
        .and_then(Value::as_str)
        .and_then(|value| value.parse::<usize>().ok())
        .ok_or_else(|| usage("invalid cursor"))?;
    if program.get(..cursor).is_none() {
        return Err(usage("cursor is not a UTF-8 boundary"));
    }
    let cursor = u32::try_from(cursor).map_err(|_| usage("cursor is out of range"))?;
    let source = SourceText::new(program.to_owned());
    let (line, column) = source.line_and_column(cursor);
    Ok(Position { line, column })
}

pub(crate) fn templates(arguments: &Value) -> Result<Value, ApiError> {
    let profile_name = arguments
        .get("profile")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing profile"))?;
    let profile = Profile::from_name(profile_name).ok_or_else(|| usage("invalid profile"))?;
    let templates: Vec<Value> = template_constructions()
        .iter()
        .filter_map(|construction| {
            let template = get_template(construction, profile)?;
            let label = template.split_whitespace().next()?;
            if !template_parses_cleanly(construction, profile) {
                return None;
            }
            let family = family_of(construction);
            Some(json!({
                "construction": construction,
                "label": label,
                "template": template,
                "caret_offset": label.encode_utf16().count().saturating_add(1),
                "family": family
            }))
        })
        .collect();
    Ok(json!({"templates":templates}))
}

fn family_of(construction: &str) -> &'static str {
    match construction {
        "class" => "oop",
        "subroutine" | "function" => "procedural",
        _ => "structured",
    }
}

fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}

fn serialization(error: serde_json::Error) -> ApiError {
    ApiError::SerializationFailure(error.to_string())
}
