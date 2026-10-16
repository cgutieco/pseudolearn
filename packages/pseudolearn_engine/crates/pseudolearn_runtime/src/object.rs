use crate::heap::{AllocationRequest, Shape};
use crate::{Heap, MemoryError, ObjectLayout, ValueKind};
use pseudolearn_abi::{Handle, object_fields_start_offset};

pub fn new_object(
    heap: &mut Heap,
    layout: ObjectLayout,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    new_object_shared(heap, std::sync::Arc::new(layout), roots)
}

pub fn new_object_shared(
    heap: &mut Heap,
    layout: std::sync::Arc<ObjectLayout>,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let payload = object_fields_start_offset(layout.fields.len(), layout.dense)
        .ok_or(MemoryError::Resource)?;
    let cells = u64::try_from(layout.fields.len())
        .map_err(|_| MemoryError::Resource)?
        .checked_add(1)
        .ok_or(MemoryError::Resource)?;
    let fields = layout.clone();
    let request = AllocationRequest {
        shape: Shape::Object(layout),
        payload,
        elements: fields.fields.len(),
        auxiliary: 0,
        cells,
        literal: false,
    };
    let handle = heap.allocate(request, roots)?;
    for offset in 2..payload {
        heap.store(handle, offset, u64::MAX)?;
    }
    for (index, kind) in fields.fields.iter().enumerate() {
        heap.store(
            handle,
            payload.checked_add(index).ok_or(MemoryError::Internal)?,
            kind.absent(),
        )?;
    }
    Ok(handle)
}

pub fn read_field(heap: &Heap, handle: Handle, index: usize) -> Result<u64, MemoryError> {
    let (payload, kind) = field(heap, handle, index)?;
    let word = heap.word(
        handle,
        payload.checked_add(index).ok_or(MemoryError::Internal)?,
    )?;
    heap.require(handle, index, (kind, word))
}

pub fn write_field(
    heap: &mut Heap,
    handle: Handle,
    target: (usize, u64),
) -> Result<(), MemoryError> {
    let (payload, kind) = field(heap, handle, target.0)?;
    heap.store(
        handle,
        payload.checked_add(target.0).ok_or(MemoryError::Internal)?,
        target.1,
    )?;
    if kind == ValueKind::Integer {
        heap.define_integer(handle, target.0)?;
    }
    Ok(())
}

pub fn copy_object(
    heap: &mut Heap,
    handle: Handle,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let source = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    let Shape::Object(layout) = &source.shape else {
        return Err(MemoryError::Internal);
    };
    let layout = layout.clone();
    let payload = source.payload;
    let assigned = source.assigned;
    let mut retained = roots.to_vec();
    retained.push(handle);
    let target = new_object_shared(heap, layout.clone(), &retained)?;
    for offset in 2..payload {
        let mask = heap.word(handle, offset)?;
        heap.store(target, offset, mask)?;
    }
    for index in 0..layout.fields.len() {
        let offset = payload.checked_add(index).ok_or(MemoryError::Internal)?;
        let word = heap.word(handle, offset)?;
        heap.store(target, offset, word)?;
    }
    let entry = heap
        .allocations
        .get_mut(&target)
        .ok_or(MemoryError::Internal)?;
    entry.assigned = assigned;
    Ok(target)
}

pub fn object_class(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    if let Shape::Object(layout) = &entry.shape {
        Ok(layout.class)
    } else {
        Err(MemoryError::Internal)
    }
}

fn field(heap: &Heap, handle: Handle, index: usize) -> Result<(usize, ValueKind), MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    let entry = heap.allocations.get(&handle).ok_or(MemoryError::Internal)?;
    let Shape::Object(layout) = &entry.shape else {
        return Err(MemoryError::Internal);
    };
    Ok((
        entry.payload,
        *layout.fields.get(index).ok_or(MemoryError::Internal)?,
    ))
}
