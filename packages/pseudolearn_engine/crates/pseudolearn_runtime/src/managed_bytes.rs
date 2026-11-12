use crate::heap::{AllocationRequest, Shape};
use crate::{Heap, MemoryError};
use pseudolearn_abi::{
    Handle,
    bytes_layout::{BYTES_DATA_OFFSET, BYTES_LENGTH_OFFSET, BYTES_SHAPE_TAG},
};

pub fn new_bytes(heap: &mut Heap, bytes: &[u8], roots: &[Handle]) -> Result<Handle, MemoryError> {
    let request = AllocationRequest {
        shape: Shape::Bytes,
        payload: BYTES_DATA_OFFSET,
        elements: bytes.len().div_ceil(8),
        auxiliary: 0,
        cells: u64::try_from(pseudolearn_abi::bytes_cell_count(bytes.len()))
            .map_err(|_| MemoryError::Resource)?,
        literal: false,
    };
    let handle = heap.allocate(request, roots)?;
    heap.store(
        handle,
        BYTES_LENGTH_OFFSET,
        u64::try_from(bytes.len()).map_err(|_| MemoryError::Resource)?,
    )?;
    for (index, chunk) in bytes.chunks(8).enumerate() {
        let mut packed = [0; 8];
        let destination = packed.get_mut(..chunk.len()).ok_or(MemoryError::Internal)?;
        destination.copy_from_slice(chunk);
        heap.store(
            handle,
            BYTES_DATA_OFFSET
                .checked_add(index)
                .ok_or(MemoryError::Resource)?,
            u64::from_le_bytes(packed),
        )?;
    }
    Ok(handle)
}

pub fn bytes_length(heap: &Heap, handle: Handle) -> Result<usize, MemoryError> {
    if heap.header(handle)?.shape_tag != BYTES_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    usize::try_from(heap.word(handle, BYTES_LENGTH_OFFSET)?).map_err(|_| MemoryError::Resource)
}

pub fn bytes_at(heap: &Heap, handle: Handle, index: i64) -> Result<u8, MemoryError> {
    let index = usize::try_from(index).map_err(|_| MemoryError::IndexOutOfRange)?;
    if index >= bytes_length(heap, handle)? {
        return Err(MemoryError::IndexOutOfRange);
    }
    let offset = BYTES_DATA_OFFSET
        .checked_add(index.checked_div(8).ok_or(MemoryError::Internal)?)
        .ok_or(MemoryError::Resource)?;
    let shift = u32::try_from(index % 8)
        .map_err(|_| MemoryError::Internal)?
        .checked_mul(8)
        .ok_or(MemoryError::Internal)?;
    u8::try_from(
        heap.word(handle, offset)?
            .checked_shr(shift)
            .ok_or(MemoryError::Internal)?
            & 255,
    )
    .map_err(|_| MemoryError::Internal)
}

pub fn bytes_content(heap: &Heap, handle: Handle) -> Result<Vec<u8>, MemoryError> {
    let count = bytes_length(heap, handle)?;
    (0..count)
        .map(|index| {
            bytes_at(
                heap,
                handle,
                i64::try_from(index).map_err(|_| MemoryError::Resource)?,
            )
        })
        .collect()
}
