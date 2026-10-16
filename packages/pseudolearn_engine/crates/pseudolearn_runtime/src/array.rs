use crate::heap::{AllocationRequest, Shape};
use crate::{Heap, MemoryError, ValueKind};
use pseudolearn_abi::{
    ARRAY_DEFINITION_MAP_WORD_OFFSET, ARRAY_DENSE_BOUNDARY_WORD_OFFSET,
    ARRAY_DIMENSION_EXTENTS_START_OFFSET, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, Handle,
    array_elements_start_offset,
};

pub fn new_array(
    heap: &mut Heap,
    element: ValueKind,
    dimensions: &[i64],
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    if dimensions.is_empty() {
        return Err(MemoryError::Internal);
    }
    if dimensions.len() > usize::from(u8::MAX) {
        return Err(MemoryError::Resource);
    }
    let dimensions = dimensions
        .iter()
        .map(|dimension| u64::try_from(*dimension).map_err(|_| MemoryError::NegativeSize))
        .collect::<Result<Vec<_>, _>>()?;
    let total = element_count(&dimensions)?;
    let elements = usize::try_from(total).map_err(|_| MemoryError::Resource)?;
    let rank = u32::try_from(dimensions.len()).map_err(|_| MemoryError::Resource)?;
    let payload = array_elements_start_offset(rank);
    let request = AllocationRequest {
        shape: Shape::Array {
            element,
            dimensions: dimensions.clone(),
        },
        payload,
        elements,
        auxiliary: integer_mask_words(element, elements)?,
        cells: total.checked_add(1).ok_or(MemoryError::Resource)?,
        literal: false,
    };
    let handle = heap.allocate(request, roots)?;
    initialize_array(heap, handle, (element, elements, payload), &dimensions)?;
    Ok(handle)
}

fn integer_mask_words(element: ValueKind, elements: usize) -> Result<usize, MemoryError> {
    if element != ValueKind::Integer || elements == 0 {
        return Ok(0);
    }
    elements
        .checked_add(63)
        .and_then(|count| count.checked_div(64))
        .ok_or(MemoryError::Resource)
}

fn initialize_array(
    heap: &mut Heap,
    handle: Handle,
    (element, elements, payload): (ValueKind, usize, usize),
    dimensions: &[u64],
) -> Result<(), MemoryError> {
    let total = u64::try_from(elements).map_err(|_| MemoryError::Internal)?;
    heap.store(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, total)?;
    heap.store(
        handle,
        ARRAY_DENSE_BOUNDARY_WORD_OFFSET,
        if element == ValueKind::Integer && elements > 0 {
            0
        } else {
            total
        },
    )?;
    if element == ValueKind::Integer && elements > 0 {
        let offset = payload.checked_add(elements).ok_or(MemoryError::Resource)?;
        heap.store(
            handle,
            ARRAY_DEFINITION_MAP_WORD_OFFSET,
            u64::from(handle.0)
                .checked_add(u64::try_from(offset).map_err(|_| MemoryError::Resource)?)
                .ok_or(MemoryError::Resource)?,
        )?;
    }
    store_dimensions(heap, handle, dimensions)?;
    Ok(())
}

fn store_dimensions(
    heap: &mut Heap,
    handle: Handle,
    dimensions: &[u64],
) -> Result<(), MemoryError> {
    if dimensions.len() <= 1 {
        return Ok(());
    }
    for (index, extent) in dimensions.iter().enumerate() {
        heap.store(
            handle,
            ARRAY_DIMENSION_EXTENTS_START_OFFSET
                .checked_add(index)
                .ok_or(MemoryError::Internal)?,
            *extent,
        )?;
    }
    Ok(())
}

pub fn read_element(heap: &Heap, handle: Handle, indices: &[i64]) -> Result<u64, MemoryError> {
    let (index, payload, element) = position(heap, handle, indices)?;
    let word = heap.word(
        handle,
        payload.checked_add(index).ok_or(MemoryError::Internal)?,
    )?;
    if element == ValueKind::Integer
        && heap.word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)?
            == heap.word(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?
    {
        return Ok(word);
    }
    heap.require(handle, index, (element, word))
}

pub fn array_dimensions(heap: &Heap, handle: Handle) -> Result<&[u64], MemoryError> {
    let rank = heap.array_rank(handle)?;
    let address = usize::try_from(handle.0).map_err(|_| MemoryError::Internal)?;
    let start = if rank == 1 {
        address
            .checked_add(ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)
            .ok_or(MemoryError::Internal)?
    } else {
        address
            .checked_add(ARRAY_DIMENSION_EXTENTS_START_OFFSET)
            .ok_or(MemoryError::Internal)?
    };
    let end = start.checked_add(rank).ok_or(MemoryError::Internal)?;
    heap.words.get(start..end).ok_or(MemoryError::Internal)
}

pub fn write_element(
    heap: &mut Heap,
    handle: Handle,
    target: (&[i64], u64),
) -> Result<(), MemoryError> {
    let (index, payload, element) = position(heap, handle, target.0)?;
    heap.store(
        handle,
        payload.checked_add(index).ok_or(MemoryError::Internal)?,
        target.1,
    )?;
    if element == ValueKind::Integer {
        heap.define_integer(handle, index)?;
    }
    Ok(())
}

pub(crate) fn position(
    heap: &Heap,
    handle: Handle,
    indices: &[i64],
) -> Result<(usize, usize, ValueKind), MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    let dimensions = array_dimensions(heap, handle)?;
    if indices.len() != dimensions.len() {
        return Err(MemoryError::Internal);
    }
    let mut linear = 0_u64;
    for (index, extent) in indices.iter().zip(dimensions) {
        let index = u64::try_from(*index).map_err(|_| MemoryError::IndexOutOfRange)?;
        if index >= *extent {
            return Err(MemoryError::IndexOutOfRange);
        }
        linear = linear
            .checked_mul(*extent)
            .and_then(|value| value.checked_add(index))
            .ok_or(MemoryError::Internal)?;
    }
    Ok((
        usize::try_from(linear).map_err(|_| MemoryError::Internal)?,
        heap.array_payload(handle)?,
        heap.array_element_kind(handle)?,
    ))
}

fn element_count(dimensions: &[u64]) -> Result<u64, MemoryError> {
    Ok(if dimensions.contains(&0) {
        0
    } else {
        dimensions.iter().try_fold(1_u64, |total, extent| {
            total.checked_mul(*extent).ok_or(MemoryError::Resource)
        })?
    })
}
