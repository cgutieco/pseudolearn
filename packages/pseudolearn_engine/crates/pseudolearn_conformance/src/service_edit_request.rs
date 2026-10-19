use crate::service_request::ServiceRequest;
use pseudolearn_api::service::{Position, Range, TextEdit};
use serde_json::Value;

pub fn edits_of(request: &ServiceRequest<'_>) -> Vec<TextEdit> {
    let raw = request.raw();
    let list: Vec<&Value> = match raw.get("ediciones").and_then(Value::as_array) {
        Some(items) => items.iter().collect(),
        None => raw.get("edicion").into_iter().collect(),
    };
    list.into_iter().map(edit_of).collect()
}

fn edit_of(value: &Value) -> TextEdit {
    let coordinate = |pointer: &str| {
        value
            .pointer(pointer)
            .and_then(Value::as_u64)
            .and_then(|number| u32::try_from(number).ok())
            .unwrap_or(1)
    };
    TextEdit {
        range: Range {
            start: Position {
                line: coordinate("/rango/start/line"),
                column: coordinate("/rango/start/column"),
            },
            end: Position {
                line: coordinate("/rango/end/line"),
                column: coordinate("/rango/end/column"),
            },
        },
        new_text: value
            .get("texto")
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned(),
    }
}
