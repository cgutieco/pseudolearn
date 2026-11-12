use crate::direct::DirectMachine;
use crate::frame_banks::FrameBanks;
use crate::machine::{Calls, Handle, Outcome};

#[derive(Default)]
pub struct FramedDirect {
    pub(crate) heap: DirectMachine,
    pub(crate) banks: FrameBanks,
}

impl FramedDirect {
    pub fn reset(&mut self) {
        self.heap.reset();
        self.banks.reset();
    }
}

impl Calls for FramedDirect {
    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        self.banks.enter(words, links)
    }

    fn word(&self, slot: usize) -> i64 {
        self.banks.word(slot)
    }

    fn handle(&self, slot: usize) -> Handle {
        self.banks.handle(slot)
    }

    fn leave(&mut self) {
        self.banks.leave();
    }

    fn tick(&mut self) {}
}
