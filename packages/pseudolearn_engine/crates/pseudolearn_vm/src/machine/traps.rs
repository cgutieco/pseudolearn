#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::integer_of;
use crate::machine::{Flow, Machine};

impl Machine<'_> {
    pub(crate) fn check_step(&mut self, word: u64) -> Result<Flow, Fault> {
        if integer_of(word) == 0 {
            Err("zeroStepInCountedLoop")
        } else {
            Ok(Flow::Continue)
        }
    }

    pub(crate) fn check_step_register(&mut self, source: u16) -> Result<Flow, Fault> {
        let word = self.scalar(source)?;
        self.check_step(word)
    }

    pub(crate) fn missing_return(&mut self) -> Result<Flow, Fault> {
        Err("missingReturn")
    }

    pub(crate) fn unreachable(&mut self) -> Result<Flow, Fault> {
        Err("unreachable")
    }

    pub(crate) fn unsupported(&mut self) -> Result<Flow, Fault> {
        Err("unsupportedOperation")
    }
}
