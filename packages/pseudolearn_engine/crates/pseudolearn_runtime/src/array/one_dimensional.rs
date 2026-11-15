use crate::heap::value_kind;
use crate::{Heap, MemoryError, ValueKind};
use pseudolearn_abi::{
    ARRAY_DEFINITION_MAP_WORD_OFFSET, ARRAY_DENSE_BOUNDARY_WORD_OFFSET, ARRAY_KIND_STATUS_MASK,
    ARRAY_KIND_STATUS_SHIFT, ARRAY_RANK_STATUS_MASK, ARRAY_RANK_STATUS_SHIFT,
    ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, Handle, array_elements_start_offset,
};

pub fn read_element_1d(heap: &Heap, handle: Handle, index: i64) -> Result<u64, MemoryError> {
    let position = position_1d(heap, handle, index)?;
    read_position_1d(heap, handle, position)
}

pub fn write_element_1d(
    heap: &mut Heap,
    handle: Handle,
    index: i64,
    word: u64,
) -> Result<(), MemoryError> {
    let (index, payload, element, total) = position_1d(heap, handle, index)?;
    heap.store(
        handle,
        payload.checked_add(index).ok_or(MemoryError::Internal)?,
        word,
    )?;
    if element == ValueKind::Integer {
        define_integer_1d(heap, handle, (index, total))?;
    }
    Ok(())
}

fn position_1d(
    heap: &Heap,
    handle: Handle,
    index: i64,
) -> Result<(usize, usize, ValueKind, u64), MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    let header = heap.header(handle)?;
    let rank = (header.status_flags & ARRAY_RANK_STATUS_MASK)
        .checked_shr(ARRAY_RANK_STATUS_SHIFT)
        .ok_or(MemoryError::Internal)?;
    if header.shape_tag != 1 || rank != 1 {
        return Err(MemoryError::Internal);
    }
    let index = u64::try_from(index).map_err(|_| MemoryError::IndexOutOfRange)?;
    let total = heap.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?;
    if index >= total {
        return Err(MemoryError::IndexOutOfRange);
    }
    let kind = (header.status_flags & ARRAY_KIND_STATUS_MASK)
        .checked_shr(ARRAY_KIND_STATUS_SHIFT)
        .ok_or(MemoryError::Internal)?;
    Ok((
        usize::try_from(index).map_err(|_| MemoryError::Internal)?,
        array_elements_start_offset(rank),
        value_kind(kind)?,
        total,
    ))
}

fn read_position_1d(
    heap: &Heap,
    handle: Handle,
    (index, payload, element, total): (usize, usize, ValueKind, u64),
) -> Result<u64, MemoryError> {
    let word = heap.word(
        handle,
        payload.checked_add(index).ok_or(MemoryError::Internal)?,
    )?;
    if element == ValueKind::Integer
        && heap.word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)? == total
    {
        return Ok(word);
    }
    heap.require(handle, index, (element, word))
}

fn define_integer_1d(
    heap: &mut Heap,
    handle: Handle,
    (index, total): (usize, u64),
) -> Result<(), MemoryError> {
    let assigned = heap.word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)?;
    if assigned == total {
        return Ok(());
    }
    let base = heap
        .word(handle, ARRAY_DEFINITION_MAP_WORD_OFFSET)?
        .checked_sub(u64::from(handle.0))
        .ok_or(MemoryError::Internal)?;
    let offset = usize::try_from(base)
        .map_err(|_| MemoryError::Internal)?
        .checked_add(index.checked_div(64).ok_or(MemoryError::Internal)?)
        .ok_or(MemoryError::Internal)?;
    let mask = definition_bit(index)?;
    let word = heap.word(handle, offset)?;
    if word & mask != 0 {
        return Ok(());
    }
    heap.store(handle, offset, word | mask)?;
    let assigned = assigned.checked_add(1).ok_or(MemoryError::Resource)?;
    heap.store(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET, assigned)?;
    if assigned == total {
        heap.store(handle, ARRAY_DEFINITION_MAP_WORD_OFFSET, 0)?;
    }
    Ok(())
}

fn definition_bit(index: usize) -> Result<u64, MemoryError> {
    let position = index.checked_rem(64).ok_or(MemoryError::Internal)?;
    let shift = u32::try_from(position).map_err(|_| MemoryError::Internal)?;
    Ok(1_u64.wrapping_shl(shift))
}
