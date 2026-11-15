use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use std::collections::{BTreeMap, VecDeque};

pub fn snapshot_copy(
    heap: &mut Heap,
    source: Handle,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let copied = snapshot_copy_many(heap, &[source], roots)?;
    copied.first().copied().ok_or(MemoryError::Internal)
}

pub fn snapshot_copy_many(
    heap: &mut Heap,
    sources: &[Handle],
    roots: &[Handle],
) -> Result<Vec<Handle>, MemoryError> {
    let graph = crate::snapshot_graph::discover(heap, sources)?;
    let mut retained = roots.to_vec();
    retained.extend_from_slice(sources);
    let mut copies = BTreeMap::new();
    for source in graph.keys() {
        let copied = copy_block(heap, *source, &retained)?;
        retained.push(copied);
        copies.insert(*source, copied);
    }
    let mut patches = VecDeque::new();
    for (source, offsets) in &graph {
        let copied = *copies.get(source).ok_or(MemoryError::Internal)?;
        for offset in offsets {
            let original = Handle(
                u32::try_from(heap.word(*source, *offset)?).map_err(|_| MemoryError::Internal)?,
            );
            let target = copies.get(&original).copied().unwrap_or(original);
            patches.push_back((copied, *offset, target));
        }
    }
    for (copied, offset, target) in patches {
        heap.store(copied, offset, u64::from(target.0))?;
    }
    Ok(sources
        .iter()
        .map(|source| copies.get(source).copied().unwrap_or(*source))
        .collect())
}

fn copy_block(heap: &mut Heap, source: Handle, roots: &[Handle]) -> Result<Handle, MemoryError> {
    let block = heap.block(source)?;
    let size = usize::try_from(block.physical).map_err(|_| MemoryError::Resource)?;
    let start = usize::try_from(source.0).map_err(|_| MemoryError::Internal)?;
    let end = start.checked_add(size).ok_or(MemoryError::Resource)?;
    let words = heap
        .words
        .get(start..end)
        .ok_or(MemoryError::Internal)?
        .to_vec();
    heap.prepare(block.cells, roots)?;
    let copied = heap.allocate(
        AllocationRequest {
            shape: Shape::Auxiliary,
            payload: size,
            elements: 0,
            auxiliary: 0,
            cells: block.cells,
            literal: false,
        },
        roots,
    )?;
    for (offset, word) in words.into_iter().enumerate() {
        heap.store(copied, offset, word)?;
    }
    relocate_array_definition(heap, source, copied)?;
    if heap.header(source)?.shape_tag != u32::MAX {
        heap.ordinal = heap.ordinal.checked_add(1).ok_or(MemoryError::Resource)?;
        heap.store(copied, 1, heap.ordinal)?;
    }
    Ok(copied)
}

fn relocate_array_definition(
    heap: &mut Heap,
    source: Handle,
    copied: Handle,
) -> Result<(), MemoryError> {
    if heap.header(source)?.shape_tag == 1
        && heap.array_element_kind(source)? == crate::ValueKind::Integer
    {
        let offset = pseudolearn_abi::ARRAY_DEFINITION_MAP_WORD_OFFSET;
        let address = heap.word(source, offset)?;
        if address != 0 {
            let relative = address
                .checked_sub(u64::from(source.0))
                .ok_or(MemoryError::Internal)?;
            heap.store(
                copied,
                offset,
                u64::from(copied.0)
                    .checked_add(relative)
                    .ok_or(MemoryError::Resource)?,
            )?;
        }
    }
    Ok(())
}
