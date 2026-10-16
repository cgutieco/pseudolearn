use super::{Breadcrumbs, text_content, text_length};
use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::TEXT_ASCII_STATUS_MASK;

pub fn text_character(heap: &mut Heap, handle: Handle, position: i64) -> Result<char, MemoryError> {
    let length = text_length(heap, handle)?;
    let position = u64::try_from(position).map_err(|_| MemoryError::StringPositionOutOfRange)?;
    if position >= length {
        return Err(MemoryError::StringPositionOutOfRange);
    }
    let position = usize::try_from(position).map_err(|_| MemoryError::Resource)?;
    let start = usize::try_from(heap.word(handle, 2)?).map_err(|_| MemoryError::Internal)?;
    let ascii_mask = u64::from(TEXT_ASCII_STATUS_MASK).wrapping_shl(32);
    if heap.word(handle, 0)? & ascii_mask != 0 {
        let index = start.checked_add(position).ok_or(MemoryError::Internal)?;
        return heap
            .arena
            .text
            .as_bytes()
            .get(index)
            .copied()
            .map(char::from)
            .ok_or(MemoryError::Internal);
    }
    let block = position.checked_div(64).ok_or(MemoryError::Internal)?;
    prepare(heap, handle, block)?;
    let byte = heap
        .arena
        .breadcrumbs
        .get(&start)
        .and_then(|crumbs| crumbs.positions.get(block))
        .copied()
        .ok_or(MemoryError::Internal)?;
    text_content(heap, handle)?
        .get(byte..)
        .and_then(|text| text.chars().nth(position.checked_rem(64)?))
        .ok_or(MemoryError::Internal)
}

fn prepare(heap: &mut Heap, handle: Handle, block: usize) -> Result<(), MemoryError> {
    let start = usize::try_from(heap.word(handle, 2)?).map_err(|_| MemoryError::Internal)?;
    let mut crumbs = heap
        .arena
        .breadcrumbs
        .remove(&start)
        .unwrap_or(Breadcrumbs {
            positions: vec![0],
            handle: Handle(0),
            capacity: 0,
        });
    while crumbs.positions.len() <= block {
        let previous = *crumbs.positions.last().ok_or(MemoryError::Internal)?;
        let offset = text_content(heap, handle)?
            .get(previous..)
            .and_then(|text| text.char_indices().nth(64))
            .map(|(offset, _)| offset)
            .ok_or(MemoryError::Internal)?;
        crumbs
            .positions
            .try_reserve(1)
            .map_err(|_| MemoryError::Resource)?;
        crumbs
            .positions
            .push(previous.checked_add(offset).ok_or(MemoryError::Resource)?);
    }
    publish(heap, handle, &mut crumbs)?;
    heap.arena.breadcrumbs.insert(start, crumbs);
    Ok(())
}

fn publish(heap: &mut Heap, owner: Handle, crumbs: &mut Breadcrumbs) -> Result<(), MemoryError> {
    if crumbs.positions.len() > crumbs.capacity {
        let capacity = crumbs
            .positions
            .len()
            .checked_next_power_of_two()
            .ok_or(MemoryError::Resource)?;
        crumbs.handle = heap.allocate(
            AllocationRequest {
                shape: Shape::Auxiliary,
                payload: 2,
                elements: capacity,
                auxiliary: 0,
                cells: 0,
                literal: false,
            },
            &[],
        )?;
        crumbs.capacity = capacity;
        heap.store(crumbs.handle, 1, 0)?;
    }
    let written =
        usize::try_from(heap.word(crumbs.handle, 1)?).map_err(|_| MemoryError::Internal)?;
    for (index, offset) in crumbs.positions.iter().enumerate().skip(written) {
        heap.store(
            crumbs.handle,
            index.checked_add(2).ok_or(MemoryError::Resource)?,
            u64::try_from(*offset).map_err(|_| MemoryError::Resource)?,
        )?;
    }
    heap.store(
        crumbs.handle,
        1,
        u64::try_from(crumbs.positions.len()).map_err(|_| MemoryError::Resource)?,
    )?;
    heap.store(owner, 4, u64::from(crumbs.handle.0))
}

impl Heap {
    pub(super) fn discard_breadcrumbs(&mut self) -> Result<(), MemoryError> {
        self.arena.breadcrumbs.clear();
        let mut headers = Vec::new();
        let mut auxiliary = Vec::new();
        for block in &self.blocks {
            if self.is_text(block.handle)? {
                headers.push(block.handle);
            } else if self.is_auxiliary(block.handle)? {
                auxiliary.push(block.handle);
            }
        }
        for handle in headers {
            self.clear_text_index(handle)?;
        }
        for handle in auxiliary {
            self.release_block(handle)?;
        }
        Ok(())
    }
}
