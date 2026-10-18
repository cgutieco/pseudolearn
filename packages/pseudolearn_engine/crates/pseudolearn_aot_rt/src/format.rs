use crate::engine::AotEngine;
use crate::trap::Trap;
use pseudolearn_abi::Handle;
use pseudolearn_library::{BooleanLexemes, PrimitiveValue, format_value};
use pseudolearn_runtime::{ValueKind, text_content};

pub(crate) fn handle_of(word: u64) -> Result<Handle, Trap> {
    u32::try_from(word)
        .map(Handle)
        .map_err(|_| Trap::named("internalFault"))
}

pub(crate) fn format_word(engine: &AotEngine, word: u64, kind: ValueKind) -> Result<String, Trap> {
    let lexemes = BooleanLexemes {
        truth: &engine.boolean_words.truth,
        falsity: &engine.boolean_words.falsity,
    };
    let primitive = match kind {
        ValueKind::Integer => PrimitiveValue::Integer(i64::from_ne_bytes(word.to_ne_bytes())),
        ValueKind::Real => PrimitiveValue::Real(finite(f64::from_bits(word))?),
        ValueKind::Boolean => PrimitiveValue::Boolean(word != 0),
        ValueKind::Character => PrimitiveValue::Character(character_of(word)?),
        ValueKind::Reference => PrimitiveValue::Text(text_content(&engine.heap, handle_of(word)?)?),
    };
    Ok(format_value(primitive, lexemes))
}

pub(crate) fn character_of(word: u64) -> Result<char, Trap> {
    u32::try_from(word)
        .ok()
        .and_then(char::from_u32)
        .ok_or_else(|| Trap::named("internalFault"))
}

fn finite(value: f64) -> Result<f64, Trap> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(Trap::named("nonFiniteRealResult"))
    }
}
