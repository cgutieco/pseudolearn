use crate::{Heap, MemoryError};
use pseudolearn_abi::Handle;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TextCompaction {
    pub ranges: Vec<(usize, usize, usize)>,
    pub previous_length: usize,
    pub current_length: usize,
}

impl Heap {
    pub fn compact_text(&mut self) -> Result<TextCompaction, MemoryError> {
        let previous_length = self.arena.text.len();
        let mut handles = Vec::new();
        for block in &self.blocks {
            if self.is_text(block.handle)? {
                handles.push(block.handle);
            }
        }
        let mut intervals = handles
            .iter()
            .map(|handle| self.text_range(*handle))
            .collect::<Result<Vec<_>, _>>()?;
        intervals.sort_unstable();
        let mut merged: Vec<(usize, usize)> = Vec::new();
        for (start, end) in intervals {
            if let Some(last) = merged.last_mut()
                && start <= last.1
            {
                last.1 = last.1.max(end);
            } else {
                merged.push((start, end));
            }
        }
        let ranges = self.move_ranges(&merged)?;
        self.relocate_headers(&handles, &ranges)?;
        let current_length = ranges.last().map_or(0, |(start, end, target)| {
            target.saturating_add(end.saturating_sub(*start))
        });
        self.arena.text.truncate(current_length);
        self.discard_breadcrumbs()?;
        Ok(TextCompaction {
            ranges,
            previous_length,
            current_length,
        })
    }

    fn text_range(&self, handle: Handle) -> Result<(usize, usize), MemoryError> {
        let start = usize::try_from(self.word(handle, 2)?).map_err(|_| MemoryError::Internal)?;
        let length = usize::try_from(self.word(handle, 3)?).map_err(|_| MemoryError::Internal)?;
        Ok((
            start,
            start.checked_add(length).ok_or(MemoryError::Internal)?,
        ))
    }

    fn move_ranges(
        &mut self,
        merged: &[(usize, usize)],
    ) -> Result<Vec<(usize, usize, usize)>, MemoryError> {
        let total = merged.iter().try_fold(0_usize, |total, (start, end)| {
            total
                .checked_add(end.saturating_sub(*start))
                .ok_or(MemoryError::Resource)
        })?;
        let mut text = String::new();
        text.try_reserve_exact(total)
            .map_err(|_| MemoryError::Resource)?;
        let mut ranges = Vec::new();
        for (start, end) in merged {
            let fragment = self
                .arena
                .text
                .get(*start..*end)
                .ok_or(MemoryError::Internal)?;
            ranges.push((*start, *end, text.len()));
            text.push_str(fragment);
        }
        self.arena.text = text;
        Ok(ranges)
    }

    fn relocate_headers(
        &mut self,
        handles: &[Handle],
        ranges: &[(usize, usize, usize)],
    ) -> Result<(), MemoryError> {
        for handle in handles {
            let (start, end) = self.text_range(*handle)?;
            let (old, _, target) = ranges
                .iter()
                .find(|(old, limit, _)| *old <= start && end <= *limit)
                .ok_or(MemoryError::Internal)?;
            let moved = target
                .checked_add(start.saturating_sub(*old))
                .ok_or(MemoryError::Internal)?;
            self.store(
                *handle,
                2,
                u64::try_from(moved).map_err(|_| MemoryError::Internal)?,
            )?;
        }
        Ok(())
    }
}
