use crate::Heap;

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct HeapStatistics {
    pub allocations: u64,
    pub heap_growths: u64,
    pub collections: u64,
    pub reachability_walks: u64,
    pub layout_copies: u64,
    pub initialized_words: u64,
}

impl Heap {
    pub fn statistics(&self) -> HeapStatistics {
        self.statistics.get()
    }

    pub(crate) fn record(&self, update: impl FnOnce(&mut HeapStatistics)) {
        let mut statistics = self.statistics.get();
        update(&mut statistics);
        self.statistics.set(statistics);
    }
}
