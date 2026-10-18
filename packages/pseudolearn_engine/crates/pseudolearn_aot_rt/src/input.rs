use crate::context::AotRuntimeContext;
use crate::engine::AotEngine;
use crate::fault::FaultRecord;
use crate::guard::{Entry, run_entry};
use crate::kinds::{KIND_BOOLEAN, KIND_CHARACTER, KIND_INTEGER, KIND_REAL, KIND_REFERENCE};
use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::new_text;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_read(context: *mut AotRuntimeContext, site: u32, kind: u32) -> u32 {
    run_entry(context, site, |entry| read_value(entry, kind))
}

fn read_value(entry: &mut Entry<'_>, kind: u32) -> Result<u64, Trap> {
    loop {
        let line = next_line(entry.engine)?;
        if let Some(word) = convert(entry, kind, &line)? {
            return Ok(word);
        }
        record_mismatch(entry, kind, &line);
    }
}

fn next_line(engine: &mut AotEngine) -> Result<String, Trap> {
    let mut line = String::new();
    let read = engine
        .streams
        .input
        .read_line(&mut line)
        .map_err(|_| Trap::exhausted_input())?;
    if read == 0 {
        return Err(Trap::exhausted_input());
    }
    let trimmed = line.strip_suffix('\n').unwrap_or(&line);
    Ok(trimmed.strip_suffix('\r').unwrap_or(trimmed).to_owned())
}

fn convert(entry: &mut Entry<'_>, kind: u32, text: &str) -> Result<Option<u64>, Trap> {
    let word = match kind {
        KIND_INTEGER => text
            .trim()
            .parse::<i64>()
            .ok()
            .map(|number| u64::from_ne_bytes(number.to_ne_bytes())),
        KIND_REAL => text.trim().parse::<f64>().ok().map(f64::to_bits),
        KIND_BOOLEAN => boolean_word(text),
        KIND_CHARACTER => single_character(text),
        KIND_REFERENCE => {
            let roots = entry.roots()?;
            let handle = new_text(&mut entry.engine.heap, text, false, &roots)?;
            Some(u64::from(handle.0))
        }
        _ => return Err(Trap::named("internalFault")),
    };
    Ok(word)
}

fn boolean_word(text: &str) -> Option<u64> {
    match text.trim().to_lowercase().as_str() {
        "verdadero" | "true" | "1" => Some(1),
        "falso" | "false" | "0" => Some(0),
        _ => None,
    }
}

fn single_character(text: &str) -> Option<u64> {
    let mut characters = text.chars();
    match (characters.next(), characters.next()) {
        (Some(single), None) => Some(u64::from(u32::from(single))),
        _ => None,
    }
}

fn record_mismatch(entry: &mut Entry<'_>, kind: u32, found: &str) {
    let expected = match kind {
        KIND_INTEGER => "Entero",
        KIND_REAL => "Real",
        KIND_BOOLEAN => "Logico",
        _ => "Caracter",
    };
    let code =
        DiagnosticCode::from_name("readValueTypeMismatch").unwrap_or(DiagnosticCode::InternalFault);
    let record = FaultRecord {
        site: entry.site,
        code: Some(code),
        range: entry.engine.site_range(entry.site),
        arguments: vec![
            ("expected".to_owned(), expected.to_owned()),
            ("found".to_owned(), found.to_owned()),
        ],
    };
    entry.engine.record_notice(record);
}
