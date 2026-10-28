use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::continuation_layout::*;

pub struct ContinuationValues<'values> {
    pub function: u64,
    pub state: u64,
    pub parent: Handle,
    pub scalars: &'values [u64],
    pub references: &'values [Handle],
}

pub fn new_continuation(
    heap: &mut Heap,
    values: ContinuationValues<'_>,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let layout = ContinuationLayout::new(
        u32::try_from(values.scalars.len()).map_err(|_| MemoryError::Resource)?,
        u32::try_from(values.references.len()).map_err(|_| MemoryError::Resource)?,
    )
    .ok_or(MemoryError::Resource)?;
    let mut retained = roots.to_vec();
    retained.extend_from_slice(values.references);
    retained.push(values.parent);
    let handle = heap.allocate(
        AllocationRequest {
            shape: Shape::Continuation,
            payload: layout.physical_words().ok_or(MemoryError::Resource)?,
            elements: 0,
            auxiliary: 0,
            cells: layout.logical_cells(),
            literal: false,
        },
        &retained,
    )?;
    write_continuation(heap, handle, layout, values)?;
    Ok(handle)
}

pub fn read_continuation(
    heap: &Heap,
    handle: Handle,
) -> Result<(Vec<u64>, Vec<Handle>), MemoryError> {
    let layout = continuation_capacity(heap, handle)?;
    let scalars = (0..layout.scalar_slots())
        .map(|slot| {
            heap.word(
                handle,
                layout.scalar_offset(slot).ok_or(MemoryError::Internal)?,
            )
        })
        .collect::<Result<_, _>>()?;
    let references = (0..layout.reference_slots())
        .map(|slot| {
            let word = heap.word(
                handle,
                layout.reference_offset(slot).ok_or(MemoryError::Internal)?,
            )?;
            Ok(Handle(
                u32::try_from(word).map_err(|_| MemoryError::Internal)?,
            ))
        })
        .collect::<Result<_, MemoryError>>()?;
    Ok((scalars, references))
}

pub(crate) fn references(
    heap: &Heap,
    handle: Handle,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    let layout = continuation_capacity(heap, handle)?;
    for offset in [CONTINUATION_PARENT_OFFSET, CONTINUATION_RESULT_OFFSET] {
        pending.push(Handle(
            u32::try_from(heap.word(handle, offset)?).map_err(|_| MemoryError::Internal)?,
        ));
    }
    for slot in 0..layout.reference_slots() {
        pending.push(Handle(
            u32::try_from(heap.word(
                handle,
                layout.reference_offset(slot).ok_or(MemoryError::Internal)?,
            )?)
            .map_err(|_| MemoryError::Internal)?,
        ));
    }
    Ok(())
}

pub fn continuation_capacity(
    heap: &Heap,
    handle: Handle,
) -> Result<ContinuationLayout, MemoryError> {
    if heap.header(handle)?.shape_tag != CONTINUATION_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    ContinuationLayout::new(
        u32::try_from(heap.word(handle, CONTINUATION_SCALARS_OFFSET)?)
            .map_err(|_| MemoryError::Internal)?,
        u32::try_from(heap.word(handle, CONTINUATION_REFERENCES_OFFSET)?)
            .map_err(|_| MemoryError::Internal)?,
    )
    .ok_or(MemoryError::Internal)
}

pub fn write_continuation(
    heap: &mut Heap,
    handle: Handle,
    layout: ContinuationLayout,
    values: ContinuationValues<'_>,
) -> Result<(), MemoryError> {
    for (offset, word) in [
        (CONTINUATION_FUNCTION_OFFSET, values.function),
        (CONTINUATION_STATE_OFFSET, values.state),
        (CONTINUATION_PARENT_OFFSET, u64::from(values.parent.0)),
        (
            CONTINUATION_SCALARS_OFFSET,
            u64::from(layout.scalar_slots()),
        ),
        (
            CONTINUATION_REFERENCES_OFFSET,
            u64::from(layout.reference_slots()),
        ),
    ] {
        heap.store(handle, offset, word)?;
    }
    write_values(heap, handle, layout, values)
}

fn write_values(
    heap: &mut Heap,
    handle: Handle,
    layout: ContinuationLayout,
    values: ContinuationValues<'_>,
) -> Result<(), MemoryError> {
    for (slot, value) in values.scalars.iter().enumerate() {
        heap.store(
            handle,
            layout
                .scalar_offset(u32::try_from(slot).map_err(|_| MemoryError::Internal)?)
                .ok_or(MemoryError::Internal)?,
            *value,
        )?;
    }
    for (slot, value) in values.references.iter().enumerate() {
        heap.store(
            handle,
            layout
                .reference_offset(u32::try_from(slot).map_err(|_| MemoryError::Internal)?)
                .ok_or(MemoryError::Internal)?,
            u64::from(value.0),
        )?;
    }
    Ok(())
}

pub fn clear_continuation(heap: &mut Heap, handle: Handle) -> Result<(), MemoryError> {
    let layout = continuation_capacity(heap, handle)?;
    for slot in 0..layout.reference_slots() {
        heap.store(
            handle,
            layout.reference_offset(slot).ok_or(MemoryError::Internal)?,
            0,
        )?;
    }
    heap.store(handle, CONTINUATION_RESULT_OFFSET, 0)
}
