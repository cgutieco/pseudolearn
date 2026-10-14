use crate::paged_heap::{PagedHeap, Snapshot};
use std::collections::VecDeque;
use std::time::{Duration, Instant};

const TICKS_PER_CLOCK_READ: u32 = 4096;
const RETAINED_CHECKPOINTS: usize = 64;

pub struct ExecutionState<'scope> {
    pub scalars: &'scope [i64],
    pub references: &'scope [u32],
    pub depth: u32,
    pub ordinal: i64,
}

pub struct Checkpoint {
    pub heap: Snapshot,
    pub scalars: Vec<i64>,
    pub references: Vec<u32>,
    pub depth: u32,
    pub ordinal: i64,
}

pub struct Timeline {
    interval: Duration,
    ticks: u32,
    last: Instant,
    checkpoints: VecDeque<Checkpoint>,
    taken: u64,
}

impl Timeline {
    pub fn new(interval: Duration) -> Self {
        Self {
            interval,
            ticks: 0,
            last: Instant::now(),
            checkpoints: VecDeque::new(),
            taken: 0,
        }
    }

    pub fn tick(&mut self, heap: &mut PagedHeap, state: ExecutionState<'_>) {
        self.ticks = self.ticks.wrapping_add(1);
        if self.ticks < TICKS_PER_CLOCK_READ {
            return;
        }
        self.ticks = 0;
        if self.last.elapsed() >= self.interval {
            self.record(heap, state);
        }
    }

    pub fn record(&mut self, heap: &mut PagedHeap, state: ExecutionState<'_>) {
        if self.checkpoints.len() >= RETAINED_CHECKPOINTS {
            self.checkpoints.pop_front();
        }
        self.checkpoints.push_back(Checkpoint {
            heap: heap.checkpoint(),
            scalars: state.scalars.to_vec(),
            references: state.references.to_vec(),
            depth: state.depth,
            ordinal: state.ordinal,
        });
        self.taken = self.taken.wrapping_add(1);
        self.last = Instant::now();
    }

    pub fn taken(&self) -> u64 {
        self.taken
    }

    pub fn latest(&self) -> Option<&Checkpoint> {
        self.checkpoints.back()
    }
}
