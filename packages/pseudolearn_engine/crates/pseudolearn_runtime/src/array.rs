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
        auxiliary: if element == ValueKind::Integer {
            elements
                .checked_add(63)
                .and_then(|count| count.checked_div(64))
                .ok_or(MemoryError::Resource)?
        } else {
            0
        },
        cells: total.checked_add(1).ok_or(MemoryError::Resource)?,
        literal: false,
    };
    let handle = heap.allocate(request, roots)?;
    initialize_array(heap, handle, (element, elements, payload), &dimensions)?;
    Ok(handle)
}

fn initialize_array(
    heap: &mut Heap,
    handle: Handle,
    (element, elements, payload): (ValueKind, usize, usize),
    dimensions: &[u64],
) -> Result<(), MemoryError> {
    let total = u64::try_from(elements).map_err(|_| MemoryError::Internal)?;
    let rank = dimensions.len();
    heap.store(handle, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, total)?;
    if element == ValueKind::Integer && elements != 0 {
        let offset = payload.checked_add(elements).ok_or(MemoryError::Resource)?;
        heap.store(
            handle,
            ARRAY_DEFINITION_MAP_WORD_OFFSET,
            u64::from(handle.0)
                .checked_add(u64::try_from(offset).map_err(|_| MemoryError::Resource)?)
                .ok_or(MemoryError::Resource)?,
        )?;
    }
    if element != ValueKind::Integer {
        heap.store(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET, total)?;
    }
    if rank > 1 {
        for (index, extent) in dimensions.iter().enumerate() {
            heap.store(
                handle,
                ARRAY_DIMENSION_EXTENTS_START_OFFSET
                    .checked_add(index)
                    .ok_or(MemoryError::Internal)?,
                *extent,
            )?;
        }
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
        && u64::try_from(index).map_err(|_| MemoryError::Internal)?
            < heap.word(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET)?
    {
        return Ok(word);
    }
    heap.require(handle, index, (element, word))
}

pub fn array_dimensions(heap: &Heap, handle: Handle) -> Result<&[u64], MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    if let Shape::Array { dimensions, .. } = &entry.shape {
        Ok(dimensions)
    } else {
        Err(MemoryError::Internal)
    }
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
        let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
        if entry.assigned == entry.elements {
            let length = u64::try_from(entry.assigned).map_err(|_| MemoryError::Internal)?;
            heap.store(handle, ARRAY_DENSE_BOUNDARY_WORD_OFFSET, length)?;
        }
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
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    let Shape::Array {
        element,
        dimensions,
    } = &entry.shape
    else {
        return Err(MemoryError::Internal);
    };
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
        entry.payload,
        *element,
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
