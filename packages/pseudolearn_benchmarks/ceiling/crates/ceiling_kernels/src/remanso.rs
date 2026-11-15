use crate::differential::{CHECKPOINT_QUANTUM, Recording};
use crate::flat_heap::FlatHeap;
use crate::frame_banks::FrameBanks;
use crate::immediate_arithmetic::ImmediateArithmetic;
use crate::machine::{Calls, Handle, Outcome, Trap};

pub trait IndexPolicy {
    const CHECK: bool;
}
pub struct CheckedIndex;
pub struct UncheckedLanguageIndex;
impl IndexPolicy for CheckedIndex {
    const CHECK: bool = true;
}
impl IndexPolicy for UncheckedLanguageIndex {
    const CHECK: bool = false;
}

pub struct RemansoMachine<Policy: Recording, Indexing: IndexPolicy = CheckedIndex> {
    pub(crate) heap: FlatHeap,
    pub(crate) banks: FrameBanks,
    pub(crate) recording: Policy,
    pub(crate) ordinal: i64,
    fuel: u64,
    services: u64,
    indexing: std::marker::PhantomData<Indexing>,
}

impl<Policy: Recording, Indexing: IndexPolicy> Default for RemansoMachine<Policy, Indexing> {
    fn default() -> Self {
        let mut heap = FlatHeap::default();
        heap.reset();
        Self {
            heap,
            banks: FrameBanks::default(),
            recording: Policy::default(),
            ordinal: 0,
            fuel: CHECKPOINT_QUANTUM,
            services: 0,
            indexing: std::marker::PhantomData,
        }
    }
}

impl<Policy: Recording, Indexing: IndexPolicy> ImmediateArithmetic
    for RemansoMachine<Policy, Indexing>
{
}

impl<Policy: Recording, Indexing: IndexPolicy> RemansoMachine<Policy, Indexing> {
    pub fn reset(&mut self) {
        self.heap.reset();
        self.banks.reset();
        self.recording.reset();
        self.ordinal = 0;
    }

    pub fn checkpoints(&self) -> u64 {
        self.recording.taken()
    }

    pub fn services(&self) -> u64 {
        self.services
    }

    #[inline(always)]
    pub(crate) fn element(&self, array: Handle, index: i64) -> Outcome<usize> {
        let base = usize::try_from(array.0).map_err(|_| Trap::InvalidHandle)?;
        if Indexing::CHECK {
            let length = self.heap.load(base)?;
            if index < 0 || index >= length {
                return Err(Trap::IndexOutOfRange);
            }
        }
        let offset = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        Ok(base.wrapping_add(1).wrapping_add(offset))
    }

    #[cold]
    #[inline(never)]
    fn service(&mut self) {
        self.services = self.services.saturating_add(1);
        if Policy::ACTIVE {
            let words = self.heap.words.get(..self.heap.top).unwrap_or(&[]);
            self.recording.capture(words, &self.banks, self.ordinal);
        }
        self.fuel = self.recording.interval();
    }
}

impl<Policy: Recording, Indexing: IndexPolicy> Calls for RemansoMachine<Policy, Indexing> {
    #[inline(always)]
    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        self.banks.enter(words, links)?;
        self.tick();
        Ok(())
    }

    #[inline(always)]
    fn word(&self, slot: usize) -> i64 {
        self.banks.word(slot)
    }

    #[inline(always)]
    fn handle(&self, slot: usize) -> Handle {
        self.banks.handle(slot)
    }

    #[inline(always)]
    fn leave(&mut self) {
        self.banks.leave();
    }

    #[inline(always)]
    fn tick(&mut self) {
        self.fuel = self.fuel.wrapping_sub(1);
        if self.fuel == 0 {
            self.service();
        }
    }
}
