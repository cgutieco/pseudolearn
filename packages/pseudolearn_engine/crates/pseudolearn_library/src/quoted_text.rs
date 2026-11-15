use pseudolearn_runtime::{Handle, Heap, MemoryError, new_text, text_content};

pub fn quote_text(
    heap: &mut Heap,
    handle: Handle,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let content = text_content(heap, handle)?;
    let mut quoted = String::new();
    let maximum = content
        .len()
        .checked_mul(10)
        .and_then(|count| count.checked_add(2))
        .ok_or(MemoryError::Resource)?;
    quoted
        .try_reserve(maximum)
        .map_err(|_| MemoryError::Resource)?;
    quoted.push('"');
    for character in content.chars() {
        match character {
            '"' => quoted.push_str("\\\""),
            '\\' => quoted.push_str("\\\\"),
            '\n' => quoted.push_str("\\n"),
            '\r' => quoted.push_str("\\r"),
            '\t' => quoted.push_str("\\t"),
            control if control.is_control() => quoted.extend(control.escape_unicode()),
            ordinary => quoted.push(ordinary),
        }
    }
    quoted.push('"');
    let mut retained = roots.to_vec();
    retained.push(handle);
    new_text(heap, &quoted, false, &retained)
}
