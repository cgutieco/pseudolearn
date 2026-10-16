use crate::{Heap, MemoryError, ValueKind};
use pseudolearn_abi::Handle;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct MemoryCell {
    pub owner: Handle,
    pub index: usize,
}

pub fn element_cell(
    heap: &Heap,
    owner: Handle,
    indices: &[i64],
) -> Result<MemoryCell, MemoryError> {
    let (index, _, _) = crate::array::position(heap, owner, indices)?;
    Ok(MemoryCell { owner, index })
}

pub fn field_cell(heap: &Heap, owner: Handle, index: usize) -> Result<MemoryCell, MemoryError> {
    if owner.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    heap.layout(owner)?
        .fields
        .get(index)
        .ok_or(MemoryError::Internal)?;
    Ok(MemoryCell { owner, index })
}

pub fn read_memory_cell(heap: &Heap, cell: MemoryCell) -> Result<u64, MemoryError> {
    let (payload, kind) = describe(heap, cell)?;
    let word = heap.word(
        cell.owner,
        payload
            .checked_add(cell.index)
            .ok_or(MemoryError::Internal)?,
    )?;
    heap.require(cell.owner, cell.index, (kind, word))
}

pub fn write_memory_cell(heap: &mut Heap, cell: MemoryCell, word: u64) -> Result<(), MemoryError> {
    let (payload, kind) = describe(heap, cell)?;
    heap.store(
        cell.owner,
        payload
            .checked_add(cell.index)
            .ok_or(MemoryError::Internal)?,
        word,
    )?;
    if kind == ValueKind::Integer {
        heap.define_integer(cell.owner, cell.index)?;
    }
    Ok(())
}

fn describe(heap: &Heap, cell: MemoryCell) -> Result<(usize, ValueKind), MemoryError> {
    let header = heap.header(cell.owner)?;
    if header.shape_tag == 1 {
        let total =
            usize::try_from(heap.word(cell.owner, 2)?).map_err(|_| MemoryError::Internal)?;
        if cell.index >= total {
            return Err(MemoryError::IndexOutOfRange);
        }
        return Ok((
            heap.array_payload(cell.owner)?,
            heap.array_element_kind(cell.owner)?,
        ));
    }
    if header.shape_tag > 2 && header.shape_tag < u32::MAX {
        let layout = heap.layout(cell.owner)?;
        let kind = *layout
            .fields
            .get(cell.index)
            .ok_or(MemoryError::IndexOutOfRange)?;
        return Ok((heap.object_payload(cell.owner)?, kind));
    }
    Err(MemoryError::Internal)
}
