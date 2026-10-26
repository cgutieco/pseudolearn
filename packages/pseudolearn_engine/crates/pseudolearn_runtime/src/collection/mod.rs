mod access;
pub(crate) mod storage;
pub use access::{collection_is_dictionary, collection_key, collection_load_word};
pub(crate) use storage::{buffer, clear_value, read_value, reserve_buffers, write_value};

use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::dictionary_layout::{
    DICTIONARY_HEADER_WORDS, DICTIONARY_KEY_KIND_OFFSET, DICTIONARY_SHAPE_TAG,
};
use pseudolearn_abi::vector_layout::{
    COLLECTION_CAPACITY_OFFSET, COLLECTION_LENGTH_OFFSET, COLLECTION_REFERENCE_WIDTH_OFFSET,
    COLLECTION_SCALAR_WIDTH_OFFSET, COLLECTION_TYPE_OFFSET, COLLECTION_VERSION_OFFSET,
    VECTOR_HEADER_WORDS, VECTOR_SHAPE_TAG,
};
use pseudolearn_abi::{DictionaryLayout, VectorLayout};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct CollectionWords {
    pub scalars: Vec<u64>,
    pub references: Vec<Handle>,
}

pub fn new_vector(
    heap: &mut Heap,
    layout: VectorLayout,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    create(heap, layout, None, roots)
}

pub fn new_dictionary(
    heap: &mut Heap,
    layout: DictionaryLayout,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    create(heap, layout.value, Some(layout.key), roots)
}

fn create(
    heap: &mut Heap,
    layout: VectorLayout,
    key: Option<pseudolearn_abi::DictionaryKeyKind>,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    layout
        .element_words()
        .filter(|width| *width <= u32::from(u16::MAX))
        .ok_or(MemoryError::CollectionLimit)?;
    let handle = heap.allocate(
        AllocationRequest {
            shape: if key.is_some() {
                Shape::Dictionary
            } else {
                Shape::Vector
            },
            payload: if key.is_some() {
                DICTIONARY_HEADER_WORDS
            } else {
                VECTOR_HEADER_WORDS
            },
            elements: 0,
            auxiliary: 0,
            cells: 1,
            literal: false,
        },
        roots,
    )?;
    initialize(heap, handle, layout, key)?;
    Ok(handle)
}

pub(crate) fn validate(heap: &Heap, handle: Handle) -> Result<(), MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    if matches!(
        heap.header(handle)?.shape_tag,
        VECTOR_SHAPE_TAG | DICTIONARY_SHAPE_TAG
    ) {
        Ok(())
    } else {
        Err(MemoryError::Internal)
    }
}

pub fn collection_length(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    validate(heap, handle)?;
    number(heap, handle, COLLECTION_LENGTH_OFFSET)
}

pub fn collection_version(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    validate(heap, handle)?;
    number(heap, handle, COLLECTION_VERSION_OFFSET)
}

pub fn collection_check_version(
    heap: &Heap,
    handle: Handle,
    expected: u32,
) -> Result<(), MemoryError> {
    if collection_version(heap, handle)? == expected {
        Ok(())
    } else {
        Err(MemoryError::CollectionModified)
    }
}

pub fn collection_layout(heap: &Heap, handle: Handle) -> Result<VectorLayout, MemoryError> {
    validate(heap, handle)?;
    Ok(VectorLayout {
        scalar_words: number(heap, handle, COLLECTION_SCALAR_WIDTH_OFFSET)?,
        reference_words: number(heap, handle, COLLECTION_REFERENCE_WIDTH_OFFSET)?,
        type_identity: number(heap, handle, COLLECTION_TYPE_OFFSET)?,
    })
}

pub(crate) fn number(heap: &Heap, handle: Handle, offset: usize) -> Result<u32, MemoryError> {
    u32::try_from(heap.word(handle, offset)?).map_err(|_| MemoryError::Internal)
}

pub(crate) fn next_version(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    collection_version(heap, handle)?
        .checked_add(1)
        .ok_or(MemoryError::CollectionVersion)
}

pub(crate) fn capacity(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    number(heap, handle, COLLECTION_CAPACITY_OFFSET)
}

pub(crate) fn limit(heap: &Heap, length: u32, words: u64) -> Result<(), MemoryError> {
    let maximum = heap.options.cells.min(u64::from(u32::MAX - 2));
    if u64::from(length) > maximum || words > heap.options.cells.min(u64::from(u32::MAX)) {
        return Err(MemoryError::CollectionLimit);
    }
    Ok(())
}

pub(crate) fn retained(roots: &[Handle], handle: Handle, value: &CollectionWords) -> Vec<Handle> {
    let mut retained = roots.to_vec();
    retained.push(handle);
    retained.extend_from_slice(&value.references);
    retained
}

pub(crate) fn cells(heap: &mut Heap, handle: Handle, next: u64) -> Result<(), MemoryError> {
    let index = heap
        .blocks
        .binary_search_by_key(&handle, |block| block.handle)
        .map_err(|_| MemoryError::Internal)?;
    let block = heap.blocks.get_mut(index).ok_or(MemoryError::Internal)?;
    let increase = next.saturating_sub(block.cells);
    block.cells = next;
    heap.allocated_cells = heap
        .allocated_cells
        .checked_add(increase)
        .ok_or(MemoryError::Resource)?;
    Ok(())
}

pub(crate) fn value_matches(
    layout: VectorLayout,
    value: &CollectionWords,
) -> Result<(), MemoryError> {
    if usize::try_from(layout.scalar_words).ok() != Some(value.scalars.len())
        || usize::try_from(layout.reference_words).ok() != Some(value.references.len())
    {
        return Err(MemoryError::Internal);
    }
    Ok(())
}

pub(crate) fn references(
    heap: &Heap,
    handle: Handle,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    storage::references(heap, handle, pending)
}

fn initialize(
    heap: &mut Heap,
    handle: Handle,
    layout: VectorLayout,
    key: Option<pseudolearn_abi::DictionaryKeyKind>,
) -> Result<(), MemoryError> {
    heap.store(
        handle,
        COLLECTION_SCALAR_WIDTH_OFFSET,
        u64::from(layout.scalar_words),
    )?;
    heap.store(
        handle,
        COLLECTION_REFERENCE_WIDTH_OFFSET,
        u64::from(layout.reference_words),
    )?;
    heap.store(
        handle,
        COLLECTION_TYPE_OFFSET,
        u64::from(layout.type_identity),
    )?;
    if let Some(key) = key {
        heap.store(handle, DICTIONARY_KEY_KIND_OFFSET, u64::from(key.code()))?;
    }
    Ok(())
}
