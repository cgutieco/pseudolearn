use pseudolearn_api::service::{
    DocumentSession, HighlightKind, Position, Profile, Range, signature_help_at_position,
};
use serde_json::{Value, json};

pub fn parse_position_coordinate(request: &Value, pointer: &str) -> u32 {
    request
        .pointer(pointer)
        .and_then(Value::as_u64)
        .and_then(|value| u32::try_from(value).ok())
        .unwrap_or(1)
}

pub fn handle_definition(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
    if let Some(target_range) = session.definition(Position { line, column }) {
        json!({
            "definicion": {
                "start": { "line": target_range.start.line, "column": target_range.start.column },
                "end": { "line": target_range.end.line, "column": target_range.end.column }
            }
        })
    } else {
        json!({})
    }
}

pub fn handle_references(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
    let ranges = session.references(Position { line, column });
    let converted: Vec<Value> = ranges
        .into_iter()
        .map(|range: Range| {
            json!({
                "start": { "line": range.start.line, "column": range.start.column },
                "end": { "line": range.end.line, "column": range.end.column }
            })
        })
        .collect();
    json!({ "referencias": converted })
}

pub fn handle_highlight(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
    let highlights = session.highlights(Position { line, column });
    let converted: Vec<Value> = highlights
        .into_iter()
        .map(|highlight| {
            let kind_string = match highlight.kind {
                HighlightKind::Read => "read",
                HighlightKind::Write => "write",
                HighlightKind::Text => "text",
            };
            json!({
                "rango": {
                    "start": { "line": highlight.range.start.line, "column": highlight.range.start.column },
                    "end": { "line": highlight.range.end.line, "column": highlight.range.end.column }
                },
                "tipo": kind_string
            })
        })
        .collect();
    json!({ "destacados": converted })
}

pub fn handle_hover(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let strictness = request
        .get("strictness")
        .and_then(Value::as_str)
        .unwrap_or("strict");
    let is_strict = strictness != "flexible";
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, is_strict);

    if let Some(hover) = session.hover(Position { line, column }) {
        if hover.is_intrinsic {
            json!({
                "es_intrinseca": true,
                "identificador": hover.identifier
            })
        } else {
            json!({
                "tipo": hover.type_name,
                "inferido": hover.is_inferred
            })
        }
    } else {
        json!({})
    }
}

pub fn handle_signature_help(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
    if let Some(help) = signature_help_at_position(
        &session.analysis,
        &session.source,
        Position { line, column },
        Profile::Spanish,
    ) {
        json!({
            "parametro_activo": help.active_parameter,
            "firma": help.signature
        })
    } else {
        json!({})
    }
}
