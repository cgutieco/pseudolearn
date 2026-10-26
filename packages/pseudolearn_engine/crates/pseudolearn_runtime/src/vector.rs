use crate::collection::{
    self, CollectionWords, collection_layout, collection_length, read_value, write_value,
};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::vector_layout::{
    COLLECTION_CAPACITY_OFFSET, COLLECTION_LENGTH_OFFSET, COLLECTION_REFERENCES_OFFSET,
    COLLECTION_SCALARS_OFFSET, COLLECTION_VERSION_OFFSET,
};

pub fn vector_get(heap: &Heap, handle: Handle, index: i64) -> Result<CollectionWords, MemoryError> {
    let index = position(heap, handle, index, false)?;
    read_value(heap, handle, index)
}

pub fn vector_set(
    heap: &mut Heap,
    handle: Handle,
    target: (i64, CollectionWords),
) -> Result<(), MemoryError> {
    let index = position(heap, handle, target.0, false)?;
    write_value(heap, handle, index, &target.1)
}

pub fn vector_insert(
    heap: &mut Heap,
    handle: Handle,
    target: (i64, CollectionWords),
    roots: &[Handle],
) -> Result<(), MemoryError> {
    let index = position(heap, handle, target.0, true)?;
    let length = collection_length(heap, handle)?;
    let next = length.checked_add(1).ok_or(MemoryError::CollectionLimit)?;
    let layout = collection_layout(heap, handle)?;
    collection::value_matches(layout, &target.1)?;
    let version = collection::next_version(heap, handle)?;
    let cells = layout
        .logical_cells(next)
        .ok_or(MemoryError::CollectionLimit)?;
    let retained = collection::retained(roots, handle, &target.1);
    heap.prepare(
        cells
            .checked_sub(layout.logical_cells(length).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Internal)?,
        &retained,
    )?;
    grow(heap, handle, next)?;
    for source in (index..length).rev() {
        let value = read_value(heap, handle, source)?;
        write_value(
            heap,
            handle,
            source.checked_add(1).ok_or(MemoryError::Internal)?,
            &value,
        )?;
    }
    write_value(heap, handle, index, &target.1)?;
    heap.store(handle, COLLECTION_LENGTH_OFFSET, u64::from(next))?;
    heap.store(handle, COLLECTION_VERSION_OFFSET, u64::from(version))?;
    collection::cells(heap, handle, cells)
}

pub fn vector_remove(heap: &mut Heap, handle: Handle, index: i64) -> Result<(), MemoryError> {
    let index = position(heap, handle, index, false)?;
    let length = collection_length(heap, handle)?;
    let version = collection::next_version(heap, handle)?;
    for destination in index..length.saturating_sub(1) {
        let source = destination.checked_add(1).ok_or(MemoryError::Internal)?;
        let value = read_value(heap, handle, source)?;
        write_value(heap, handle, destination, &value)?;
    }
    let next = length.checked_sub(1).ok_or(MemoryError::Internal)?;
    collection::clear_value(heap, handle, next)?;
    heap.store(handle, COLLECTION_LENGTH_OFFSET, u64::from(next))?;
    heap.store(handle, COLLECTION_VERSION_OFFSET, u64::from(version))?;
    let cells = collection_layout(heap, handle)?
        .logical_cells(next)
        .ok_or(MemoryError::Internal)?;
    collection::cells(heap, handle, cells)
}

fn position(heap: &Heap, handle: Handle, index: i64, insertion: bool) -> Result<u32, MemoryError> {
    let index = u32::try_from(index).map_err(|_| MemoryError::IndexOutOfRange)?;
    let length = collection_length(heap, handle)?;
    if index > length || (!insertion && index == length) {
        return Err(MemoryError::IndexOutOfRange);
    }
    Ok(index)
}

fn grow(heap: &mut Heap, handle: Handle, needed: u32) -> Result<(), MemoryError> {
    let current = collection::capacity(heap, handle)?;
    let layout = collection_layout(heap, handle)?;
    collection::limit(
        heap,
        needed,
        layout
            .storage_words(needed)
            .ok_or(MemoryError::CollectionLimit)?,
    )?;
    if needed <= current {
        return Ok(());
    }
    let capacity = next_capacity(heap, layout, current)?;
    let buffers = collection::reserve_buffers(heap, layout, capacity)?;
    for index in 0..collection_length(heap, handle)? {
        let value = read_value(heap, handle, index)?;
        crate::collection::storage::write_buffers(heap, buffers, index, (layout, &value))?;
    }
    heap.store(handle, COLLECTION_SCALARS_OFFSET, u64::from(buffers.0.0))?;
    heap.store(handle, COLLECTION_REFERENCES_OFFSET, u64::from(buffers.1.0))?;
    heap.store(handle, COLLECTION_CAPACITY_OFFSET, u64::from(capacity))
}

fn next_capacity(
    heap: &Heap,
    layout: pseudolearn_abi::VectorLayout,
    current: u32,
) -> Result<u32, MemoryError> {
    let width = u64::from(
        layout
            .element_words()
            .ok_or(MemoryError::CollectionLimit)?
            .max(1),
    );
    let maximum = heap.options.cells.min(u64::from(u32::MAX - 2)).min(
        heap.options
            .cells
            .min(u64::from(u32::MAX))
            .checked_div(width)
            .ok_or(MemoryError::CollectionLimit)?,
    );
    let doubled = u64::from(current.max(1))
        .checked_mul(if current == 0 { 1 } else { 2 })
        .ok_or(MemoryError::CollectionLimit)?;
    u32::try_from(doubled.min(maximum)).map_err(|_| MemoryError::CollectionLimit)
}
