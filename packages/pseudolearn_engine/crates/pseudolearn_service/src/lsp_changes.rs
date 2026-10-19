use crate::positions::offset_from_lsp;
use serde_json::Value;

pub fn apply_content_changes(current_text: &str, changes: &[Value]) -> String {
    let mut updated = current_text.to_owned();
    for change in changes {
        let new_text = change.get("text").and_then(Value::as_str).unwrap_or("");
        updated = match change.get("range") {
            Some(range) => apply_range_change(&updated, range, new_text),
            None => new_text.to_owned(),
        };
    }
    updated
}

fn coordinate(range: &Value, pointer: &str) -> u32 {
    range
        .pointer(pointer)
        .and_then(Value::as_u64)
        .and_then(|value| u32::try_from(value).ok())
        .unwrap_or(0)
}

fn apply_range_change(text: &str, range: &Value, new_text: &str) -> String {
    let start = offset_from_lsp(
        text,
        coordinate(range, "/start/line"),
        coordinate(range, "/start/character"),
    );
    let ending = offset_from_lsp(
        text,
        coordinate(range, "/end/line"),
        coordinate(range, "/end/character"),
    )
    .max(start);
    let head = text.get(..start).unwrap_or("");
    let tail = text.get(ending..).unwrap_or("");
    format!("{head}{new_text}{tail}")
}
