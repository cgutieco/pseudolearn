use std::collections::BTreeMap;

pub const BLOCK_WORDS: usize = 64;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DeltaError {
    MissingFill,
}

#[derive(Clone, Debug, PartialEq)]
pub struct BlockDelta<Element> {
    pub target_length: usize,
    pub blocks: BTreeMap<usize, Vec<Element>>,
}

impl<Element: Clone + PartialEq> BlockDelta<Element> {
    pub fn empty(target_length: usize) -> Self {
        Self {
            target_length,
            blocks: BTreeMap::new(),
        }
    }

    pub fn copied_slots(&self) -> usize {
        self.blocks.values().map(Vec::len).sum()
    }

    pub fn advance(tip: &mut Vec<Element>, live: &[Element]) -> Self {
        Self::advance_from(tip, live, 0)
    }

    pub fn advance_from(tip: &mut Vec<Element>, live: &[Element], dirty_from: usize) -> Self {
        let old_length = tip.len();
        let live_length = live.len();
        let common = old_length.min(live_length);
        let mut delta = Self::empty(old_length);
        let mut changed = Vec::new();
        let block_count = old_length.max(live_length).div_ceil(BLOCK_WORDS);
        let first_block = dirty_from.min(common) / BLOCK_WORDS;
        for block_index in first_block..block_count {
            let start = block_index.saturating_mul(BLOCK_WORDS);
            let old_slice = slice_of(tip, start, old_length);
            if old_slice != slice_of(live, start, live_length) {
                changed.push(start);
                if !old_slice.is_empty() {
                    delta.blocks.insert(block_index, old_slice.to_vec());
                }
            }
        }
        tip.truncate(live_length);
        if let Some(extension) = live.get(old_length..live_length) {
            tip.reserve_exact(extension.len());
            tip.extend_from_slice(extension);
        }
        for start in changed {
            let end = start.saturating_add(BLOCK_WORDS).min(common);
            if let (Some(destination), Some(source)) =
                (tip.get_mut(start..end), live.get(start..end))
            {
                destination.clone_from_slice(source);
            }
        }
        delta
    }

    pub fn revert(&self, current: &mut Vec<Element>) -> Result<(), DeltaError> {
        current.truncate(self.target_length);
        if current.len() < self.target_length {
            let fill = self
                .blocks
                .values()
                .next()
                .and_then(|block| block.first())
                .cloned()
                .ok_or(DeltaError::MissingFill)?;
            current.resize(self.target_length, fill);
        }
        for (block_index, content) in &self.blocks {
            let start = block_index.saturating_mul(BLOCK_WORDS);
            let end = start.saturating_add(content.len()).min(self.target_length);
            if let (Some(destination), Some(source)) = (
                current.get_mut(start..end),
                content.get(..end.saturating_sub(start)),
            ) {
                destination.clone_from_slice(source);
            }
        }
        Ok(())
    }

    pub fn compose(first_applied: &Self, older: &Self) -> Self {
        let mut blocks = older.blocks.clone();
        for (block_index, content) in &first_applied.blocks {
            if block_index.saturating_mul(BLOCK_WORDS) < older.target_length {
                blocks
                    .entry(*block_index)
                    .or_insert_with(|| content.clone());
            }
        }
        Self {
            target_length: older.target_length,
            blocks,
        }
    }
}

fn slice_of<Element>(source: &[Element], start: usize, length: usize) -> &[Element] {
    let end = start.saturating_add(BLOCK_WORDS).min(length);
    source.get(start..end).unwrap_or(&[])
}
