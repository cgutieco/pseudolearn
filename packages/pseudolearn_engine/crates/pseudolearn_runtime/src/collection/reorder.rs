use super::{collection_layout, collection_length, read_value, write_value};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::vector_layout::COLLECTION_VERSION_OFFSET;

pub fn vector_clone(
    heap: &mut Heap,
    original: Handle,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let layout = collection_layout(heap, original)?;
    let length = collection_length(heap, original)?;
    let mut retained = roots.to_vec();
    retained.push(original);
    let copy = super::new_vector(heap, layout, &retained)?;
    retained.push(copy);
    for index in 0..length {
        let value = read_value(heap, original, index)?;
        crate::vector_insert(heap, copy, (i64::from(index), value), &retained)?;
    }
    Ok(copy)
}

pub fn vector_commit(heap: &mut Heap, original: Handle, copy: Handle) -> Result<(), MemoryError> {
    if collection_layout(heap, original)? != collection_layout(heap, copy)?
        || collection_length(heap, original)? != collection_length(heap, copy)?
    {
        return Err(MemoryError::Internal);
    }
    let version = super::next_version(heap, original)?;
    for index in 0..collection_length(heap, original)? {
        let value = read_value(heap, copy, index)?;
        write_value(heap, original, index, &value)?;
    }
    heap.store(original, COLLECTION_VERSION_OFFSET, u64::from(version))?;
    let header = heap.word(original, 0)?;
    heap.store(original, 0, header & !SORTING_FLAG)
}

pub fn vector_reverse(heap: &mut Heap, original: Handle) -> Result<(), MemoryError> {
    check_sorting(heap, original)?;
    let version = super::next_version(heap, original)?;
    let length = collection_length(heap, original)?;
    for index in 0..length / 2 {
        let opposite = length
            .checked_sub(index)
            .and_then(|index| index.checked_sub(1))
            .ok_or(MemoryError::Internal)?;
        let left = read_value(heap, original, index)?;
        let right = read_value(heap, original, opposite)?;
        write_value(heap, original, index, &right)?;
        write_value(heap, original, opposite, &left)?;
    }
    heap.store(original, COLLECTION_VERSION_OFFSET, u64::from(version))
}

const SORTING_FLAG: u64 = 1_u64 << 32;

pub fn vector_begin_sort(heap: &mut Heap, handle: Handle) -> Result<(), MemoryError> {
    check_sorting(heap, handle)?;
    let header = heap.word(handle, 0)?;
    heap.store(handle, 0, header | SORTING_FLAG)
}

pub(crate) fn check_sorting(heap: &Heap, handle: Handle) -> Result<(), MemoryError> {
    if heap.word(handle, 0)? & SORTING_FLAG != 0 {
        Err(MemoryError::CollectionModified)
    } else {
        Ok(())
    }
}
