use crate::frame_banks::{FRAME_SLOTS, FrameBanks};
use std::collections::VecDeque;

pub(crate) const CHECKPOINT_QUANTUM: u64 = 1 << 17;
const DELTA_WORDS: usize = 64;

type UndoBlock = (usize, Vec<i64>);

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DifferentialPoint {
    pub undo: Vec<UndoBlock>,
    pub previous_top: usize,
    pub scalars: Vec<i64>,
    pub references: Vec<u32>,
    pub depth: u32,
    pub ordinal: i64,
}

pub trait Recording: Default {
    const ACTIVE: bool;
    fn reset(&mut self);
    fn written(&mut self, address: usize);
    fn capture(&mut self, words: &[i64], banks: &FrameBanks, ordinal: i64);
    fn taken(&self) -> u64;
    fn interval(&self) -> u64;
}

#[derive(Default)]
pub struct Unobserved;

impl Recording for Unobserved {
    const ACTIVE: bool = false;
    fn reset(&mut self) {}
    #[inline(always)]
    fn written(&mut self, _address: usize) {}
    fn capture(&mut self, _words: &[i64], _banks: &FrameBanks, _ordinal: i64) {}
    fn taken(&self) -> u64 {
        0
    }
    fn interval(&self) -> u64 {
        CHECKPOINT_QUANTUM
    }
}

#[derive(Default)]
pub struct Differential {
    pub shadow: Vec<i64>,
    pub points: VecDeque<DifferentialPoint>,
    pub count: u64,
    pub compared_words: u64,
}

impl Differential {
    pub(crate) fn record(&mut self, words: &[i64], banks: &FrameBanks, ordinal: i64) {
        let previous_top = self.shadow.len();
        let mut undo = Vec::new();
        for (block, current) in words.chunks(DELTA_WORDS).enumerate() {
            let start = block.saturating_mul(DELTA_WORDS);
            let ending = start.saturating_add(current.len()).min(previous_top);
            let previous = self.shadow.get(start..ending).unwrap_or(&[]);
            self.compared_words = self
                .compared_words
                .saturating_add(u64::try_from(previous.len()).unwrap_or(0));
            if previous == current {
                continue;
            }
            if !previous.is_empty() {
                undo.push((start, previous.to_vec()));
            }
            let ending = start.saturating_add(current.len());
            if ending > self.shadow.len() {
                self.shadow.resize(ending, 0);
            }
            if let Some(target) = self.shadow.get_mut(start..ending) {
                target.copy_from_slice(current);
            }
        }
        self.shadow.truncate(words.len());
        self.push_point(undo, previous_top, (banks, ordinal));
    }

    pub(crate) fn push_point(
        &mut self,
        undo: Vec<UndoBlock>,
        previous_top: usize,
        control: (&FrameBanks, i64),
    ) {
        let (banks, ordinal) = control;
        let ending = banks.base.saturating_add(FRAME_SLOTS);
        self.points.push_back(DifferentialPoint {
            undo,
            previous_top,
            scalars: banks.scalars.get(..ending).unwrap_or(&[]).to_vec(),
            references: banks.references.get(..ending).unwrap_or(&[]).to_vec(),
            depth: banks.depth,
            ordinal,
        });
        if self.points.len() > 64 {
            self.points.pop_front();
        }
        self.count = self.count.saturating_add(1);
    }
}

impl Recording for Differential {
    const ACTIVE: bool = true;
    fn reset(&mut self) {
        self.shadow.clear();
        self.points.clear();
    }
    #[inline(always)]
    fn written(&mut self, _address: usize) {}
    fn capture(&mut self, words: &[i64], banks: &FrameBanks, ordinal: i64) {
        self.record(words, banks, ordinal);
    }
    fn taken(&self) -> u64 {
        self.count
    }
    fn interval(&self) -> u64 {
        CHECKPOINT_QUANTUM.max(
            u64::try_from(self.shadow.len())
                .unwrap_or(u64::MAX)
                .saturating_mul(16),
        )
    }
}
