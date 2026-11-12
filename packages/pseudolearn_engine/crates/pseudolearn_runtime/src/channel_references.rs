use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::channel_layout::*;

pub fn channel_identity(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    if heap.header(handle)?.shape_tag != CHANNEL_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    heap.word(handle, CHANNEL_IDENTITY_OFFSET)
}

pub fn set_channel_identity(
    heap: &mut Heap,
    handle: Handle,
    identity: u64,
) -> Result<(), MemoryError> {
    heap.store(handle, CHANNEL_IDENTITY_OFFSET, identity)
}

pub fn store_channel_slot(
    heap: &mut Heap,
    handle: Handle,
    slot: usize,
    words: &[(u64, bool)],
) -> Result<(), MemoryError> {
    let width = usize::try_from(heap.word(handle, CHANNEL_WIDTH_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    let total = total(heap, handle)?;
    if words.len() > width {
        return Err(MemoryError::Internal);
    }
    let start = slot.checked_mul(width).ok_or(MemoryError::Internal)?;
    for index in 0..width {
        let index = start
            .checked_add(index)
            .filter(|index| *index < total)
            .ok_or(MemoryError::Internal)?;
        let (word, reference) = words
            .get(index.saturating_sub(start))
            .copied()
            .unwrap_or((0, false));
        heap.store(
            handle,
            CHANNEL_HEADER_WORDS
                .checked_add(index)
                .ok_or(MemoryError::Internal)?,
            word,
        )?;
        set_reference_bit(heap, handle, (total, index), reference)?;
    }
    Ok(())
}

pub(crate) fn references(
    heap: &Heap,
    handle: Handle,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    let total = total(heap, handle)?;
    for index in 0..total {
        let mask_offset = CHANNEL_HEADER_WORDS
            .checked_add(total)
            .and_then(|offset| offset.checked_add(index.checked_div(64)?))
            .ok_or(MemoryError::Internal)?;
        let bit = 1_u64.wrapping_shl(
            u32::try_from(index.checked_rem(64).ok_or(MemoryError::Internal)?)
                .map_err(|_| MemoryError::Internal)?,
        );
        if heap.word(handle, mask_offset)? & bit != 0 {
            pending.push(Handle(
                u32::try_from(
                    heap.word(
                        handle,
                        CHANNEL_HEADER_WORDS
                            .checked_add(index)
                            .ok_or(MemoryError::Internal)?,
                    )?,
                )
                .map_err(|_| MemoryError::Internal)?,
            ));
        }
    }
    Ok(())
}

fn total(heap: &Heap, handle: Handle) -> Result<usize, MemoryError> {
    heap.word(handle, CHANNEL_CAPACITY_OFFSET)?
        .checked_mul(heap.word(handle, CHANNEL_WIDTH_OFFSET)?)
        .and_then(|total| usize::try_from(total).ok())
        .ok_or(MemoryError::Internal)
}

fn set_reference_bit(
    heap: &mut Heap,
    handle: Handle,
    (total, index): (usize, usize),
    reference: bool,
) -> Result<(), MemoryError> {
    let mask_offset = CHANNEL_HEADER_WORDS
        .checked_add(total)
        .and_then(|offset| offset.checked_add(index.checked_div(64)?))
        .ok_or(MemoryError::Internal)?;
    let bit = 1_u64.wrapping_shl(
        u32::try_from(index.checked_rem(64).ok_or(MemoryError::Internal)?)
            .map_err(|_| MemoryError::Internal)?,
    );
    let mask = heap.word(handle, mask_offset)?;
    heap.store(
        handle,
        mask_offset,
        if reference { mask | bit } else { mask & !bit },
    )?;
    Ok(())
}
