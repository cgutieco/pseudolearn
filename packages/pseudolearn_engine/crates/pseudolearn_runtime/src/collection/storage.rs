use super::{CollectionWords, collection_layout, number};
use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_HASHES_OFFSET, DICTIONARY_INDEX_OFFSET, DICTIONARY_KEY_KIND_OFFSET,
    DICTIONARY_KEYS_OFFSET, DICTIONARY_OCCUPIED_OFFSET, DICTIONARY_SHAPE_TAG,
    DICTIONARY_USED_OFFSET,
};
use pseudolearn_abi::vector_layout::{
    COLLECTION_BUFFER_OFFSET, COLLECTION_LENGTH_OFFSET, COLLECTION_REFERENCES_OFFSET,
    COLLECTION_SCALARS_OFFSET,
};

pub(crate) fn buffer(heap: &Heap, handle: Handle, offset: usize) -> Result<Handle, MemoryError> {
    Ok(Handle(number(heap, handle, offset)?))
}

pub(crate) fn allocate_buffer(heap: &mut Heap, count: u64) -> Result<Handle, MemoryError> {
    if count == 0 {
        return Ok(Handle(0));
    }
    heap.allocate(
        AllocationRequest {
            shape: Shape::Auxiliary,
            payload: COLLECTION_BUFFER_OFFSET,
            elements: usize::try_from(count).map_err(|_| MemoryError::CollectionLimit)?,
            auxiliary: 0,
            cells: 0,
            literal: false,
        },
        &[],
    )
}

pub(crate) fn reserve_buffers(
    heap: &mut Heap,
    layout: pseudolearn_abi::VectorLayout,
    capacity: u32,
) -> Result<(Handle, Handle), MemoryError> {
    let scalars = allocate_buffer(
        heap,
        u64::from(layout.scalar_words)
            .checked_mul(u64::from(capacity))
            .ok_or(MemoryError::CollectionLimit)?,
    )?;
    let references = allocate_buffer(
        heap,
        u64::from(layout.reference_words)
            .checked_mul(u64::from(capacity))
            .ok_or(MemoryError::CollectionLimit)?,
    )?;
    Ok((scalars, references))
}

pub(crate) fn read_word(heap: &Heap, handle: Handle, position: u64) -> Result<u64, MemoryError> {
    let offset = usize::try_from(position)
        .ok()
        .and_then(|position| position.checked_add(COLLECTION_BUFFER_OFFSET))
        .ok_or(MemoryError::Internal)?;
    heap.word(handle, offset)
}

pub(crate) fn write_word(
    heap: &mut Heap,
    handle: Handle,
    position: u64,
    value: u64,
) -> Result<(), MemoryError> {
    let offset = usize::try_from(position)
        .ok()
        .and_then(|position| position.checked_add(COLLECTION_BUFFER_OFFSET))
        .ok_or(MemoryError::Internal)?;
    heap.store(handle, offset, value)
}

pub(crate) fn read_value(
    heap: &Heap,
    handle: Handle,
    index: u32,
) -> Result<CollectionWords, MemoryError> {
    let layout = collection_layout(heap, handle)?;
    let scalars = buffer(heap, handle, COLLECTION_SCALARS_OFFSET)?;
    let references = buffer(heap, handle, COLLECTION_REFERENCES_OFFSET)?;
    let mut value = CollectionWords::default();
    for offset in 0..layout.scalar_words {
        value.scalars.push(read_word(
            heap,
            scalars,
            position(index, layout.scalar_words, offset)?,
        )?);
    }
    for offset in 0..layout.reference_words {
        value.references.push(Handle(
            u32::try_from(read_word(
                heap,
                references,
                position(index, layout.reference_words, offset)?,
            )?)
            .map_err(|_| MemoryError::Internal)?,
        ));
    }
    Ok(value)
}

pub(crate) fn write_value(
    heap: &mut Heap,
    handle: Handle,
    index: u32,
    value: &CollectionWords,
) -> Result<(), MemoryError> {
    let layout = collection_layout(heap, handle)?;
    super::value_matches(layout, value)?;
    write_buffers(
        heap,
        (
            buffer(heap, handle, COLLECTION_SCALARS_OFFSET)?,
            buffer(heap, handle, COLLECTION_REFERENCES_OFFSET)?,
        ),
        index,
        (layout, value),
    )
}

