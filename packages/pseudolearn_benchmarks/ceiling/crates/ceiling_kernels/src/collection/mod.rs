mod allocation;
mod calls;
mod heap;
mod lines;
mod reclaim;
mod workloads;

use std::collections::{BTreeMap, BTreeSet};
use std::time::Duration;

use crate::immediate_arithmetic::ImmediateArithmetic;
use crate::machine::{Handle, Outcome, Trap};

pub use workloads::run;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Collector {
    SizeClasses,
    Lines,
    ReferenceCounts,
}

#[derive(Clone, Copy, Debug)]
pub struct Pause {
    pub elapsed: Duration,
    pub marked_words: u64,
    pub swept_words: u64,
}

#[derive(Clone, Debug, Default)]
pub struct Statistics {
    pub pauses: Vec<Pause>,
    pub peak_words: usize,
    pub changed_blocks: Vec<u64>,
    pub collections: u64,
}

struct Allocation {
    address: usize,
    words: usize,
    links: BTreeSet<usize>,
    counts: u64,
    array: bool,
}

pub struct CollectionMachine {
    words: Vec<i64>,
    top: usize,
    allocations: BTreeMap<u32, Allocation>,
    free: BTreeMap<usize, BTreeSet<usize>>,
    frames: Vec<Vec<Handle>>,
    arguments: Vec<([i64; 4], [Handle; 4])>,
    collector: Collector,
    forced: bool,
    allocated_cells: u64,
    ordinal: i64,
    operations: u64,
    line_cursor: usize,
    line_end: usize,
    shadow: Vec<i64>,
    pub statistics: Statistics,
}

impl ImmediateArithmetic for CollectionMachine {}

impl CollectionMachine {
    pub fn new(collector: Collector, forced: bool) -> Self {
        Self {
            words: Vec::new(),
            top: 1,
            allocations: BTreeMap::new(),
            free: BTreeMap::new(),
            frames: vec![Vec::new()],
            arguments: Vec::new(),
            collector,
            forced,
            allocated_cells: 0,
            ordinal: 0,
            operations: 0,
            line_cursor: 0,
            line_end: 0,
            shadow: Vec::new(),
            statistics: Statistics::default(),
        }
    }

    fn load_word(&self, address: usize) -> Outcome<i64> {
        self.words.get(address).copied().ok_or(Trap::InvalidHandle)
    }

    fn store_word(&mut self, address: usize, value: i64) -> Outcome<()> {
        *self.words.get_mut(address).ok_or(Trap::InvalidHandle)? = value;
        Ok(())
    }

    fn slot(&self, handle: Handle, index: usize) -> Outcome<usize> {
        let allocation = self.allocations.get(&handle.0).ok_or(Trap::InvalidHandle)?;
        if index >= allocation.words.saturating_sub(2) {
            return Err(Trap::IndexOutOfRange);
        }
        allocation
            .address
            .checked_add(2)
            .and_then(|base| base.checked_add(index))
            .ok_or(Trap::InvalidHandle)
    }
}
