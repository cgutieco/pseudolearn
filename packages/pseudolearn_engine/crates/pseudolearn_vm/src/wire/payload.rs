#![forbid(unsafe_code)]

use crate::events::{EventPayload, TraceClass};

pub(crate) fn parse_payload(class: TraceClass, slice: &str) -> Result<EventPayload, &'static str> {
    match class {
        TraceClass::Decision => parse_decision(slice),
        TraceClass::Call => {
            let value = extract_field_value(slice, "nombre")?;
            Ok(EventPayload::Call {
                nombre: unescape_json_str(value)?,
            })
        }
        TraceClass::Return => {
            let value = extract_field_value(slice, "nombre")?;
            Ok(EventPayload::Return {
                nombre: unescape_json_str(value)?,
            })
        }
        TraceClass::Output => {
            let value = extract_field_value(slice, "texto")?;
            Ok(EventPayload::Output {
                texto: unescape_json_str(value)?,
            })
        }
        TraceClass::InputReceived => {
            let value = extract_field_value(slice, "texto")?;
            Ok(EventPayload::InputReceived {
                texto: unescape_json_str(value)?,
            })
        }
        TraceClass::Failure => {
            let value = extract_field_value(slice, "codigo")?;
            Ok(EventPayload::Failure {
                codigo: unescape_json_str(value)?,
            })
        }
        _ => Err("Class does not carry payload"),
    }
}

fn parse_decision(slice: &str) -> Result<EventPayload, &'static str> {
    if let Some(remainder) = slice.strip_prefix("{\"indice\":") {
        let comma_position = remainder
            .find(',')
            .ok_or("Decision missing comma after indice")?;
        let index_slice = remainder
            .get(..comma_position)
            .ok_or("Decision missing index slice")?;
        let index = index_slice
            .parse::<u64>()
            .map_err(|_| "Failed parsing decision index")?;
        let after_comma_offset = comma_position.saturating_add(1);
        let after_comma = remainder
            .get(after_comma_offset..)
            .ok_or("Decision missing branch after comma")?;
        let branch_value = extract_named_field(after_comma, "rama")?;
        Ok(EventPayload::Decision {
            rama: unescape_json_str(branch_value)?,
            indice: Some(index),
        })
    } else {
        let branch_value = extract_field_value(slice, "rama")?;
        Ok(EventPayload::Decision {
            rama: unescape_json_str(branch_value)?,
            indice: None,
        })
    }
}

fn extract_field_value<'slice>(slice: &'slice str, key: &str) -> Result<&'slice str, &'static str> {
    let remainder = slice.strip_prefix("{\"").ok_or("Malformed JSON start")?;
    extract_named_field(remainder, key)
}

fn extract_named_field<'slice>(slice: &'slice str, key: &str) -> Result<&'slice str, &'static str> {
    let key_part = slice.strip_prefix('"').unwrap_or(slice);
    let after_key = key_part
        .strip_prefix(key)
        .ok_or("Unexpected key in payload")?;
    let inner_end = after_key.len().saturating_sub(2);
    if !after_key.starts_with("\":\"") || !after_key.ends_with("\"}") {
        return Err("Malformed delimiters in payload");
    }
    after_key
        .get(3..inner_end)
        .ok_or("Malformed payload delimiters")
}

fn unescape_json_str(source: &str) -> Result<String, &'static str> {
    let mut result = String::new();
    let mut characters = source.chars();
    while let Some(character) = characters.next() {
        if character == '\\' {
            match characters.next() {
                Some('"') => result.push('"'),
                Some('\\') => result.push('\\'),
                Some('n') => result.push('\n'),
                Some('r') => result.push('\r'),
                Some('t') => result.push('\t'),
                _ => return Err("Invalid escape sequence"),
            }
        } else {
            result.push(character);
        }
    }
    Ok(result)
}
