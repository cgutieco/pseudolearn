use crate::machine::{Calls, Handle, Outcome};
use crate::semantic_memory::SemanticMachine;

impl Calls for SemanticMachine {
    fn retain(&mut self, handle: Handle) {
        if let Some(frame) = self.frames.last_mut() {
            frame.push(handle);
        }
    }

    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        self.banks.enter(words, links)?;
        self.frames.push(links.to_vec());
        Ok(())
    }

    fn word(&self, slot: usize) -> i64 {
        self.banks.word(slot)
    }

    fn handle(&self, slot: usize) -> Handle {
        self.banks.handle(slot)
    }

    fn leave(&mut self) {
        self.banks.leave();
        if self.frames.len() > 1 {
            self.frames.pop();
        }
    }

    fn tick(&mut self) {}
}
