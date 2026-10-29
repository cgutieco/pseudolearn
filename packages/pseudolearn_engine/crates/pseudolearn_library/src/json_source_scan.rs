#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

#[derive(Debug, Eq, PartialEq)]
pub struct ObjectFieldSpan {
    pub name: String,
    pub value_start: usize,
    pub value_end: usize,
}

pub fn scan_object_fields(source: &str) -> Result<Vec<ObjectFieldSpan>, MemoryError> {
    let bytes = source.as_bytes();
    if bytes.first() != Some(&b'{') || bytes.last() != Some(&b'}') {
        return Err(MemoryError::Internal);
    }
    let mut fields = Vec::new();
    let mut cursor = skip_whitespace(bytes, 1)?;
    if bytes.get(cursor) == Some(&b'}') {
        return Ok(fields);
    }
    loop {
        let key_end = scan_string_end(bytes, cursor)?;
        let key_text = source.get(cursor..key_end).ok_or(MemoryError::Internal)?;
        let name = serde_json::from_str(key_text).map_err(|_| MemoryError::Internal)?;
        let separator = skip_whitespace(bytes, key_end)?;
        if bytes.get(separator) != Some(&b':') {
            return Err(MemoryError::Internal);
        }
        let value_start = skip_whitespace(bytes, advance(separator, 1)?)?;
        let value_end = scan_value_end(bytes, value_start)?;
        fields.try_reserve(1).map_err(|_| MemoryError::Resource)?;
        fields.push(ObjectFieldSpan {
            name,
            value_start,
            value_end,
        });
        cursor = skip_whitespace(bytes, value_end)?;
        match bytes.get(cursor) {
            Some(b',') => cursor = skip_whitespace(bytes, advance(cursor, 1)?)?,
            Some(b'}') => return Ok(fields),
            _ => return Err(MemoryError::Internal),
        }
    }
}

fn scan_value_end(bytes: &[u8], start: usize) -> Result<usize, MemoryError> {
    match bytes.get(start) {
        Some(b'"') => scan_string_end(bytes, start),
        Some(b'{') | Some(b'[') => scan_container_end(bytes, start),
        Some(_) => scan_scalar_end(bytes, start),
        None => Err(MemoryError::Internal),
    }
}

fn scan_scalar_end(bytes: &[u8], start: usize) -> Result<usize, MemoryError> {
    let mut cursor = start;
    while let Some(byte) = bytes.get(cursor) {
        if matches!(byte, b',' | b'}' | b']' | b' ' | b'\t' | b'\n' | b'\r') {
            return Ok(cursor);
        }
        cursor = advance(cursor, 1)?;
    }
    Err(MemoryError::Internal)
}

fn scan_container_end(bytes: &[u8], start: usize) -> Result<usize, MemoryError> {
    let mut cursor = advance(start, 1)?;
    let mut depth = 1usize;
    while let Some(byte) = bytes.get(cursor).copied() {
        match byte {
            b'"' => cursor = scan_string_end(bytes, cursor)?,
            b'{' | b'[' => {
                depth = depth.checked_add(1).ok_or(MemoryError::Resource)?;
                cursor = advance(cursor, 1)?;
            }
            b'}' | b']' => {
                depth = depth.checked_sub(1).ok_or(MemoryError::Internal)?;
                cursor = advance(cursor, 1)?;
                if depth == 0 {
                    return Ok(cursor);
                }
            }
            _ => cursor = advance(cursor, 1)?,
        }
    }
    Err(MemoryError::Internal)
}

fn scan_string_end(bytes: &[u8], start: usize) -> Result<usize, MemoryError> {
    if bytes.get(start) != Some(&b'"') {
        return Err(MemoryError::Internal);
    }
    let mut cursor = advance(start, 1)?;
    let mut escaped = false;
    while let Some(byte) = bytes.get(cursor).copied() {
        cursor = advance(cursor, 1)?;
        match (escaped, byte) {
            (true, _) => escaped = false,
            (false, b'\\') => escaped = true,
            (false, b'"') => return Ok(cursor),
            _ => {}
        }
    }
    Err(MemoryError::Internal)
}

fn skip_whitespace(bytes: &[u8], start: usize) -> Result<usize, MemoryError> {
    let mut cursor = start;
    while matches!(bytes.get(cursor), Some(b' ' | b'\t' | b'\n' | b'\r')) {
        cursor = advance(cursor, 1)?;
    }
    Ok(cursor)
}

fn advance(position: usize, amount: usize) -> Result<usize, MemoryError> {
    position.checked_add(amount).ok_or(MemoryError::Resource)
}
