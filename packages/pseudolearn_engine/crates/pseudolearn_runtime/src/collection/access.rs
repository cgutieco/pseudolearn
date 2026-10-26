use super::storage::read_word;
use super::{buffer, collection_layout, collection_length, number};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_KEYS_OFFSET, DICTIONARY_OCCUPIED_OFFSET, DICTIONARY_SHAPE_TAG,
    DICTIONARY_USED_OFFSET,
};
use pseudolearn_abi::vector_layout::{COLLECTION_REFERENCES_OFFSET, COLLECTION_SCALARS_OFFSET};

pub fn collection_load_word(
    heap: &Heap,
    handle: Handle,
    target: (i64, u32),
) -> Result<u64, MemoryError> {
    let index = position(heap, handle, target.0)?;
    let layout = collection_layout(heap, handle)?;
    let reference = target.1 >= layout.scalar_words;
    let (width, offset, column) = if reference {
        (
            layout.reference_words,
            COLLECTION_REFERENCES_OFFSET,
            target
                .1
                .checked_sub(layout.scalar_words)
                .ok_or(MemoryError::Internal)?,
        )
    } else {
        (layout.scalar_words, COLLECTION_SCALARS_OFFSET, target.1)
    };
    if column >= width {
        return Err(MemoryError::Internal);
    }
    let position = u64::from(index)
        .checked_mul(u64::from(width))
        .and_then(|value| value.checked_add(u64::from(column)))
        .ok_or(MemoryError::Internal)?;
    read_word(heap, buffer(heap, handle, offset)?, position)
}

pub fn collection_key(heap: &Heap, handle: Handle, index: i64) -> Result<u64, MemoryError> {
    let index = position(heap, handle, index)?;
    read_word(
        heap,
        buffer(heap, handle, DICTIONARY_KEYS_OFFSET)?,
        u64::from(index),
    )
}

pub(crate) fn position(heap: &Heap, handle: Handle, index: i64) -> Result<u32, MemoryError> {
    let dictionary = heap.header(handle)?.shape_tag == DICTIONARY_SHAPE_TAG;
    let failure = if dictionary {
        MemoryError::MissingDictionaryKey
    } else {
        MemoryError::IndexOutOfRange
    };
    let index = u32::try_from(index).map_err(|_| failure)?;
    let length = if dictionary {
        number(heap, handle, DICTIONARY_USED_OFFSET)?
    } else {
        collection_length(heap, handle)?
    };
    if index >= length {
        return Err(failure);
    }
    if dictionary
        && read_word(
            heap,
            buffer(heap, handle, DICTIONARY_OCCUPIED_OFFSET)?,
            u64::from(index),
        )? == 0
    {
        return Err(failure);
    }
    Ok(index)
}

pub fn collection_is_dictionary(heap: &Heap, handle: Handle) -> Result<bool, MemoryError> {
    super::validate(heap, handle)?;
    Ok(heap.header(handle)?.shape_tag == DICTIONARY_SHAPE_TAG)
}
