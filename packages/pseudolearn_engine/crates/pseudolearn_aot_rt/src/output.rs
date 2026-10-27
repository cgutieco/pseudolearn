use crate::context::AotRuntimeContext;
use crate::format::format_word;
use crate::guard::{Entry, run_entry};
use crate::kinds::{NEWLINE_FLAG, kind_code, kind_from_code, profile_index};
use crate::trap::Trap;
use std::io::Write;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_write(
    context: *mut AotRuntimeContext,
    site: u32,
    word: u64,
    descriptor: u32,
) -> u32 {
    run_entry(context, site, |entry| write_value(entry, word, descriptor))
}

fn write_value(entry: &mut Entry<'_>, word: u64, descriptor: u32) -> Result<u64, Trap> {
    let kind = kind_from_code(kind_code(descriptor))?;
    let mut text = format_word(entry.engine, word, (kind, profile_index(descriptor)))?;
    if descriptor & NEWLINE_FLAG != 0 {
        text.push('\n');
    }
    entry
        .engine
        .streams
        .output
        .write_all(text.as_bytes())
        .map_err(|_| Trap::named("resourceLimit"))?;
    let bytes = text.into_bytes();
    entry
        .engine
        .effects
        .record_console("write", bytes.clone(), bytes)?;
    Ok(0)
}
