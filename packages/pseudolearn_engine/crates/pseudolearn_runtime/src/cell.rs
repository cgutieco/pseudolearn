use crate::heap::Shape;
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
    let entry = heap.allocations.get(&owner).ok_or(MemoryError::Internal)?;
    let Shape::Object(layout) = &entry.shape else {
        return Err(MemoryError::Internal);
    };
    layout.fields.get(index).ok_or(MemoryError::Internal)?;
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
    let entry = heap
        .allocations
        .get(&cell.owner)
        .ok_or(MemoryError::Internal)?;
    if matches!(
        entry.shape,
        Shape::Array {
            element: ValueKind::Integer,
            ..
        }
    ) && entry.assigned == entry.elements
    {
        heap.store(
            cell.owner,
            3,
            u64::try_from(entry.assigned).map_err(|_| MemoryError::Internal)?,
        )?;
    }
    Ok(())
}

fn describe(heap: &Heap, cell: MemoryCell) -> Result<(usize, ValueKind), MemoryError> {
    let entry = heap
        .allocations
        .get(&cell.owner)
        .ok_or(MemoryError::Internal)?;
    let kind = match &entry.shape {
        Shape::Array { element, .. } if cell.index < entry.elements => *element,
        Shape::Object(layout) => *layout.fields.get(cell.index).ok_or(MemoryError::Internal)?,
        _ => return Err(MemoryError::Internal),
    };
    Ok((entry.payload, kind))
}
