use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::channel_layout::{
    CHANNEL_CAPACITY_OFFSET, CHANNEL_HEADER_WORDS, CHANNEL_WIDTH_OFFSET, ChannelLayout,
};

pub fn new_channel_storage(
    heap: &mut Heap,
    layout: ChannelLayout,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let elements = u64::from(layout.capacity)
        .checked_mul(u64::from(layout.element_words))
        .and_then(|count| usize::try_from(count).ok())
        .ok_or(MemoryError::Resource)?;
    let request = AllocationRequest {
        shape: Shape::Channel,
        payload: CHANNEL_HEADER_WORDS,
        elements,
        auxiliary: elements
            .saturating_add(63)
            .checked_div(64)
            .ok_or(MemoryError::Resource)?,
        cells: layout.cells().ok_or(MemoryError::Resource)?,
        literal: false,
    };
    let handle = heap.allocate(request, roots)?;
    heap.store(handle, CHANNEL_CAPACITY_OFFSET, u64::from(layout.capacity))?;
    heap.store(
        handle,
        CHANNEL_WIDTH_OFFSET,
        u64::from(layout.element_words),
    )?;
    Ok(handle)
}
