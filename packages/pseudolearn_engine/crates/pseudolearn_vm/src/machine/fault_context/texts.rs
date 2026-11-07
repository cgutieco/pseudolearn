use super::{Arguments, number};
use crate::load::memory::TypedSource;
use crate::machine::Machine;
use pseudolearn_bytecode::Opcode;
use pseudolearn_diagnostics::DiagnosticArgument;
use pseudolearn_runtime::{self as runtime, Handle};

impl Machine<'_> {
    pub(super) fn text_arguments(
        &self,
        opcode: Opcode,
        sources: &[TypedSource],
        arguments: &mut Arguments,
    ) {
        let first = sources
            .first()
            .and_then(|source| self.read_value(source.source).ok())
            .and_then(|word| u32::try_from(word).ok())
            .map(Handle);
        let Some(first) = first else {
            return;
        };
        match opcode {
            Opcode::TextToInteger | Opcode::TextToReal => {
                if let Ok(text) = runtime::text_content(&self.heap, first) {
                    arguments.insert("lexeme", DiagnosticArgument::Lexeme(text.to_owned()));
                }
            }
            Opcode::TextCharAt => {
                if let Ok(length) = runtime::text_length(&self.heap, first) {
                    arguments.insert("length", DiagnosticArgument::Number(length.into()));
                }
                if let Some(position) = sources
                    .get(1)
                    .and_then(|source| self.read_value(source.source).ok())
                {
                    number(arguments, "position", crate::evaluate::integer_of(position));
                }
            }
            _ => {}
        }
    }
}
