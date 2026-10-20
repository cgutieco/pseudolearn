use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_service::{CompletionEntry, EditError, Insertion, StopRange, TextChange};
use serde_json::{Value, json};

pub(crate) fn offset_text(arguments: &Value, name: &str) -> Result<usize, ApiError> {
    arguments
        .get(name)
        .and_then(Value::as_str)
        .and_then(|value| value.parse::<usize>().ok())
        .ok_or_else(|| usage(&format!("invalid {name}")))
}

pub(crate) fn revision_of(arguments: &Value) -> Result<u64, ApiError> {
    arguments
        .get("revision")
        .and_then(Value::as_str)
        .and_then(|value| value.parse::<u64>().ok())
        .ok_or_else(|| usage("invalid revision"))
}

pub(crate) fn parse_changes(arguments: &Value) -> Result<Vec<TextChange>, ApiError> {
    let rows = arguments
        .get("edits")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing edits"))?;
    rows.iter()
        .map(|row| {
            let text = row
                .get("text")
                .and_then(Value::as_str)
                .ok_or_else(|| usage("missing edit text"))?;
            Ok(TextChange {
                start_utf8: offset_text(row, "start_utf8")?,
                end_utf8: offset_text(row, "end_utf8")?,
                text: text.to_owned(),
            })
        })
        .collect()
}

pub(crate) fn change_json(change: &TextChange) -> Value {
    json!({
        "start_utf8": change.start_utf8.to_string(),
        "end_utf8": change.end_utf8.to_string(),
        "text": change.text
    })
}

pub(crate) fn candidate_json(id: usize, entry: &CompletionEntry) -> Value {
    json!({
        "id": id.to_string(),
        "label": entry.label,
        "kind": entry.kind,
        "detail": entry.detail,
        "detail_key": entry.detail_key,
        "detail_arguments": entry.detail_arguments,
        "insert_text": entry.insert_text,
        "bilingual_origin": entry.bilingual_origin,
        "inline": entry.inline
    })
}

fn stop_json(stop: &StopRange) -> Value {
    json!({
        "index": stop.index,
        "role": stop.role.name(),
        "start_utf8": stop.start.to_string(),
        "end_utf8": stop.end.to_string()
    })
}

pub(crate) fn insertion_json(insertion: &Insertion, revision: u64, active: bool) -> Value {
    let stops: Vec<Value> = insertion.stops.iter().map(stop_json).collect();
    json!({
        "revision": revision.to_string(),
        "template_active": active,
        "edit": change_json(&insertion.edit),
        "stops": stops,
        "final_utf8": insertion.final_offset.to_string(),
        "selection": {
            "start_utf8": insertion.selection.0.to_string(),
            "end_utf8": insertion.selection.1.to_string()
        },
        "lsp_snippet": insertion.lsp_snippet
    })
}

pub(crate) fn failed(error: EditError) -> Result<Value, ApiError> {
    match error {
        EditError::StaleRevision { current } => {
            Ok(json!({ "stale_revision": current.to_string() }))
        }
        EditError::InvalidCursor => Err(usage("cursor is not a UTF-8 boundary")),
        EditError::UnknownCandidate => Err(usage("unknown candidate")),
        EditError::NoTemplateSession => Err(usage("no template session")),
    }
}
