use crate::heap::Shape;
use crate::{Handle, Heap, MemoryError, ValueKind};

pub fn heap_words(heap: &Heap) -> &[u64] {
    &heap.words
}

pub fn heap_used_words(heap: &Heap) -> usize {
    heap.used
}

pub fn set_heap_used_words(heap: &mut Heap, used_words: usize) {
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
    heap.allocations.keys().copied().collect()
}

pub fn is_object_allocation(heap: &Heap, handle: Handle) -> bool {
    heap.allocations
        .get(&handle)
        .is_some_and(|entry| matches!(entry.shape, Shape::Object(_)))
}

pub fn is_array_allocation(heap: &Heap, handle: Handle) -> bool {
    heap.allocations
        .get(&handle)
        .is_some_and(|entry| matches!(entry.shape, Shape::Array { .. }))
}

pub fn allocation_ordinal(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    heap.word(handle, 1)
}

pub fn object_class_identifier(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    match &entry.shape {
        Shape::Object(layout) => Ok(layout.class),
        _ => Err(MemoryError::Internal),
    }
}

pub fn object_field_kinds(heap: &Heap, handle: Handle) -> Result<Vec<ValueKind>, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    match &entry.shape {
        Shape::Object(layout) => Ok(layout.fields.clone()),
        _ => Err(MemoryError::Internal),
    }
}

pub fn array_element_kind(heap: &Heap, handle: Handle) -> Result<ValueKind, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    match &entry.shape {
        Shape::Array { element, .. } => Ok(*element),
        _ => Err(MemoryError::Internal),
    }
}

pub fn is_defined_element(
    heap: &Heap,
    handle: Handle,
    element_index: usize,
) -> Result<bool, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    let (element_kind, payload) = match entry.shape {
        Shape::Array { element, .. } => (element, entry.payload),
        _ => return Err(MemoryError::Internal),
    };
    if element_index >= entry.elements {
        return Err(MemoryError::IndexOutOfRange);
    }
    let target_offset = payload
        .checked_add(element_index)
        .ok_or(MemoryError::Internal)?;
    let stored_word = heap.word(handle, target_offset)?;
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
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    let (field_kind, payload) = match &entry.shape {
        Shape::Object(layout) => {
            let kind = layout
                .fields
                .get(field_index)
                .copied()
                .ok_or(MemoryError::Internal)?;
            (kind, entry.payload)
        }
        _ => return Err(MemoryError::Internal),
    };
    let target_offset = payload
        .checked_add(field_index)
        .ok_or(MemoryError::Internal)?;
    let stored_word = heap.word(handle, target_offset)?;
    match field_kind {
        ValueKind::Integer => heap.integer_defined(handle, field_index),
        ValueKind::Real => Ok(!f64::from_bits(stored_word).is_nan()),
        _ => Ok(stored_word != field_kind.absent()),
    }
}

pub fn read_element_raw(
    heap: &Heap,
    handle: Handle,
    element_index: usize,
) -> Result<u64, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    if !matches!(entry.shape, Shape::Array { .. }) || element_index >= entry.elements {
        return Err(MemoryError::IndexOutOfRange);
    }
    let target_offset = entry
        .payload
        .checked_add(element_index)
        .ok_or(MemoryError::Internal)?;
    heap.word(handle, target_offset)
}

pub fn read_field_raw(heap: &Heap, handle: Handle, field_index: usize) -> Result<u64, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    if !matches!(entry.shape, Shape::Object(_)) || field_index >= entry.elements {
        return Err(MemoryError::IndexOutOfRange);
    }
    let target_offset = entry
        .payload
        .checked_add(field_index)
        .ok_or(MemoryError::Internal)?;
    heap.word(handle, target_offset)
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
