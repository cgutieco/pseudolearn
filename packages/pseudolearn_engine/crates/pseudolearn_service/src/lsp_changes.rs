use pseudolearn_source::LineIndex;
use serde_json::Value;

pub fn apply_content_changes(current_text: &str, changes: &[Value]) -> String {
    let mut updated = current_text.to_owned();
    for change in changes {
        let new_text = change.get("text").and_then(Value::as_str).unwrap_or("");
        if let Some(range_object) = change.get("range") {
            updated = apply_range_change(&updated, range_object, new_text);
        } else {
            updated = new_text.to_owned();
        }
    }
    updated
}

fn apply_range_change(updated: &str, range_object: &Value, new_text: &str) -> String {
    let start_line = range_object
        .pointer("/start/line")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let start_char = range_object
        .pointer("/start/character")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let end_line = range_object
        .pointer("/end/line")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let end_char = range_object
        .pointer("/end/character")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let indexer = LineIndex::build(updated);
    let start_line_offset = indexer
        .line_start(usize::try_from(start_line).unwrap_or(0))
        .unwrap_or(0);
    let end_line_offset = indexer
        .line_start(usize::try_from(end_line).unwrap_or(0))
        .unwrap_or(0);
    let start_offset =
        usize::try_from(start_line_offset.saturating_add(u32::try_from(start_char).unwrap_or(0)))
            .unwrap_or(0);
    let end_offset =
        usize::try_from(end_line_offset.saturating_add(u32::try_from(end_char).unwrap_or(0)))
            .unwrap_or(0);
    let prefix = updated.get(..start_offset).unwrap_or("");
    let suffix = updated.get(end_offset..).unwrap_or("");
    format!("{prefix}{new_text}{suffix}")
}
