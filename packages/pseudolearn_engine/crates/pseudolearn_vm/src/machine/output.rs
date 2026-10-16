#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::integer_of;
use crate::events::{EventPayload, TraceClass, TraceEvent};
use crate::machine::{Flow, Machine};

impl Machine<'_> {
    pub(crate) fn write_integer(&mut self, word: u64, newline: bool) -> Result<Flow, Fault> {
        let mut text = integer_of(word).to_string();
        if newline {
            text.push('\n');
        }
        self.emit_output(&text);
        self.output.push_str(&text);
        Ok(Flow::Continue)
    }

    pub(crate) fn write_integer_register(
        &mut self,
        source: u16,
        newline: bool,
    ) -> Result<Flow, Fault> {
        let word = self.scalar(source)?;
        self.write_integer(word, newline)
    }

    pub(crate) fn emit_output(&mut self, text: &str) {
        if self.probed {
            let line = self.current_line();
            let depth = self.current_depth();
            self.events.push(TraceEvent {
                class: TraceClass::Output,
                line,
                depth,
                payload: Some(EventPayload::Output {
                    texto: text.to_owned(),
                }),
            });
        }
    }
}
