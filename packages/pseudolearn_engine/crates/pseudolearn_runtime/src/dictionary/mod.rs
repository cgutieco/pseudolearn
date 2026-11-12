mod index;
mod window;
pub use window::dictionary_window;
mod rebuild;

use crate::collection::storage::{read_word, write_word};
use crate::collection::{
    self, CollectionWords, buffer, collection_layout, collection_length, number, read_value,
    write_value,
};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_DELETED_INDEX, DICTIONARY_HASHES_OFFSET, DICTIONARY_INDEX_OFFSET,
    DICTIONARY_KEY_KIND_OFFSET, DICTIONARY_KEYS_OFFSET, DICTIONARY_OCCUPIED_OFFSET,
    DICTIONARY_USED_OFFSET,
};
use pseudolearn_abi::vector_layout::{COLLECTION_LENGTH_OFFSET, COLLECTION_VERSION_OFFSET};
use pseudolearn_abi::{DictionaryKeyKind, DictionaryLayout};

pub fn dictionary_find(
    heap: &Heap,
    handle: Handle,
    key: u64,
) -> Result<Option<CollectionWords>, MemoryError> {
    index::find(heap, handle, key)?
        .map(|(position, _)| read_value(heap, handle, position))
        .transpose()
}

pub fn dictionary_get(
    heap: &Heap,
    handle: Handle,
    key: u64,
) -> Result<CollectionWords, MemoryError> {
    dictionary_find(heap, handle, key)?.ok_or(MemoryError::MissingDictionaryKey)
}

pub fn dictionary_lookup(
    heap: &Heap,
    handle: Handle,
    key: u64,
) -> Result<Option<u32>, MemoryError> {
    Ok(index::find(heap, handle, key)?.map(|(position, _)| position))
}

pub fn dictionary_set(
    heap: &mut Heap,
    handle: Handle,
    target: (u64, CollectionWords),
    roots: &[Handle],
) -> Result<(), MemoryError> {
    let layout = layout(heap, handle)?;
    collection::value_matches(layout.value, &target.1)?;
    if let Some((position, _)) = index::find(heap, handle, target.0)? {
        return write_value(heap, handle, position, &target.1);
    }
    let length = collection_length(heap, handle)?;
    let next = length.checked_add(1).ok_or(MemoryError::CollectionLimit)?;
    let version = collection::next_version(heap, handle)?;
    let cells = layout
        .logical_cells(next)
        .ok_or(MemoryError::CollectionLimit)?;
    let mut retained = collection::retained(roots, handle, &target.1);
    if layout.key == DictionaryKeyKind::String {
        retained.push(Handle(
            u32::try_from(target.0).map_err(|_| MemoryError::Internal)?,
        ));
    }
    heap.prepare(
        cells
            .checked_sub(layout.logical_cells(length).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Internal)?,
        &retained,
    )?;
    rebuild::grow(heap, handle, next)?;
    write_entry(heap, handle, (next, version), &target)?;
    collection::cells(heap, handle, cells)
}

pub fn dictionary_remove(
    heap: &mut Heap,
    handle: Handle,
    key: u64,
) -> Result<Option<CollectionWords>, MemoryError> {
    let Some((position, slot)) = index::find(heap, handle, key)? else {
        return Ok(None);
    };
    let value = read_value(heap, handle, position)?;
    let version = collection::next_version(heap, handle)?;
    let length = collection_length(heap, handle)?
        .checked_sub(1)
        .ok_or(MemoryError::Internal)?;
    let used = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    if length == 0
        || used
            .saturating_sub(length)
            .checked_mul(4)
            .ok_or(MemoryError::CollectionLimit)?
            > used
    {
        rebuild::without(heap, handle, position)?;
    } else {
        unlink(heap, handle, position, slot)?;
    }
    heap.store(handle, COLLECTION_LENGTH_OFFSET, u64::from(length))?;
    heap.store(handle, COLLECTION_VERSION_OFFSET, u64::from(version))?;
    let cells = layout(heap, handle)?
        .logical_cells(length)
        .ok_or(MemoryError::Internal)?;
    collection::cells(heap, handle, cells)?;
    Ok(Some(value))
}

pub fn dictionary_entry(
    heap: &Heap,
    handle: Handle,
    ordinal: u32,
) -> Result<Option<(u64, CollectionWords)>, MemoryError> {
    let mut cursor = 0;
    for index in 0..=ordinal {
        let Some((next, key, value)) = dictionary_next(heap, handle, cursor)? else {
            return Ok(None);
        };
        if cursor > next {
            return Err(MemoryError::Internal);
        }
        if index == ordinal {
            return Ok(Some((key, value)));
        }
        cursor = next;
    }
    Ok(None)
}

pub fn dictionary_next(
    heap: &Heap,
    handle: Handle,
    cursor: u32,
) -> Result<Option<(u32, u64, CollectionWords)>, MemoryError> {
    collection::validate(heap, handle)?;
    let used = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    for position in cursor..used {
        if read_word(
            heap,
            buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?,
            u64::from(position),
        )? == 0
        {
            continue;
        }
        let key = read_word(
            heap,
            buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
            u64::from(position),
        )?;
        return Ok(Some((
            position.checked_add(1).ok_or(MemoryError::Internal)?,
            key,
            read_value(heap, handle, position)?,
        )));
    }
    Ok(None)
}

pub(crate) fn layout(heap: &Heap, handle: Handle) -> Result<DictionaryLayout, MemoryError> {
    let key = DictionaryKeyKind::from_code(number(heap, handle, DICTIONARY_KEY_KIND_OFFSET)?)
        .ok_or(MemoryError::Internal)?;
    Ok(DictionaryLayout {
        value: collection_layout(heap, handle)?,
        key,
    })
}

fn write_entry(
    heap: &mut Heap,
    handle: Handle,
    counters: (u32, u32),
    target: &(u64, CollectionWords),
) -> Result<(), MemoryError> {
    let (next, version) = counters;
    let layout = layout(heap, handle)?;
    let position = number(heap, handle, DICTIONARY_USED_OFFSET)?;
    let hash = index::hash(heap, layout.key, target.0)?;
    write_value(heap, handle, position, &target.1)?;
    for (offset, value) in [
        (DICTIONARY_KEYS_OFFSET, target.0),
        (DICTIONARY_HASHES_OFFSET, hash),
        (DICTIONARY_OCCUPIED_OFFSET, 1),
    ] {
        write_word(
            heap,
            buffer(heap, handle, offset)?,
            u64::from(position),
            value,
        )?;
    }
    index::insert(heap, handle, position, hash)?;
    heap.store(
        handle,
        DICTIONARY_USED_OFFSET,
        u64::from(
            position
                .checked_add(1)
                .ok_or(MemoryError::CollectionLimit)?,
        ),
    )?;
    heap.store(handle, COLLECTION_LENGTH_OFFSET, u64::from(next))?;
    heap.store(handle, COLLECTION_VERSION_OFFSET, u64::from(version))?;
    Ok(())
}

fn unlink(heap: &mut Heap, handle: Handle, position: u32, slot: u32) -> Result<(), MemoryError> {
    write_word(
        heap,
        buffer(heap, handle, DICTIONARY_INDEX_OFFSET)?,
        u64::from(slot),
        u64::from(DICTIONARY_DELETED_INDEX),
    )?;
    write_word(
        heap,
        buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?,
        u64::from(position),
        0,
    )?;
    write_word(
        heap,
        buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
        u64::from(position),
        0,
    )?;
    collection::clear_value(heap, handle, position)?;
    Ok(())
}

#[cfg(test)]
#[path = "../dictionary_tests.rs"]
mod tests;
