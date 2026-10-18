use crate::context::AotRuntimeContext;
use crate::format::{character_of, format_word, handle_of};
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::kinds::{CHARACTER_OPERAND_FLAG, kind_code, kind_from_code};
use crate::trap::Trap;
use pseudolearn_library::{parse_integer, parse_real};
use pseudolearn_runtime::{
    TextPart, compare_text, concat_parts, new_text, text_character, text_content, text_length,
};
use std::cmp::Ordering;

pub const TEXT_LENGTH: u32 = 0;
pub const TEXT_TO_INTEGER: u32 = 1;
pub const TEXT_TO_REAL: u32 = 2;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_literal(
    context: *mut AotRuntimeContext,
    site: u32,
    bytes: *const u8,
    length: usize,
) -> u32 {
    let content = borrow_slice(bytes, length);
    run_entry(context, site, |entry| text_literal(entry, content))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_concat(
    context: *mut AotRuntimeContext,
    site: u32,
    left: u64,
    right: u64,
) -> u32 {
    run_entry(context, site, |entry| text_concat(entry, left, right))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_format(
    context: *mut AotRuntimeContext,
    site: u32,
    word: u64,
    descriptor: u32,
) -> u32 {
    run_entry(context, site, |entry| text_format(entry, word, descriptor))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_query(
    context: *mut AotRuntimeContext,
    site: u32,
    operation: u32,
    handle: u64,
) -> u32 {
    run_entry(context, site, |entry| text_query(entry, operation, handle))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_character(
    context: *mut AotRuntimeContext,
    site: u32,
    handle: u64,
    position: i64,
) -> u32 {
    run_entry(context, site, |entry| {
        let owner = handle_of(handle)?;
        let length = text_length(&entry.engine.heap, owner)?;
        let character =
            text_character(&mut entry.engine.heap, owner, position).map_err(|error| {
                let trap: Trap = error.into();
                trap.argument("position", position)
                    .argument("length", length)
            })?;
        Ok(u64::from(u32::from(character)))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_compare(
    context: *mut AotRuntimeContext,
    site: u32,
    left: u64,
    right: u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let ordering = compare_parts(entry, operand(left)?, operand(right)?)?;
        let sign: i64 = match ordering {
            Ordering::Less => -1,
            Ordering::Equal => 0,
            Ordering::Greater => 1,
        };
        Ok(u64::from_ne_bytes(sign.to_ne_bytes()))
    })
}

fn compare_parts(entry: &Entry<'_>, left: TextPart, right: TextPart) -> Result<Ordering, Trap> {
    let heap = &entry.engine.heap;
    let mut buffer = [0_u8; 4];
    Ok(match (left, right) {
        (TextPart::Text(first), TextPart::Text(second)) => compare_text(heap, first, second)?,
        (TextPart::Character(first), TextPart::Character(second)) => first.cmp(&second),
        (TextPart::Text(first), TextPart::Character(second)) => {
            text_content(heap, first)?.cmp(&*second.encode_utf8(&mut buffer))
        }
        (TextPart::Character(first), TextPart::Text(second)) => {
            (*first.encode_utf8(&mut buffer)).cmp(text_content(heap, second)?)
        }
    })
}

fn text_literal(entry: &mut Entry<'_>, content: Option<&[u8]>) -> Result<u64, Trap> {
    let bytes = content.ok_or_else(|| Trap::named("internalFault"))?;
    let text = std::str::from_utf8(bytes).map_err(|_| Trap::named("internalFault"))?;
    let roots = entry.roots()?;
    let handle = new_text(&mut entry.engine.heap, text, true, &roots)?;
    Ok(u64::from(handle.0))
}

fn operand(word: u64) -> Result<TextPart, Trap> {
    let low = word & 0xffff_ffff;
    if word & CHARACTER_OPERAND_FLAG != 0 {
        return Ok(TextPart::Character(character_of(low)?));
    }
    Ok(TextPart::Text(handle_of(low)?))
}

fn text_concat(entry: &mut Entry<'_>, left: u64, right: u64) -> Result<u64, Trap> {
    let (left, right) = (operand(left)?, operand(right)?);
    let roots = entry.roots()?;
    let handle = concat_parts(&mut entry.engine.heap, left, right, &roots)?;
    Ok(u64::from(handle.0))
}

fn text_format(entry: &mut Entry<'_>, word: u64, descriptor: u32) -> Result<u64, Trap> {
    let kind = kind_from_code(kind_code(descriptor))?;
    let text = format_word(entry.engine, word, kind)?;
    let roots = entry.roots()?;
    let handle = new_text(&mut entry.engine.heap, &text, false, &roots)?;
    Ok(u64::from(handle.0))
}

fn text_query(entry: &mut Entry<'_>, operation: u32, handle: u64) -> Result<u64, Trap> {
    let handle = handle_of(handle)?;
    if operation == TEXT_LENGTH {
        return Ok(text_length(&entry.engine.heap, handle)?);
    }
    let text = text_content(&entry.engine.heap, handle)?;
    let conversion = Trap::named("stringToNumberConversionFailed").argument("lexeme", text);
    match operation {
        TEXT_TO_INTEGER => parse_integer(text)
            .map(|number| u64::from_ne_bytes(number.to_ne_bytes()))
            .map_err(|_| conversion),
        TEXT_TO_REAL => parse_real(text).map(f64::to_bits).map_err(|_| conversion),
        _ => Err(Trap::named("internalFault")),
    }
}
