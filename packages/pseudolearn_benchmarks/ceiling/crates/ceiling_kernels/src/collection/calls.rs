use super::CollectionMachine;
use crate::machine::{Calls, DEPTH_LIMIT, Handle, Outcome, Trap};

impl Calls for CollectionMachine {
    fn retain(&mut self, handle: Handle) {
        if let Some(frame) = self.frames.last_mut() {
            frame.push(handle);
        }
    }

    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        if self.frames.len() >= usize::try_from(DEPTH_LIMIT).map_err(|_| Trap::DepthLimit)? {
            return Err(Trap::DepthLimit);
        }
        let mut scalar_arguments = [0; 4];
        let mut reference_arguments = [Handle(0); 4];
        for (destination, source) in scalar_arguments.iter_mut().zip(words) {
            *destination = *source;
        }
        for (destination, source) in reference_arguments.iter_mut().zip(links) {
            *destination = *source;
        }
        self.arguments.push((scalar_arguments, reference_arguments));
        self.frames.push(links.to_vec());
        self.tick();
        Ok(())
    }

    fn word(&self, slot: usize) -> i64 {
        self.arguments
            .last()
            .and_then(|entry| entry.0.get(slot))
            .copied()
            .unwrap_or(0)
    }

    fn handle(&self, slot: usize) -> Handle {
        self.arguments
            .last()
            .and_then(|entry| entry.1.get(slot))
            .copied()
            .unwrap_or(Handle(0))
    }

    fn leave(&mut self) {
        self.arguments.pop();
        if self.frames.len() > 1 {
            self.frames.pop();
        }
    }

    fn tick(&mut self) {
        self.operations = self.operations.wrapping_add(1);
        if self.operations.is_multiple_of(4096) {
            self.checkpoint();
        }
    }
}

impl CollectionMachine {
    pub(super) fn checkpoint(&mut self) {
        let changed = self
            .words
            .chunks(64)
            .enumerate()
            .filter(|(index, block)| {
                let start = index.saturating_mul(64);
                self.shadow.get(start..start.saturating_add(block.len())) != Some(*block)
            })
            .count();
        self.statistics
            .changed_blocks
            .push(u64::try_from(changed).unwrap_or(u64::MAX));
        self.shadow.clone_from(&self.words);
    }
}
