#![forbid(unsafe_code)]

use crate::Fault;
use crate::VmTrap;
use crate::events::{EventField, EventPayload, TraceClass, TraceEvent};
use crate::machine::read_kind::ReadKind;
use crate::machine::{Flow, Machine};
use pseudolearn_diagnostics::DiagnosticArgument;

impl Machine<'_> {
    pub(crate) fn in_read_integer(&mut self, destination: u16) -> Result<Flow, Fault> {
        if self.ensure_input_requested(ReadKind::Integer) {
            return Ok(Flow::Continue);
        }
        let Some(text) = self.next_input() else {
            self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
            return Ok(Flow::AwaitingInput);
        };
        match text.trim().parse::<i64>() {
            Ok(value) => {
                let word = u64::from_ne_bytes(value.to_ne_bytes());
                self.record_input_received(&text);
                self.set_scalar(destination, word)?;
                if self.probed {
                    self.change_buffer.record_scalar(destination, word);
                }
                self.input_requested_emitted = false;
                Ok(Flow::Continue)
            }
            Err(_) => {
                self.reject_input(ReadKind::Integer, &text);
                Ok(Flow::Continue)
            }
        }
    }

    pub(crate) fn in_read_real(&mut self, destination: u16) -> Result<Flow, Fault> {
        if self.ensure_input_requested(ReadKind::Real) {
            return Ok(Flow::Continue);
        }
        let Some(text) = self.next_input() else {
            self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
            return Ok(Flow::AwaitingInput);
        };
        match text.trim().parse::<f64>() {
            Ok(value) => {
                self.record_input_received(&text);
                self.set_scalar(destination, value.to_bits())?;
                if self.probed {
                    self.change_buffer
                        .record_scalar(destination, value.to_bits());
                }
                self.input_requested_emitted = false;
                Ok(Flow::Continue)
            }
            Err(_) => {
                self.reject_input(ReadKind::Real, &text);
                Ok(Flow::Continue)
            }
        }
    }

    pub(crate) fn in_read_boolean(&mut self, destination: u16) -> Result<Flow, Fault> {
        if self.ensure_input_requested(ReadKind::Boolean) {
            return Ok(Flow::Continue);
        }
        let Some(text) = self.next_input() else {
            self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
            return Ok(Flow::AwaitingInput);
        };
        let parsed = match text.trim().to_lowercase().as_str() {
            "verdadero" | "true" | "1" => Some(1_u64),
            "falso" | "false" | "0" => Some(0_u64),
            _ => None,
        };
        if let Some(word) = parsed {
            self.record_input_received(&text);
            self.set_scalar(destination, word)?;
            if self.probed {
                self.change_buffer.record_scalar(destination, word);
            }
            self.input_requested_emitted = false;
            Ok(Flow::Continue)
        } else {
            self.reject_input(ReadKind::Boolean, &text);
            Ok(Flow::Continue)
        }
    }

    pub(crate) fn in_read_character(&mut self, destination: u16) -> Result<Flow, Fault> {
        if self.ensure_input_requested(ReadKind::Character) {
            return Ok(Flow::Continue);
        }
        let Some(text) = self.next_input() else {
            self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
            return Ok(Flow::AwaitingInput);
        };
        let mut characters = text.chars();
        let first = characters.next();
        let second = characters.next();
        if let (Some(single), None) = (first, second) {
            self.record_input_received(&text);
            let code = u64::from(u32::from(single));
            self.set_scalar(destination, code)?;
            if self.probed {
                self.change_buffer.record_scalar(destination, code);
            }
            self.input_requested_emitted = false;
            Ok(Flow::Continue)
        } else {
            self.reject_input(ReadKind::Character, &text);
            Ok(Flow::Continue)
        }
    }

    pub(crate) fn in_read_string(&mut self, destination: u16) -> Result<Flow, Fault> {
        if self.ensure_input_requested(ReadKind::Text) {
            return Ok(Flow::Continue);
        }
        let Some(text) = self.next_input() else {
            self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
            return Ok(Flow::AwaitingInput);
        };
        self.record_input_received(&text);
        let roots = self.memory_roots()?;
        let handle = pseudolearn_runtime::new_text(&mut self.heap, &text, false, &roots)
            .map_err(super::memory::memory_fault)?;
        self.set_reference(destination, handle.0)?;
        if self.probed {
            self.change_buffer.record_reference(destination, handle.0);
        }
        self.input_requested_emitted = false;
        Ok(Flow::Continue)
    }

    fn ensure_input_requested(&mut self, kind: ReadKind) -> bool {
        if self.probed && !self.input_requested_emitted {
            let line = self.current_line();
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::InputRequested,
                line,
                depth,
                span: self.current_span(),
                payload: Some(EventPayload::Fields(vec![(
                    "tipo",
                    EventField::Text(kind.event_name().to_owned()),
                )])),
            });
            self.input_requested_emitted = true;
            self.cursor.program_counter = self.cursor.program_counter.saturating_sub(1);
            return true;
        }
        false
    }

    fn next_input(&mut self) -> Option<String> {
        let text = self.inputs.get(self.input_index)?.clone();
        self.input_index = self.input_index.saturating_add(1);
        Some(text)
    }

    fn record_input_received(&mut self, text: &str) {
        if self.probed {
            let line = self.current_line();
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::InputReceived,
                line,
                depth,
                span: self.current_span(),
                payload: Some(EventPayload::InputReceived {
                    texto: text.to_owned(),
                }),
            });
        }
    }

    fn reject_input(&mut self, kind: ReadKind, found: &str) {
        self.record_type_mismatch(kind.diagnostic_name(), found);
        self.input_requested_emitted = false;
        self.cursor.program_counter = self.cursor.program_counter.wrapping_sub(1);
    }

    fn record_type_mismatch(&mut self, expected: &'static str, found: &str) {
        let position = self.cursor.program_counter.saturating_sub(1);
        let span = self.current.span(position, self.probed);
        let mut trap = VmTrap::new("readValueTypeMismatch", span);
        trap.arguments
            .insert("expected", DiagnosticArgument::Lexeme(expected.to_owned()));
        trap.arguments
            .insert("found", DiagnosticArgument::Lexeme(found.to_owned()));
        self.diagnostics.push(trap);
    }
}
