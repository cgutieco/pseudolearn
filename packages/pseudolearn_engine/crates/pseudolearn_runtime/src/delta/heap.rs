use std::collections::BTreeSet;

use super::{BlockDelta, DeltaError, MapDelta, TailDelta};
use crate::Handle;
use crate::heap::{Allocation, Heap};
use crate::text::Breadcrumbs;

#[derive(Clone, Debug, PartialEq)]
pub struct HeapDelta {
    words: BlockDelta<u64>,
    used: usize,
    allocations: MapDelta<Handle, Allocation>,
    free: MapDelta<usize, BTreeSet<usize>>,
    arena_text: TailDelta<String>,
    breadcrumbs: MapDelta<usize, Breadcrumbs>,
    ordinal: u64,
    allocated_cells: u64,
    live_cells: u64,
}

impl HeapDelta {
    pub fn copied_slots(&self) -> usize {
        self.words
            .copied_slots()
            .saturating_add(self.allocations.copied_entries())
            .saturating_add(self.free.copied_entries())
            .saturating_add(self.arena_text.copied_slots())
            .saturating_add(self.breadcrumbs.copied_entries())
    }
}

pub fn advance_heap(tip: &mut Heap, live: &Heap) -> HeapDelta {
    let delta = HeapDelta {
        words: BlockDelta::advance(&mut tip.words, &live.words),
        used: tip.used,
        allocations: MapDelta::advance(&mut tip.allocations, &live.allocations),
        free: MapDelta::advance(&mut tip.free, &live.free),
        arena_text: TailDelta::advance(&mut tip.arena.text, &live.arena.text),
        breadcrumbs: MapDelta::advance(&mut tip.arena.breadcrumbs, &live.arena.breadcrumbs),
        ordinal: tip.ordinal,
        allocated_cells: tip.allocated_cells,
        live_cells: tip.live_cells,
    };
    tip.used = live.used;
    tip.ordinal = live.ordinal;
    tip.allocated_cells = live.allocated_cells;
    tip.live_cells = live.live_cells;
    delta
}

pub fn revert_heap(heap: &mut Heap, delta: &HeapDelta) -> Result<(), DeltaError> {
    delta.words.revert(&mut heap.words)?;
    delta.allocations.revert(&mut heap.allocations);
    delta.free.revert(&mut heap.free);
    delta.arena_text.revert(&mut heap.arena.text);
    delta.breadcrumbs.revert(&mut heap.arena.breadcrumbs);
    heap.used = delta.used;
    heap.ordinal = delta.ordinal;
    heap.allocated_cells = delta.allocated_cells;
    heap.live_cells = delta.live_cells;
    Ok(())
}

pub fn compose_heap_deltas(first_applied: &HeapDelta, older: &HeapDelta) -> HeapDelta {
    HeapDelta {
        words: BlockDelta::compose(&first_applied.words, &older.words),
        used: older.used,
        allocations: MapDelta::compose(&first_applied.allocations, &older.allocations),
        free: MapDelta::compose(&first_applied.free, &older.free),
        arena_text: TailDelta::compose(&first_applied.arena_text, &older.arena_text),
        breadcrumbs: MapDelta::compose(&first_applied.breadcrumbs, &older.breadcrumbs),
        ordinal: older.ordinal,
        allocated_cells: older.allocated_cells,
        live_cells: older.live_cells,
    }
}
