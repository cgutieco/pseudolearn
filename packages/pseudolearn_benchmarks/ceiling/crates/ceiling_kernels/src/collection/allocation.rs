use super::{Allocation, CollectionMachine, Collector};
use crate::machine::{Handle, Outcome, Trap};
use std::collections::BTreeSet;

const BLOCK_WORDS: usize = 4096;

impl CollectionMachine {
    pub(super) fn allocate(&mut self, cells: usize, array: bool) -> Outcome<Handle> {
        let count = cells.checked_add(2).ok_or(Trap::CellLimit)?;
        if self.forced || self.allocated_cells >= 4096 {
            self.collect()?;
            self.allocated_cells = 0;
        }
        let address = self.reserve(count)?;
        self.words
            .get_mut(address..address.checked_add(count).ok_or(Trap::CellLimit)?)
            .ok_or(Trap::InvalidHandle)?
            .fill(0);
        let handle = u32::try_from(address)
            .map(Handle)
            .map_err(|_| Trap::CellLimit)?;
        self.ordinal = self.ordinal.checked_add(1).ok_or(Trap::CellLimit)?;
        self.store_word(address, i64::try_from(cells).map_err(|_| Trap::CellLimit)?)?;
        self.store_word(address.saturating_add(1), self.ordinal)?;
        self.allocations.insert(
            handle.0,
            Allocation {
                address,
                words: count,
                links: BTreeSet::new(),
                counts: 0,
                array,
            },
        );
        self.frames
            .last_mut()
            .ok_or(Trap::InvalidHandle)?
            .push(handle);
        self.allocated_cells = self
            .allocated_cells
            .checked_add(u64::try_from(cells.saturating_add(1)).map_err(|_| Trap::CellLimit)?)
            .ok_or(Trap::CellLimit)?;
        Ok(handle)
    }

    fn reserve(&mut self, count: usize) -> Outcome<usize> {
        if self.collector == Collector::Lines {
            return self.reserve_lines(count);
        }
        if let Some(addresses) = self.free.get_mut(&count)
            && let Some(address) = addresses.pop_first()
        {
            return Ok(address);
        }
        self.advance(count)
    }

    pub(super) fn advance(&mut self, count: usize) -> Outcome<usize> {
        let ending = self.top.checked_add(count).ok_or(Trap::CellLimit)?;
        if ending > self.words.len() {
            let length = ending
                .checked_next_multiple_of(BLOCK_WORDS)
                .ok_or(Trap::CellLimit)?;
            self.words
                .try_reserve(length.saturating_sub(self.words.len()))
                .map_err(|_| Trap::CellLimit)?;
            self.words.resize(length, 0);
            self.statistics.peak_words = self.statistics.peak_words.max(length);
        }
        let address = self.top;
        self.top = ending;
        Ok(address)
    }
}
