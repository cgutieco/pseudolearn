use super::CollectionMachine;
use crate::machine::{Outcome, Trap};

const LINE_WORDS: usize = 32;

impl CollectionMachine {
    pub(super) fn reserve_lines(&mut self, count: usize) -> Outcome<usize> {
        if count <= self.line_end.saturating_sub(self.line_cursor) {
            let address = self.line_cursor;
            self.line_cursor = self.line_cursor.checked_add(count).ok_or(Trap::CellLimit)?;
            return Ok(address);
        }
        let padded = count
            .checked_next_multiple_of(LINE_WORDS)
            .ok_or(Trap::CellLimit)?;
        let address = self.line_region(padded)?;
        self.line_cursor = address.checked_add(count).ok_or(Trap::CellLimit)?;
        self.line_end = address.checked_add(padded).ok_or(Trap::CellLimit)?;
        Ok(address)
    }

    fn line_region(&mut self, padded: usize) -> Outcome<usize> {
        let selected = self
            .free
            .range(padded..)
            .filter_map(|(length, addresses)| addresses.first().map(|address| (*length, *address)))
            .min_by_key(|(_, address)| *address);
        if let Some((length, address)) = selected {
            self.free
                .get_mut(&length)
                .ok_or(Trap::InvalidHandle)?
                .remove(&address);
            if length > padded {
                self.free
                    .entry(length.saturating_sub(padded))
                    .or_default()
                    .insert(address.saturating_add(padded));
            }
            return Ok(address);
        }
        self.advance(padded)
    }

    pub(super) fn reclaim_lines(&mut self) -> Outcome<()> {
        let lines = self
            .top
            .saturating_sub(1)
            .checked_div(LINE_WORDS)
            .ok_or(Trap::CellLimit)?;
        let mut occupied = vec![false; lines];
        for allocation in self.allocations.values() {
            let start = allocation
                .address
                .saturating_sub(1)
                .checked_div(LINE_WORDS)
                .ok_or(Trap::CellLimit)?;
            let end = allocation
                .address
                .checked_add(allocation.words)
                .and_then(|end| end.checked_sub(2))
                .and_then(|end| end.checked_div(LINE_WORDS))
                .ok_or(Trap::CellLimit)?;
            occupied
                .get_mut(start..=end)
                .ok_or(Trap::InvalidHandle)?
                .fill(true);
        }
        self.free.clear();
        let mut hole = None;
        for (line, used) in occupied.iter().enumerate() {
            if !used {
                hole.get_or_insert(line);
            } else if let Some(start) = hole.take() {
                self.save_hole(start, line)?;
            }
        }
        if let Some(start) = hole {
            self.save_hole(start, lines)?;
        }
        self.line_cursor = 0;
        self.line_end = 0;
        Ok(())
    }

    fn save_hole(&mut self, start: usize, end: usize) -> Outcome<()> {
        let length = end
            .checked_sub(start)
            .and_then(|count| count.checked_mul(LINE_WORDS))
            .ok_or(Trap::CellLimit)?;
        let address = start
            .checked_mul(LINE_WORDS)
            .and_then(|address| address.checked_add(1))
            .ok_or(Trap::CellLimit)?;
        self.free.entry(length).or_default().insert(address);
        Ok(())
    }
}
