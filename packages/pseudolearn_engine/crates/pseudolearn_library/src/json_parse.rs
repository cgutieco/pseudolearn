#![forbid(unsafe_code)]

use pseudolearn_runtime::{JsonFailure, JsonResultValue, MemoryError};

pub fn parse_json(text: &str, maximum_depth: usize) -> Result<JsonResultValue, MemoryError> {
    if text.starts_with('\u{feff}') {
        return Ok(JsonResultValue::Error(JsonFailure {
            code: "invalidSyntax".to_owned(),
            line: 1,
            column: 1,
        }));
    }
    if let Err(error) = crate::json_parse_strings::validate(text, maximum_depth) {
        return Ok(JsonResultValue::Error(parse_error(&error)?));
    }
    crate::json_text::compact_source(text).map(JsonResultValue::Value)
}

fn parse_error(error: &serde_json::Error) -> Result<JsonFailure, MemoryError> {
    let description = error.to_string().to_lowercase();
    Ok(JsonFailure {
        code: error_code(error, &description).to_owned(),
        line: i64::try_from(error.line()).map_err(|_| MemoryError::Resource)?,
        column: i64::try_from(error.column().max(1)).map_err(|_| MemoryError::Resource)?,
    })
}

fn error_code(error: &serde_json::Error, description: &str) -> &'static str {
    if description.contains("json_duplicate_key") {
        return "duplicateKey";
    }
    if description.contains("json_depth_exceeded") {
        return "depthExceeded";
    }
    if description.contains("trailing characters") {
        return "trailingContent";
    }
    if invalid_escape(description) {
        return "invalidEscape";
    }
    if error.classify() == serde_json::error::Category::Eof {
        return "unexpectedEnd";
    }
    "invalidSyntax"
}

fn invalid_escape(description: &str) -> bool {
    description.contains("escape")
        || description.contains("surrogate")
        || description.contains("unicode code point")
}
