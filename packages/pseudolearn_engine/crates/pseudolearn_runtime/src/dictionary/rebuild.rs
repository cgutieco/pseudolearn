use crate::collection::storage::{allocate_buffer, read_word, write_buffers, write_word};
use crate::collection::{self, buffer, collection_length, number, read_value};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_EMPTY_INDEX, DICTIONARY_HASHES_OFFSET, DICTIONARY_INDEX_CAPACITY_OFFSET,
    DICTIONARY_INDEX_OFFSET, DICTIONARY_KEYS_OFFSET, DICTIONARY_OCCUPIED_OFFSET,
    DICTIONARY_USED_OFFSET,
};
use pseudolearn_abi::vector_layout::{
    COLLECTION_CAPACITY_OFFSET, COLLECTION_REFERENCES_OFFSET, COLLECTION_SCALARS_OFFSET,
};

struct Buffers {
    scalars: Handle,
    references: Handle,
    keys: Handle,
    hashes: Handle,
    occupied: Handle,
    index: Handle,
}

pub(super) fn grow(heap: &mut Heap, handle: Handle, needed: u32) -> Result<(), MemoryError> {
    let layout = super::layout(heap, handle)?;
    let used = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    let current = collection::capacity(heap, handle)?;
    let index_capacity = planned_index_capacity(heap, handle, used)?;
    let capacity = if used < current {
        current
    } else {
        current
            .max(1)
            .checked_mul(if current == 0 { 1 } else { 2 })
            .ok_or(MemoryError::CollectionLimit)?
    };
    if collection::limit(
        heap,
        needed,
        layout
            .storage_words(capacity, index_capacity)
            .ok_or(MemoryError::CollectionLimit)?,
    )
    .is_err()
    {
        let compacted = needed;
        collection::limit(
            heap,
            needed,
            layout
                .storage_words(compacted, index_capacity)
                .ok_or(MemoryError::CollectionLimit)?,
        )?;
        return rebuild(heap, handle, (compacted, index_capacity), None);
    }
    if current == capacity
        && number(heap, handle, DICTIONARY_INDEX_CAPACITY_OFFSET)? == index_capacity
    {
        return Ok(());
    }
    rebuild(heap, handle, (capacity, index_capacity), None)
}

pub(super) fn without(heap: &mut Heap, handle: Handle, position: u32) -> Result<(), MemoryError> {
    let length = collection_length(heap, handle)?;
    let capacity = if length == 1 {
        0
    } else {
        collection::capacity(heap, handle)?
    };
    let index_capacity = if capacity == 0 {
        0
    } else {
        number(heap, handle, DICTIONARY_INDEX_CAPACITY_OFFSET)?
    };
    rebuild(heap, handle, (capacity, index_capacity), Some(position))
}

fn allocate(heap: &mut Heap, handle: Handle, capacity: (u32, u32)) -> Result<Buffers, MemoryError> {
    let values = collection::reserve_buffers(heap, super::layout(heap, handle)?.value, capacity.0)?;
    let buffers = Buffers {
        scalars: values.0,
        references: values.1,
        keys: allocate_buffer(heap, u64::from(capacity.0))?,
        hashes: allocate_buffer(heap, u64::from(capacity.0))?,
        occupied: allocate_buffer(heap, u64::from(capacity.0))?,
        index: allocate_buffer(heap, u64::from(capacity.1))?,
    };
    for position in 0..capacity.1 {
        write_word(
            heap,
            buffers.index,
            u64::from(position),
            u64::from(DICTIONARY_EMPTY_INDEX),
        )?;
    }
    Ok(buffers)
}

fn rebuild(
    heap: &mut Heap,
    handle: Handle,
    capacity: (u32, u32),
    excluded: Option<u32>,
) -> Result<(), MemoryError> {
    let buffers = allocate(heap, handle, capacity)?;
    let used = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    let mut destination = 0_u32;
    for source in 0..used {
        if Some(source) == excluded
            || read_word(
                heap,
                buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?,
                u64::from(source),
            )? == 0
        {
            continue;
        }
        copy_entry(heap, handle, (source, destination), (&buffers, capacity.1))?;
        destination = destination.checked_add(1).ok_or(MemoryError::Internal)?;
    }
    commit(heap, handle, (capacity, destination), buffers)
}

fn copy_entry(
    heap: &mut Heap,
    handle: Handle,
    positions: (u32, u32),
    target: (&Buffers, u32),
) -> Result<(), MemoryError> {
    let (source, destination) = positions;
    let (buffers, index_capacity) = target;
    let value = read_value(heap, handle, source)?;
    let layout = super::layout(heap, handle)?.value;
    write_buffers(
        heap,
        (buffers.scalars, buffers.references),
        destination,
        (layout, &value),
    )?;
    let key = read_word(
        heap,
        buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
        u64::from(source),
    )?;
    let hash = read_word(
        heap,
        buffer(heap, handle, DICTIONARY_HASHES_OFFSET)?,
        u64::from(source),
    )?;
    write_word(heap, buffers.keys, u64::from(destination), key)?;
    write_word(heap, buffers.hashes, u64::from(destination), hash)?;
    write_word(heap, buffers.occupied, u64::from(destination), 1)?;
    super::index::insert_into(heap, buffers.index, index_capacity, (destination, hash))
}

fn commit(
    heap: &mut Heap,
    handle: Handle,
    target: ((u32, u32), u32),
    buffers: Buffers,
) -> Result<(), MemoryError> {
    for (offset, buffer) in [
        (COLLECTION_SCALARS_OFFSET, buffers.scalars),
        (COLLECTION_REFERENCES_OFFSET, buffers.references),
        (DICTIONARY_KEYS_OFFSET, buffers.keys),
        (DICTIONARY_HASHES_OFFSET, buffers.hashes),
        (DICTIONARY_OCCUPIED_OFFSET, buffers.occupied),
        (DICTIONARY_INDEX_OFFSET, buffers.index),
    ] {
        heap.store(handle, offset, u64::from(buffer.0))?;
    }
    heap.store(handle, COLLECTION_CAPACITY_OFFSET, u64::from(target.0.0))?;
    heap.store(
        handle,
        DICTIONARY_INDEX_CAPACITY_OFFSET,
        u64::from(target.0.1),
    )?;
    heap.store(handle, DICTIONARY_USED_OFFSET, u64::from(target.1))
}

fn planned_index_capacity(heap: &Heap, handle: Handle, used: u32) -> Result<u32, MemoryError> {
    let mut index_capacity = number(heap, handle, DICTIONARY_INDEX_CAPACITY_OFFSET)?.max(8);
    while u64::from(used)
        .checked_add(1)
        .and_then(|value| value.checked_mul(4))
        .ok_or(MemoryError::CollectionLimit)?
        > u64::from(index_capacity)
            .checked_mul(3)
            .ok_or(MemoryError::CollectionLimit)?
    {
        index_capacity = index_capacity
            .checked_mul(2)
            .ok_or(MemoryError::CollectionLimit)?;
    }
    Ok(index_capacity)
}