pub(crate) fn write_buffers(
    heap: &mut Heap,
    buffers: (Handle, Handle),
    index: u32,
    value: (pseudolearn_abi::VectorLayout, &CollectionWords),
) -> Result<(), MemoryError> {
    let (layout, value) = value;
    for (offset, word) in value.scalars.iter().enumerate() {
        write_word(
            heap,
            buffers.0,
            position(
                index,
                layout.scalar_words,
                u32::try_from(offset).map_err(|_| MemoryError::Internal)?,
            )?,
            *word,
        )?;
    }
    for (offset, handle) in value.references.iter().enumerate() {
        write_word(
            heap,
            buffers.1,
            position(
                index,
                layout.reference_words,
                u32::try_from(offset).map_err(|_| MemoryError::Internal)?,
            )?,
            u64::from(handle.0),
        )?;
    }
    Ok(())
}

fn position(index: u32, width: u32, offset: u32) -> Result<u64, MemoryError> {
    u64::from(index)
        .checked_mul(u64::from(width))
        .and_then(|position| position.checked_add(u64::from(offset)))
        .ok_or(MemoryError::Internal)
}

pub(crate) fn clear_value(heap: &mut Heap, handle: Handle, index: u32) -> Result<(), MemoryError> {
    let layout = collection_layout(heap, handle)?;
    let value = CollectionWords {
        scalars: vec![0; usize::try_from(layout.scalar_words).map_err(|_| MemoryError::Internal)?],
        references: vec![
            Handle(0);
            usize::try_from(layout.reference_words)
                .map_err(|_| MemoryError::Internal)?
        ],
    };
    write_value(heap, handle, index, &value)
}

pub(crate) fn references(
    heap: &Heap,
    handle: Handle,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    let dictionary = heap.header(handle)?.shape_tag == DICTIONARY_SHAPE_TAG;
    retain_buffers(heap, handle, dictionary, pending)?;
    let count = number(
        heap,
        handle,
        if dictionary {
            DICTIONARY_USED_OFFSET
        } else {
            COLLECTION_LENGTH_OFFSET
        },
    )?;
    for index in 0..count {
        if dictionary
            && read_word(
                heap,
                buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?,
                u64::from(index),
            )? == 0
        {
            continue;
        }
        reference_value(heap, handle, index, pending)?;
        retain_key(heap, handle, (index, dictionary), pending)?;
    }
    Ok(())
}

fn reference_value(
    heap: &Heap,
    handle: Handle,
    index: u32,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    let width = collection_layout(heap, handle)?.reference_words;
    let references = buffer(heap, handle, COLLECTION_REFERENCES_OFFSET)?;
    for offset in 0..width {
        let word = read_word(heap, references, position(index, width, offset)?)?;
        pending.push(Handle(
            u32::try_from(word).map_err(|_| MemoryError::Internal)?,
        ));
    }
    Ok(())
}

fn retain_buffers(
    heap: &Heap,
    handle: Handle,
    dictionary: bool,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    for offset in [COLLECTION_SCALARS_OFFSET, COLLECTION_REFERENCES_OFFSET] {
        pending.push(buffer(heap, handle, offset)?);
    }
    if dictionary {
        for offset in [
            DICTIONARY_KEYS_OFFSET,
            DICTIONARY_HASHES_OFFSET,
            DICTIONARY_INDEX_OFFSET,
            DICTIONARY_OCCUPIED_OFFSET,
        ] {
            pending.push(buffer(heap, handle, offset)?);
        }
    }
    Ok(())
}

fn retain_key(
    heap: &Heap,
    handle: Handle,
    source: (u32, bool),
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    let (index, dictionary) = source;
    if dictionary
        && number(heap, handle, DICTIONARY_KEY_KIND_OFFSET)?
            == pseudolearn_abi::DictionaryKeyKind::String.code()
    {
        pending.push(Handle(
            u32::try_from(read_word(
                heap,
                buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
                u64::from(index),
            )?)
            .map_err(|_| MemoryError::Internal)?,
        ));
    }
    Ok(())
}
