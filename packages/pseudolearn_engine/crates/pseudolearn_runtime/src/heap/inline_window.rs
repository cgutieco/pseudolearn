use super::{BlockRecord, Heap};
use crate::{CollectionPolicy, MemoryError};
use pseudolearn_abi::Handle;

const MINIMUM_SLACK_WORDS: usize = 1 << 14;
const REFILL_SLACK_WORDS: usize = 1 << 13;
const SIZE_MASK_WIDTH: usize = 64;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct InlineWindow {
    pub used: u64,
    pub limit: u64,
    pub ordinal: u64,
    pub room_cells: i64,
    pub room_threshold: i64,
    pub free_size_mask: u64,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct InlineBlock {
    pub handle: Handle,
    pub physical: u32,
    pub cells: u64,
}

impl Heap {
    pub fn inline_window(&mut self) -> Result<InlineWindow, MemoryError> {
        self.ensure_slack()?;
        let (room_cells, room_threshold) = self.collection_rooms();
        Ok(InlineWindow {
            used: u64::try_from(self.used).map_err(|_| MemoryError::Resource)?,
            limit: u64::try_from(self.words.len().min(address_ceiling()))
                .map_err(|_| MemoryError::Resource)?,
            ordinal: self.ordinal,
            room_cells,
            room_threshold,
            free_size_mask: self.free_size_mask(),
        })
    }

    pub fn adopt_inline(
        &mut self,
        window: (u64, u64),
        blocks: &[InlineBlock],
    ) -> Result<(), MemoryError> {
        let (used, ordinal) = window;
        let used = usize::try_from(used).map_err(|_| MemoryError::Internal)?;
        if used < self.used || used > self.words.len() || ordinal < self.ordinal {
            return Err(MemoryError::Internal);
        }
        self.blocks
            .try_reserve(blocks.len())
            .map_err(|_| MemoryError::Resource)?;
        for block in blocks {
            self.add_block(BlockRecord {
                handle: block.handle,
                physical: block.physical,
                cells: block.cells,
            })?;
            self.allocated_cells = self
                .allocated_cells
                .checked_add(block.cells)
                .ok_or(MemoryError::Resource)?;
        }
        self.used = used;
        self.ordinal = ordinal;
        Ok(())
    }

    fn ensure_slack(&mut self) -> Result<(), MemoryError> {
        if self.words.len().saturating_sub(self.used) >= REFILL_SLACK_WORDS {
            return Ok(());
        }
        let wanted = self
            .used
            .checked_add(MINIMUM_SLACK_WORDS)
            .ok_or(MemoryError::Resource)?;
        if self.words.len() >= wanted {
            return Ok(());
        }
        let target = wanted.max(self.words.len().saturating_add(self.words.len() / 2));
        let target = target.min(address_ceiling());
        if target <= self.words.len() {
            return Ok(());
        }
        self.words
            .try_reserve(target.saturating_sub(self.words.len()))
            .map_err(|_| MemoryError::Resource)?;
        self.words.resize(target, 0);
        Ok(())
    }

    fn collection_rooms(&self) -> (i64, i64) {
        if self.options.collection == CollectionPolicy::Forced {
            return (0, 0);
        }
        let committed = self.live_cells.saturating_add(self.allocated_cells);
        let room_cells = self.options.cells.saturating_sub(committed);
        let threshold = self.collection_threshold();
        let room_threshold = threshold.saturating_sub(self.allocated_cells);
        (clamp_signed(room_cells), clamp_signed(room_threshold))
    }

    fn free_size_mask(&self) -> u64 {
        let mut mask = 0_u64;
        for (size, addresses) in &self.free {
            if addresses.is_empty() {
                continue;
            }
            let bit = (*size).min(SIZE_MASK_WIDTH - 1);
            mask |= 1_u64.wrapping_shl(u32::try_from(bit).unwrap_or(63));
        }
        mask
    }
}

fn clamp_signed(value: u64) -> i64 {
    i64::try_from(value).unwrap_or(i64::MAX)
}

fn address_ceiling() -> usize {
    usize::try_from(u32::MAX).unwrap_or(usize::MAX)
}
