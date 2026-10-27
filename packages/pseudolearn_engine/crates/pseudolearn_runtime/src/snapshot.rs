use crate::{Handle, Heap, MemoryError, ValueKind};
use pseudolearn_abi::ARRAY_TOTAL_ELEMENTS_WORD_OFFSET;

pub fn heap_words(heap: &Heap) -> &[u64] {
    &heap.words
}

pub fn heap_used_words(heap: &Heap) -> usize {
    heap.used
}

pub fn set_heap_used_words(heap: &mut Heap, used_words: usize) {
    heap.words.truncate(used_words);
    if heap.words.len() < used_words {
        heap.words.resize(used_words, 0);
    }
    heap.used = used_words;
}

pub fn arena_length(heap: &Heap) -> usize {
    heap.arena.text.len()
}

pub fn truncate_arena(heap: &mut Heap, target_length: usize) {
    if target_length <= heap.arena.text.len() {
        heap.arena.text.truncate(target_length);
    }
}

pub fn heap_ordinal(heap: &Heap) -> u64 {
    heap.ordinal
}

pub fn set_heap_ordinal(heap: &mut Heap, ordinal: u64) {
    heap.ordinal = ordinal;
}

pub fn restore_heap_block(
    heap: &mut Heap,
    start_word: usize,
    words: &[u64],
) -> Result<(), MemoryError> {
    let target_end = start_word
        .checked_add(words.len())
        .ok_or(MemoryError::Resource)?;
    if heap.words.len() < target_end {
        heap.words
            .try_reserve_exact(target_end.saturating_sub(heap.words.len()))
            .map_err(|_| MemoryError::Resource)?;
        heap.words.resize(target_end, 0);
    }
    let destination = heap
        .words
        .get_mut(start_word..target_end)
        .ok_or(MemoryError::Internal)?;
    destination.copy_from_slice(words);
    Ok(())
}

pub fn live_allocation_handles(heap: &Heap) -> Vec<Handle> {
    heap.blocks.iter().map(|block| block.handle).collect()
}

pub fn is_object_allocation(heap: &Heap, handle: Handle) -> bool {
    heap.header(handle).is_ok_and(|header| {
        header.shape_tag > 2
            && header.shape_tag < pseudolearn_abi::bytes_layout::BYTES_SHAPE_TAG
    })
}

pub fn is_collection_allocation(heap: &Heap, handle: Handle) -> bool {
    crate::collection::validate(heap, handle).is_ok()
}

pub fn is_array_allocation(heap: &Heap, handle: Handle) -> bool {
    heap.header(handle)
        .is_ok_and(|header| header.shape_tag == 1)
}

pub fn allocation_ordinal(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    heap.identity(handle)
}

pub fn object_class_identifier(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    crate::object::object_class(heap, handle)
}

pub fn object_field_kinds(heap: &Heap, handle: Handle) -> Result<Vec<ValueKind>, MemoryError> {
    Ok(heap.layout(handle)?.fields.clone())
}

pub fn array_element_kind(heap: &Heap, handle: Handle) -> Result<ValueKind, MemoryError> {
    heap.array_element_kind(handle)
}

pub fn is_defined_element(
    heap: &Heap,
    handle: Handle,
    element_index: usize,
) -> Result<bool, MemoryError> {
    let element_kind = heap.array_element_kind(handle)?;
    let total = usize::try_from(heap.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    if element_index >= total {
        return Err(MemoryError::IndexOutOfRange);
    }
    let stored_word = read_element_raw(heap, handle, element_index)?;
    match element_kind {
        ValueKind::Integer => heap.integer_defined(handle, element_index),
        ValueKind::Real => Ok(!f64::from_bits(stored_word).is_nan()),
        _ => Ok(stored_word != element_kind.absent()),
    }
}

pub fn is_defined_field(
    heap: &Heap,
    handle: Handle,
    field_index: usize,
) -> Result<bool, MemoryError> {
    let kind = *heap
        .layout(handle)?
        .fields
        .get(field_index)
        .ok_or(MemoryError::Internal)?;
    let stored_word = read_field_raw(heap, handle, field_index)?;
    match kind {
        ValueKind::Integer => heap.integer_defined(handle, field_index),
        ValueKind::Real => Ok(!f64::from_bits(stored_word).is_nan()),
        _ => Ok(stored_word != kind.absent()),
    }
}

pub fn read_element_raw(
    heap: &Heap,
    handle: Handle,
    element_index: usize,
) -> Result<u64, MemoryError> {
    if !is_array_allocation(heap, handle) {
        return Err(MemoryError::IndexOutOfRange);
    }
    let total = usize::try_from(heap.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    if element_index >= total {
        return Err(MemoryError::IndexOutOfRange);
    }
    heap.word(
        handle,
        heap.array_payload(handle)?
            .checked_add(element_index)
            .ok_or(MemoryError::Internal)?,
    )
}

pub fn read_field_raw(heap: &Heap, handle: Handle, field_index: usize) -> Result<u64, MemoryError> {
    if !is_object_allocation(heap, handle) {
        return Err(MemoryError::IndexOutOfRange);
    }
    if field_index >= heap.layout(handle)?.fields.len() {
        return Err(MemoryError::IndexOutOfRange);
    }
    heap.word(
        handle,
        heap.object_payload(handle)?
            .checked_add(field_index)
            .ok_or(MemoryError::Internal)?,
    )
}

pub fn heap_allocated_cells(heap: &Heap) -> u64 {
    heap.allocated_cells
}

pub fn set_heap_allocated_cells(heap: &mut Heap, count: u64) {
    heap.allocated_cells = count;
}

pub fn heap_live_cells(heap: &Heap) -> u64 {
    heap.live_cells
}

pub fn set_heap_live_cells(heap: &mut Heap, count: u64) {
    heap.live_cells = count;
}
