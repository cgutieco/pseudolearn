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
    initialize_fields(heap, handle, fields.as_ref(), payload)?;
    Ok(handle)
}

fn initialize_fields(
    heap: &mut Heap,
    handle: Handle,
    layout: &ObjectLayout,
    payload: usize,
) -> Result<(), MemoryError> {
    for offset in 2..payload {
        heap.store(handle, offset, u64::MAX)?;
    }
    for (index, kind) in layout.fields.iter().enumerate() {
        heap.store(
            handle,
            payload.checked_add(index).ok_or(MemoryError::Internal)?,
            kind.absent(),
        )?;
    }
    Ok(())
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
    let layout = heap.layout(handle)?.clone();
    let payload = heap.object_payload(handle)?;
    let mut retained = roots.to_vec();
    retained.push(handle);
    let target = new_object_shared(heap, std::sync::Arc::new(layout.clone()), &retained)?;
    copy_words(heap, (handle, target), (layout.fields.len(), payload))?;
    Ok(target)
}

fn copy_words(
    heap: &mut Heap,
    handles: (Handle, Handle),
    layout: (usize, usize),
) -> Result<(), MemoryError> {
    let (source, target) = handles;
    let (fields, payload) = layout;
    for offset in 2..payload {
        let word = heap.word(source, offset)?;
        heap.store(target, offset, word)?;
    }
    for index in 0..fields {
        let offset = payload.checked_add(index).ok_or(MemoryError::Internal)?;
        let word = heap.word(source, offset)?;
        heap.store(target, offset, word)?;
    }
    Ok(())
}

pub fn object_class(heap: &Heap, handle: Handle) -> Result<u32, MemoryError> {
    let shape_tag = heap.header(handle)?.shape_tag;
    if shape_tag <= 2 || shape_tag == u32::MAX {
        return Err(MemoryError::Internal);
    }
    shape_tag.checked_sub(3).ok_or(MemoryError::Internal)
}

fn field(heap: &Heap, handle: Handle, index: usize) -> Result<(usize, ValueKind), MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    let layout = heap.layout(handle)?;
    Ok((
        heap.object_payload(handle)?,
        *layout.fields.get(index).ok_or(MemoryError::Internal)?,
    ))
}
