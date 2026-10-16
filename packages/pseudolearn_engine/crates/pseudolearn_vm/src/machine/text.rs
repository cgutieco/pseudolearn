use super::{Flow, Machine, memory::memory_fault};
use crate::{
    Fault,
    evaluate::INVALID_BYTECODE,
    load::memory::{MemoryOp, TypedSource},
};
use pseudolearn_bytecode::Opcode;
use pseudolearn_library::{self as library, PrimitiveValue};
use pseudolearn_runtime::{self as runtime, Handle, ValueKind};

#[cfg(test)]
#[path = "text_tests.rs"]
mod tests;

impl Machine<'_> {
    pub(super) fn memory_text(&mut self, operation: &MemoryOp) -> Result<Flow, Fault> {
        if let MemoryOp::Output { sources, newline } = operation {
            return self.write_values(sources, *newline);
        }
        let MemoryOp::Text {
            opcode,
            destination,
            sources,
            predicate,
        } = operation
        else {
            return Err(INVALID_BYTECODE);
        };
        let word = self.text_value(*opcode, sources, predicate.as_deref())?;
        self.write_result(*destination, word)?;
        Ok(Flow::Continue)
    }

    fn text_value(
        &mut self,
        opcode: Opcode,
        sources: &[TypedSource],
        predicate: Option<&str>,
    ) -> Result<u64, Fault> {
        let first = sources.first().ok_or(INVALID_BYTECODE)?;
        let first_word = self.read_value(first.source)?;
        let word = match opcode {
            Opcode::TextFormat => self.format_text(*first)?,
            Opcode::TextConcat => {
                self.concat_parts(*first, *sources.get(1).ok_or(INVALID_BYTECODE)?)?
            }
            Opcode::TextLength => {
                runtime::text_length(&self.heap, handle(first_word)?).map_err(memory_fault)?
            }
            Opcode::TextToInteger => {
                let text =
                    runtime::text_content(&self.heap, handle(first_word)?).map_err(memory_fault)?;
                let value =
                    library::parse_integer(text).map_err(|_| "stringToNumberConversionFailed")?;
                u64::from_ne_bytes(value.to_ne_bytes())
            }
            Opcode::TextToReal => {
                let text =
                    runtime::text_content(&self.heap, handle(first_word)?).map_err(memory_fault)?;
                library::parse_real(text)
                    .map_err(|_| "stringToNumberConversionFailed")?
                    .to_bits()
            }
            _ => self.text_pair(
                opcode,
                first_word,
                (sources.get(1).ok_or(INVALID_BYTECODE)?, predicate),
            )?,
        };
        Ok(word)
    }

    fn text_pair(
        &mut self,
        opcode: Opcode,
        first: u64,
        (second, predicate): (&TypedSource, Option<&str>),
    ) -> Result<u64, Fault> {
        let second = self.read_value(second.source)?;
        match opcode {
            Opcode::TextCharAt => {
                let position = crate::evaluate::integer_of(second);
                runtime::text_character(&mut self.heap, handle(first)?, position)
                    .map(|character| u64::from(u32::from(character)))
                    .map_err(memory_fault)
            }
            Opcode::TextCmp => {
                let ordering = runtime::compare_text(&self.heap, handle(first)?, handle(second)?)
                    .map_err(memory_fault)?;
                let result = match predicate {
                    Some("eq") => ordering.is_eq(),
                    Some("ne") => !ordering.is_eq(),
                    Some("lt") => ordering.is_lt(),
                    Some("le") => !ordering.is_gt(),
                    Some("gt") => ordering.is_gt(),
                    Some("ge") => !ordering.is_lt(),
                    _ => return Err(INVALID_BYTECODE),
                };
                Ok(u64::from(result))
            }
            _ => Err(INVALID_BYTECODE),
        }
    }

    fn format_text(&mut self, source: TypedSource) -> Result<u64, Fault> {
        let text = self.formatted(source)?;
        let roots = self.memory_roots()?;
        runtime::new_text(&mut self.heap, &text, false, &roots)
            .map(|handle| u64::from(handle.0))
            .map_err(memory_fault)
    }

    fn concat_parts(&mut self, left: TypedSource, right: TypedSource) -> Result<u64, Fault> {
        let part = |source: TypedSource| -> Result<runtime::TextPart, Fault> {
            let word = self.read_value(source.source)?;
            if source.kind == ValueKind::Character {
                let character = u32::try_from(word)
                    .ok()
                    .and_then(char::from_u32)
                    .ok_or(INVALID_BYTECODE)?;
                Ok(runtime::TextPart::Character(character))
            } else {
                Ok(runtime::TextPart::Text(handle(word)?))
            }
        };
        let (left, right) = (part(left)?, part(right)?);
        let roots = self.memory_roots()?;
        runtime::concat_parts(&mut self.heap, left, right, &roots)
            .map(|handle| u64::from(handle.0))
            .map_err(memory_fault)
    }

    fn formatted(&self, source: TypedSource) -> Result<String, Fault> {
        let word = self.read_value(source.source)?;
        let primitive = match source.kind {
            ValueKind::Integer => PrimitiveValue::Integer(crate::evaluate::integer_of(word)),
            ValueKind::Real => PrimitiveValue::Real(finite_real(f64::from_bits(word))?),
            ValueKind::Boolean => PrimitiveValue::Boolean(word != 0),
            ValueKind::Character => PrimitiveValue::Character(
                u32::try_from(word)
                    .ok()
                    .and_then(char::from_u32)
                    .ok_or(INVALID_BYTECODE)?,
            ),
            ValueKind::Reference => PrimitiveValue::Text(
                runtime::text_content(&self.heap, handle(word)?).map_err(memory_fault)?,
            ),
        };
        Ok(library::format_value(
            primitive,
            crate::dispatch::boolean_lexemes(&self.program.vocabulary),
        ))
    }

    fn write_values(&mut self, sources: &[TypedSource], newline: bool) -> Result<Flow, Fault> {
        let mut text = String::new();
        for source in sources {
            let fragment = self.formatted(*source)?;
            text.try_reserve(fragment.len())
                .map_err(|_| "resourceLimit")?;
            text.push_str(&fragment);
        }
        if newline {
            text.push('\n');
        }
        if !self.output_suppressed {
            self.emit_output(&text);
            self.output
                .try_reserve(text.len())
                .map_err(|_| "resourceLimit")?;
            self.output.push_str(&text);
        }
        Ok(Flow::Continue)
    }
}

fn finite_real(value: f64) -> Result<f64, Fault> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err("nonFiniteRealResult")
    }
}

fn handle(word: u64) -> Result<Handle, Fault> {
    Ok(Handle(u32::try_from(word).map_err(|_| INVALID_BYTECODE)?))
}
