use crate::heap::{AllocationRequest, Shape};
use crate::{Heap, MemoryError, ObjectLayout, ValueKind};
use pseudolearn_abi::{Handle, OBJECT_PAYLOAD_STATUS_MASK, object_fields_start_offset};

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
    let cells = object_layout_cells(&layout)?;
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
    let cells = object_allocation_cells(heap, handle)?;
    let mut retained = Vec::new();
    if heap.needs_collection(cells) {
        retained
            .try_reserve_exact(roots.len().checked_add(1).ok_or(MemoryError::Resource)?)
            .map_err(|_| MemoryError::Resource)?;
        retained.extend_from_slice(roots);
        retained.push(handle);
    }
    let target = new_object_shared(heap, std::sync::Arc::new(layout.clone()), &retained)?;
    copy_words(heap, (handle, target), (layout.fields.len(), payload))?;
    Ok(target)
}

pub fn object_allocation_cells(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    object_layout_cells(heap.layout(handle)?)
}

pub fn object_layout_cells(layout: &ObjectLayout) -> Result<u64, MemoryError> {
    u64::try_from(layout.fields.len())
        .map_err(|_| MemoryError::Resource)?
        .checked_add(1)
        .ok_or(MemoryError::Resource)
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
    let header = heap.header(handle)?;
    let class = header
        .shape_tag
        .checked_sub(3)
        .filter(|_| header.shape_tag > 2 && header.shape_tag < u32::MAX)
        .ok_or(MemoryError::Internal)?;
    let layout = heap
        .layouts
        .get(usize::try_from(class).map_err(|_| MemoryError::Internal)?)
        .and_then(Option::as_ref)
        .ok_or(MemoryError::Internal)?;
    let payload = usize::try_from(header.status_flags & OBJECT_PAYLOAD_STATUS_MASK)
        .map_err(|_| MemoryError::Internal)?;
    let expected = object_fields_start_offset(layout.fields.len(), layout.dense)
        .ok_or(MemoryError::Internal)?;
    if payload != expected {
        return Err(MemoryError::Internal);
    }
    Ok((
        payload,
        *layout.fields.get(index).ok_or(MemoryError::Internal)?,
    ))
}
