use crate::heap::{AllocationRequest, Shape};
use crate::{CapabilityKind, CapabilityToken, Heap, MemoryError, RightsMask};
use pseudolearn_abi::{
    Handle,
    capability_layout::{CAPABILITY_HEADER_WORDS, CAPABILITY_SHAPE_TAG},
};

pub fn new_capability(
    heap: &mut Heap,
    token: CapabilityToken,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let handle = heap.allocate(
        AllocationRequest {
            shape: Shape::Capability,
            payload: CAPABILITY_HEADER_WORDS,
            elements: 0,
            auxiliary: 0,
            cells: 1,
            literal: false,
        },
        roots,
    )?;
    heap.store(handle, 2, u64::from(token.slot))?;
    heap.store(handle, 3, token.generation)?;
    let rights = u64::from(token.rights.read)
        | (u64::from(token.rights.write) << 1)
        | (u64::from(token.rights.execute) << 2);
    heap.store(handle, 4, rights)?;
    heap.store(handle, 5, u64::from(token.kind.to_tag()))?;
    Ok(handle)
}

pub fn capability_token(heap: &Heap, handle: Handle) -> Result<CapabilityToken, MemoryError> {
    if heap.header(handle)?.shape_tag != CAPABILITY_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    let rights = heap.word(handle, 4)?;
    let tag = u32::try_from(heap.word(handle, 5)?).map_err(|_| MemoryError::Internal)?;
    Ok(CapabilityToken {
        slot: u32::try_from(heap.word(handle, 2)?).map_err(|_| MemoryError::Internal)?,
        generation: heap.word(handle, 3)?,
        rights: RightsMask {
            read: rights & 1 != 0,
            write: rights & 2 != 0,
            execute: rights & 4 != 0,
        },
        kind: CapabilityKind::from_tag(tag).ok_or(MemoryError::Internal)?,
    })
}
