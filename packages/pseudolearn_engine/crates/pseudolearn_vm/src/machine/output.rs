#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::integer_of;
use crate::machine::{Flow, Machine};

impl Machine<'_> {
    pub(crate) fn write_integer(&mut self, word: u64, newline: bool) -> Result<Flow, Fault> {
        self.output.push_str(&integer_of(word).to_string());
        if newline {
            self.output.push('\n');
        }
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
}
