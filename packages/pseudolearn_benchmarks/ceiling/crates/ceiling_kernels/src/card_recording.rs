use crate::differential::{Differential, Recording};
use crate::frame_banks::FrameBanks;

#[derive(Default)]
pub struct CardRecording {
    pub differential: Differential,
    cards: Vec<u8>,
}

impl Recording for CardRecording {
    const ACTIVE: bool = true;
    fn reset(&mut self) {
        self.differential.reset();
        self.cards.clear();
    }

    #[inline(always)]
    fn written(&mut self, address: usize) {
        let block = address / 64;
        if block >= self.cards.len() {
            self.cards.resize(block.saturating_add(1), 0);
        }
        if let Some(card) = self.cards.get_mut(block) {
            *card = 1;
        }
    }

    fn capture(&mut self, words: &[i64], banks: &FrameBanks, ordinal: i64) {
        let previous_top = self.differential.shadow.len();
        let mut undo = Vec::new();
        for (block, card) in self.cards.iter_mut().enumerate() {
            if *card == 0 {
                continue;
            }
            let start = block.saturating_mul(64);
            let ending = start.saturating_add(64).min(previous_top);
            if let Some(previous) = self.differential.shadow.get(start..ending) {
                undo.push((start, previous.to_vec()));
            }
            *card = 0;
        }
        self.differential.shadow.clear();
        self.differential.shadow.extend_from_slice(words);
        self.differential
            .push_point(undo, previous_top, (banks, ordinal));
    }

    fn taken(&self) -> u64 {
        self.differential.count
    }
    fn interval(&self) -> u64 {
        self.differential.interval()
    }
}
