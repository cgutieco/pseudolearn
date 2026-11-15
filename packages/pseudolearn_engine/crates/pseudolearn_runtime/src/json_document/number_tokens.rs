use crate::MemoryError;

pub(super) fn scan_number_tokens(source: &str) -> Result<Vec<String>, MemoryError> {
    let mut tokens = Vec::new();
    let mut cursor = 0usize;
    let mut inside_string = false;
    let mut escaped = false;
    while let Some(byte) = source.as_bytes().get(cursor).copied() {
        match (inside_string, byte) {
            (true, value) => update_string_state(value, (&mut inside_string, &mut escaped)),
            (false, b'"') => inside_string = true,
            (false, b'-' | b'0'..=b'9') => {
                let end = number_end(source.as_bytes(), cursor)?;
                let token = source
                    .get(cursor..end)
                    .ok_or(MemoryError::Internal)?
                    .to_owned();
                tokens.try_reserve(1).map_err(|_| MemoryError::Resource)?;
                tokens.push(token);
                cursor = end;
                continue;
            }
            _ => {}
        }
        cursor = cursor.checked_add(1).ok_or(MemoryError::Resource)?;
    }
    Ok(tokens)
}

fn update_string_state(byte: u8, state: (&mut bool, &mut bool)) {
    let (inside_string, escaped) = state;
    if *escaped {
        *escaped = false;
    } else if byte == b'\\' {
        *escaped = true;
    } else if byte == b'"' {
        *inside_string = false;
    }
}

fn number_end(source: &[u8], start: usize) -> Result<usize, MemoryError> {
    let mut end = start;
    while let Some(byte) = source.get(end).copied() {
        if matches!(byte, b',' | b']' | b'}' | b' ' | b'\t' | b'\n' | b'\r') {
            return Ok(end);
        }
        end = end.checked_add(1).ok_or(MemoryError::Resource)?;
    }
    Ok(end)
}
