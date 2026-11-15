use crate::machine::{DEPTH_LIMIT, Handle, Outcome, Trap};

const BANK_SLOTS: usize = 1 << 16;
const BANK_MASK: usize = BANK_SLOTS.wrapping_sub(1);
pub(crate) const FRAME_SLOTS: usize = 4;

pub struct FrameBanks {
    pub(crate) scalars: Box<[i64]>,
    pub(crate) references: Box<[u32]>,
    pub(crate) base: usize,
    pub(crate) depth: u32,
}

impl Default for FrameBanks {
    fn default() -> Self {
        Self {
            scalars: vec![0; BANK_SLOTS].into_boxed_slice(),
            references: vec![0; BANK_SLOTS].into_boxed_slice(),
            base: 0,
            depth: 0,
        }
    }
}

impl FrameBanks {
    pub fn reset(&mut self) {
        self.base = 0;
        self.depth = 0;
    }

    pub fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
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
        Ok(())
    }

    pub fn word(&self, slot: usize) -> i64 {
        self.scalars
            .get(self.base.wrapping_add(slot) & BANK_MASK)
            .copied()
            .unwrap_or(0)
    }

    pub fn handle(&self, slot: usize) -> Handle {
        Handle(
            self.references
                .get(self.base.wrapping_add(slot) & BANK_MASK)
                .copied()
                .unwrap_or(0),
        )
    }

    pub fn leave(&mut self) {
        self.depth = self.depth.saturating_sub(1);
        self.base = self.base.saturating_sub(FRAME_SLOTS);
    }
}
