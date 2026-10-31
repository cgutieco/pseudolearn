use crate::completion::CompletionKind;
use crate::navigation::{Position, Range};
use crate::positions::{lsp_position_at_with_index, offset_at, offset_from_lsp, position_at};
use pseudolearn_source::LineIndex;
use serde_json::{Value, json};

pub const SERVER_NOT_INITIALIZED: i64 = -32002;
pub const INVALID_REQUEST: i64 = -32600;
pub const METHOD_NOT_FOUND: i64 = -32601;
pub const INVALID_PARAMS: i64 = -32602;
pub const CONTENT_MODIFIED: i64 = -32801;

pub fn request_id(message: &Value) -> Value {
    message.get("id").cloned().unwrap_or(Value::Null)
}

pub fn success(message: &Value, result: Value) -> Value {
    json!({ "jsonrpc": "2.0", "id": request_id(message), "result": result })
}

pub fn failure(message: &Value, code: i64, text: &str) -> Value {
    json!({
        "jsonrpc": "2.0",
        "id": request_id(message),
        "error": { "code": code, "message": text }
    })
}

pub fn text_document_uri(message: &Value) -> &str {
    message
        .pointer("/params/textDocument/uri")
        .and_then(Value::as_str)
        .unwrap_or("")
}

pub fn position_from_request(text: &str, message: &Value) -> Position {
    let line = message
        .pointer("/params/position/line")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let character = message
        .pointer("/params/position/character")
        .and_then(Value::as_u64)
        .unwrap_or(0);
    let offset = offset_from_lsp(
        text,
        u32::try_from(line).unwrap_or(u32::MAX),
        u32::try_from(character).unwrap_or(u32::MAX),
    );
    position_at(text, offset)
}

pub fn lsp_range_from_offsets(text: &str, start: usize, ending: usize) -> Value {
    let index = LineIndex::build(text);
    lsp_range_from_offsets_with_index(text, start, ending, &index)
}

pub(crate) fn lsp_range_from_offsets_with_index(
    text: &str,
    start: usize,
    ending: usize,
    index: &LineIndex,
) -> Value {
    let (start_line, start_character) = lsp_position_at_with_index(text, start, index);
    let (end_line, end_character) = lsp_position_at_with_index(text, ending, index);
    json!({
        "start": { "line": start_line, "character": start_character },
        "end": { "line": end_line, "character": end_character }
    })
}

pub fn lsp_range(text: &str, range: Range) -> Value {
    lsp_range_from_offsets(
        text,
        offset_at(text, range.start),
        offset_at(text, range.end),
    )
}

pub fn completion_kind_code(kind: CompletionKind) -> u64 {
    match kind {
        CompletionKind::Keyword => 14,
        CompletionKind::Type | CompletionKind::Class => 7,
        CompletionKind::Variable => 6,
        CompletionKind::Function => 3,
        CompletionKind::Method => 2,
        CompletionKind::Field => 5,
        CompletionKind::Snippet => 15,
    }
}
