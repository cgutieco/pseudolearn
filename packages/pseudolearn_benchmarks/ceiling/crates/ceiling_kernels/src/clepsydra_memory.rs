use crate::clepsydra::{BANK_MASK, BANK_SLOTS, ClepsydraMachine, FRAME_SLOTS, cell};
use crate::machine::{
    Arithmetic, Calls, DEPTH_LIMIT, Handle, Heap, Outcome, Shape, Trap, handle_from_word,
    word_from_handle,
};

impl Heap for ClepsydraMachine {
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        let cells = u64::try_from(length).map_err(|_| Trap::NegativeSize)?;
        self.allocate(length, cells)
    }

    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        self.settle()?;
        let address = self.element(array, index)?;
        self.heap.load(address)
    }

    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        self.settle()?;
        let address = self.element(array, index)?;
        self.heap.store(address, value)
    }

    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        handle_from_word(self.read(array, index)?)
    }

    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        self.write(array, index, word_from_handle(target))
    }

    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        self.ordinal = self.ordinal.wrapping_add(1);
        let cells = u64::from(shape.links).saturating_add(u64::from(shape.words));
        self.allocate(self.ordinal, cells)
    }

    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        self.settle()?;
        self.heap.load(cell(object, slot))
    }

    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        self.settle()?;
        self.heap.store(cell(object, slot), value)
    }

    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        self.settle()?;
        handle_from_word(self.heap.load(cell(object, slot))?)
    }

    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.set_field(object, slot, word_from_handle(target))
    }
}

impl Calls for ClepsydraMachine {
    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        self.settle()?;
        let next = self.base.wrapping_add(FRAME_SLOTS);
        if self.depth >= DEPTH_LIMIT || next.wrapping_add(FRAME_SLOTS) > BANK_SLOTS {
            return Err(Trap::DepthLimit);
        }
        self.depth = self.depth.wrapping_add(1);
        self.base = next;
        for (offset, word) in words.iter().enumerate().take(FRAME_SLOTS) {
            if let Some(slot) = self.scalars.get_mut(next.wrapping_add(offset) & BANK_MASK) {
                *slot = *word;
            }
        }
        for (offset, link) in links.iter().enumerate().take(FRAME_SLOTS) {
            if let Some(slot) = self
                .references
                .get_mut(next.wrapping_add(offset) & BANK_MASK)
            {
                *slot = link.0;
            }
        }
        self.tick();
        Ok(())
    }

    fn word(&self, slot: usize) -> i64 {
        self.scalars
            .get(self.base.wrapping_add(slot) & BANK_MASK)
            .copied()
            .unwrap_or_default()
    }

    fn handle(&self, slot: usize) -> Handle {
        Handle(
            self.references
                .get(self.base.wrapping_add(slot) & BANK_MASK)
                .copied()
                .unwrap_or_default(),
        )
    }

    fn leave(&mut self) {
        self.depth = self.depth.saturating_sub(1);
        self.base = self.base.saturating_sub(FRAME_SLOTS);
    }

    fn tick(&mut self) {
        if let Some(timeline) = self.timeline.as_mut() {
            let end = self.base.saturating_add(FRAME_SLOTS);
            let state = crate::timeline::ExecutionState {
                scalars: self.scalars.get(..end).unwrap_or(&[]),
                references: self.references.get(..end).unwrap_or(&[]),
                depth: self.depth,
                ordinal: self.ordinal,
            };
            timeline.tick(&mut self.heap, state);
        }
    }
}
