use crate::{CollectionPolicy, Heap, MemoryError};

pub fn clone_heap_bounded(heap: &Heap, maximum_cells: u64) -> Result<Heap, MemoryError> {
    let maximum_cells = maximum_cells.min(heap.options.cells);
    if heap.live_cells > maximum_cells {
        return Err(MemoryError::CellLimit);
    }
    let mut copied = heap.clone();
    copied.options.cells = maximum_cells;
    copied.options.collection = CollectionPolicy::Disabled;
    copied.shrink_to_fit();
    Ok(copied)
}
