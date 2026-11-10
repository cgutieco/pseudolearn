use crate::positions::offset_from_lsp;
use serde_json::Value;

pub fn apply_content_changes(current_text: &str, changes: &[Value]) -> Option<String> {
    let mut updated = current_text.to_owned();
    for change in changes {
        let new_text = change.get("text")?.as_str()?;
        updated = match change.get("range") {
            Some(range) => apply_range_change(&updated, range, new_text)?,
            None => new_text.to_owned(),
        };
    }
    Some(updated)
}

fn line_coordinate(range: &Value, pointer: &str) -> Option<u32> {
    u32::try_from(range.pointer(pointer)?.as_u64()?).ok()
}

fn character_coordinate(range: &Value, pointer: &str) -> Option<u32> {
    let value = range.pointer(pointer)?.as_u64()?;
    Some(u32::try_from(value).unwrap_or(u32::MAX))
}

fn apply_range_change(text: &str, range: &Value, new_text: &str) -> Option<String> {
    let start = offset_from_lsp(
        text,
        line_coordinate(range, "/start/line")?,
        character_coordinate(range, "/start/character")?,
    );
    let ending = offset_from_lsp(
        text,
        line_coordinate(range, "/end/line")?,
        character_coordinate(range, "/end/character")?,
    )
    .max(start);
    let head = text.get(..start).unwrap_or("");
    let tail = text.get(ending..).unwrap_or("");
    Some(format!("{head}{new_text}{tail}"))
}
