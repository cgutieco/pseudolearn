use crate::collection::storage::{read_word, write_word};
use crate::collection::{buffer, number};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::DictionaryKeyKind;
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_DELETED_INDEX, DICTIONARY_EMPTY_INDEX, DICTIONARY_HASHES_OFFSET,
    DICTIONARY_INDEX_CAPACITY_OFFSET, DICTIONARY_INDEX_OFFSET, DICTIONARY_KEYS_OFFSET,
};

pub(super) fn hash(heap: &Heap, kind: DictionaryKeyKind, key: u64) -> Result<u64, MemoryError> {
    let bytes = key.to_le_bytes();
    let bytes = match kind {
        DictionaryKeyKind::Integer => bytes.as_slice(),
        DictionaryKeyKind::Character | DictionaryKeyKind::Enumeration => {
            bytes.get(..4).ok_or(MemoryError::Internal)?
        }
        DictionaryKeyKind::Boolean => bytes.get(..1).ok_or(MemoryError::Internal)?,
        DictionaryKeyKind::String => crate::text_content(
            heap,
            Handle(u32::try_from(key).map_err(|_| MemoryError::Internal)?),
        )?
        .as_bytes(),
    };
    Ok(bytes.iter().fold(0xcbf2_9ce4_8422_2325_u64, |hash, byte| {
        (hash ^ u64::from(*byte)).wrapping_mul(0x0100_0000_01b3)
    }))
}

pub(super) fn find(
    heap: &Heap,
    handle: Handle,
    key: u64,
) -> Result<Option<(u32, u32)>, MemoryError> {
    let layout = super::layout(heap, handle)?;
    let capacity = number(heap, handle, DICTIONARY_INDEX_CAPACITY_OFFSET)?;
    if capacity == 0 {
        return Ok(None);
    }
    let hash = hash(heap, layout.key, key)?;
    let mask = u64::from(capacity.checked_sub(1).ok_or(MemoryError::Internal)?);
    let table = buffer(heap, handle, DICTIONARY_INDEX_OFFSET)?;
    for distance in 0..capacity {
        let slot = u32::try_from(hash.wrapping_add(u64::from(distance)) & mask)
            .map_err(|_| MemoryError::Internal)?;
        let position = u32::try_from(read_word(heap, table, u64::from(slot))?)
            .map_err(|_| MemoryError::Internal)?;
        if position == DICTIONARY_EMPTY_INDEX {
            return Ok(None);
        }
        if position == DICTIONARY_DELETED_INDEX {
            continue;
        }
        if read_word(
            heap,
            buffer(heap, handle, DICTIONARY_HASHES_OFFSET)?,
            u64::from(position),
        )? == hash
            && equal(heap, handle, (position, key), layout.key)?
        {
            return Ok(Some((position, slot)));
        }
    }
    Ok(None)
}

fn equal(
    heap: &Heap,
    handle: Handle,
    target: (u32, u64),
    kind: DictionaryKeyKind,
) -> Result<bool, MemoryError> {
    let stored = read_word(
        heap,
        buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
        u64::from(target.0),
    )?;
    if kind != DictionaryKeyKind::String {
        return Ok(stored == target.1);
    }
    let stored = Handle(u32::try_from(stored).map_err(|_| MemoryError::Internal)?);
    let requested = Handle(u32::try_from(target.1).map_err(|_| MemoryError::Internal)?);
    Ok(crate::text_content(heap, stored)? == crate::text_content(heap, requested)?)
}

pub(super) fn insert(
    heap: &mut Heap,
    handle: Handle,
    position: u32,
    hash: u64,
) -> Result<(), MemoryError> {
    let capacity = number(heap, handle, DICTIONARY_INDEX_CAPACITY_OFFSET)?;
    insert_into(
        heap,
        buffer(heap, handle, DICTIONARY_INDEX_OFFSET)?,
        capacity,
        (position, hash),
    )
}

pub(super) fn insert_into(
    heap: &mut Heap,
    table: Handle,
    capacity: u32,
    entry: (u32, u64),
) -> Result<(), MemoryError> {
    let mask = u64::from(capacity.checked_sub(1).ok_or(MemoryError::Internal)?);
    for distance in 0..capacity {
        let slot = entry.1.wrapping_add(u64::from(distance)) & mask;
        let current = read_word(heap, table, slot)?;
        if current == u64::from(DICTIONARY_EMPTY_INDEX)
            || current == u64::from(DICTIONARY_DELETED_INDEX)
        {
            return write_word(heap, table, slot, u64::from(entry.0));
        }
    }
    Err(MemoryError::Internal)
}
