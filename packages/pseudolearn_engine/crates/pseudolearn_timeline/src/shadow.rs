use std::collections::BTreeMap;

pub const BLOCK_WORDS: usize = 64;

#[derive(Clone, Debug, Default, PartialEq)]
pub struct UndoSegment {
    pub blocks: BTreeMap<usize, Vec<u64>>,
}

impl UndoSegment {
    pub fn new() -> Self {
        Self {
            blocks: BTreeMap::new(),
        }
    }

    pub fn is_empty(&self) -> bool {
        self.blocks.is_empty()
    }

    pub fn changed_blocks_count(&self) -> usize {
        self.blocks.len()
    }
}

pub fn fuse_undo_segments(older: &UndoSegment, newer: &UndoSegment) -> UndoSegment {
    let mut fused_blocks = older.blocks.clone();
    for (block_index, block_words) in &newer.blocks {
        fused_blocks
            .entry(*block_index)
            .or_insert_with(|| block_words.clone());
    }
    UndoSegment {
        blocks: fused_blocks,
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct ShadowHeap {
    pub words: Vec<u64>,
    pub previous_used: usize,
}

impl ShadowHeap {
    pub fn new() -> Self {
        Self {
            words: Vec::new(),
            previous_used: 0,
        }
    }

    pub fn synchronize_and_record(&mut self, live_words: &[u64], live_used: usize) -> UndoSegment {
        let mut segment = UndoSegment::new();
        let total_words = live_words.len().max(live_used);
        if self.words.len() < total_words {
            self.words.resize(total_words, 0);
        }
        let common_limit = self.previous_used.min(live_used);
        let blocks_to_compare =
            common_limit.saturating_add(BLOCK_WORDS.saturating_sub(1)) / BLOCK_WORDS;

        for block_index in 0..blocks_to_compare {
            self.compare_and_record_block(block_index, live_words, &mut segment);
        }

        self.copy_extended_region(common_limit, live_used, live_words);
        self.previous_used = live_used;
        segment
    }

    fn compare_and_record_block(
        &mut self,
        block_index: usize,
        live_words: &[u64],
        segment: &mut UndoSegment,
    ) {
        let start = block_index.saturating_mul(BLOCK_WORDS);
        let end = start.saturating_add(BLOCK_WORDS).min(self.words.len());
        if start >= end {
            return;
        }
        let shadow_slice = match self.words.get(start..end) {
            Some(slice) => slice,
            None => return,
        };
        let live_slice = match live_words.get(start..end) {
            Some(slice) => slice,
            None => return,
        };
        if shadow_slice != live_slice {
            segment.blocks.insert(block_index, shadow_slice.to_vec());
            if let Some(destination) = self.words.get_mut(start..end) {
                destination.copy_from_slice(live_slice);
            }
        }
    }

    fn copy_extended_region(&mut self, start: usize, end: usize, live_words: &[u64]) {
        if start >= end {
            return;
        }
        let source_slice = match live_words.get(start..end) {
            Some(slice) => slice,
            None => return,
        };
        if let Some(destination) = self.words.get_mut(start..end) {
            destination.copy_from_slice(source_slice);
        }
    }

    pub fn apply_segment_to_words(target_words: &mut [u64], segment: &UndoSegment) {
        for (block_index, old_words) in &segment.blocks {
            let start = block_index.saturating_mul(BLOCK_WORDS);
            let end = start
                .saturating_add(old_words.len())
                .min(target_words.len());
            if start >= end {
                continue;
            }
            let length_to_copy = end.saturating_sub(start);
            let destination = target_words.get_mut(start..end);
            let source = old_words.get(..length_to_copy);
            if let (Some(target), Some(origin)) = (destination, source) {
                target.copy_from_slice(origin);
            }
        }
    }
}
