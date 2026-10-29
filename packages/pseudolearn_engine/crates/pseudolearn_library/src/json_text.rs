#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;
use serde_json::Value;

pub fn parse_document(text: &str) -> Result<Value, MemoryError> {
    serde_json::from_str(text).map_err(|_| MemoryError::Internal)
}

pub fn compact_text(value: &Value) -> Result<String, MemoryError> {
    serde_json::to_string(value).map_err(|_| MemoryError::Internal)
}

pub fn normalize_text(text: &str) -> Result<String, MemoryError> {
    compact_source(text)
}

pub fn compact_source(text: &str) -> Result<String, MemoryError> {
    let mut output = String::with_capacity(text.len());
    let mut cursor = 0usize;
    while let Some(byte) = text.as_bytes().get(cursor).copied() {
        cursor = match byte {
            b' ' | b'\t' | b'\n' | b'\r' => advance(cursor, 1)?,
            b'"' => append_string(text, cursor, &mut output)?,
            b'-' | b'0'..=b'9' => append_number(text, cursor, &mut output)?,
            _ => {
                output.push(char::from(byte));
                advance(cursor, 1)?
            }
        };
    }
    Ok(output)
}

fn append_string(text: &str, start: usize, output: &mut String) -> Result<usize, MemoryError> {
    let mut cursor = advance(start, 1)?;
    let mut escaped = false;
    loop {
        let byte = text
            .as_bytes()
            .get(cursor)
            .copied()
            .ok_or(MemoryError::Internal)?;
        let (next_escaped, complete) = string_step(byte, escaped);
        if complete {
            let end = advance(cursor, 1)?;
            let source = text.get(start..end).ok_or(MemoryError::Internal)?;
            let decoded =
                serde_json::from_str::<String>(source).map_err(|_| MemoryError::Internal)?;
            let encoded = serde_json::to_string(&decoded).map_err(|_| MemoryError::Internal)?;
            output.push_str(&encoded);
            return Ok(end);
        }
        escaped = next_escaped;
        cursor = advance(cursor, 1)?;
    }
}

fn string_step(byte: u8, escaped: bool) -> (bool, bool) {
    match (escaped, byte) {
        (true, _) => (false, false),
        (false, b'\\') => (true, false),
        (false, b'"') => (false, true),
        _ => (false, false),
    }
}

fn append_number(text: &str, start: usize, output: &mut String) -> Result<usize, MemoryError> {
    let bytes = text.as_bytes();
    let mut end = advance(start, 1)?;
    while let Some(byte) = bytes.get(end).copied() {
        if matches!(byte, b',' | b']' | b'}' | b' ' | b'\t' | b'\n' | b'\r') {
            break;
        }
        end = advance(end, 1)?;
    }
    output.push_str(text.get(start..end).ok_or(MemoryError::Internal)?);
    Ok(end)
}

fn advance(position: usize, amount: usize) -> Result<usize, MemoryError> {
    position.checked_add(amount).ok_or(MemoryError::Resource)
}
