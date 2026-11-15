use crate::{CollectionPolicy, Heap, MemoryError};

pub fn clone_heap_bounded(heap: &Heap, maximum_cells: u64) -> Result<Heap, MemoryError> {
    let maximum_cells = maximum_cells.min(heap.options.cells);
    let committed = heap
        .live_cells
        .checked_add(heap.allocated_cells)
        .ok_or(MemoryError::Resource)?;
    if committed > maximum_cells {
        return Err(MemoryError::CellLimit);
    }
    let mut copied = heap.clone();
    copied.options.cells = maximum_cells;
    copied.options.collection = CollectionPolicy::Disabled;
    copied.shrink_to_fit();
    Ok(copied)
}
