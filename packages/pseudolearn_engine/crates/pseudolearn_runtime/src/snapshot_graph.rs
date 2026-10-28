use crate::{Handle, Heap, MemoryError, ValueKind};
use pseudolearn_abi::dictionary_layout::*;
use pseudolearn_abi::vector_layout::*;
use std::collections::{BTreeMap, VecDeque};

type Graph = BTreeMap<Handle, Vec<usize>>;

pub(crate) fn discover(heap: &Heap, roots: &[Handle]) -> Result<Graph, MemoryError> {
    let mut graph = Graph::new();
    let mut pending: VecDeque<_> = roots.iter().map(|handle| (*handle, Vec::new())).collect();
    while let Some((handle, reference_buffer)) = pending.pop_front() {
        if handle.is_absent() || graph.contains_key(&handle) || shared(heap, handle)? {
            continue;
        }
        let offsets = offsets(heap, handle, reference_buffer)?;
        for offset in &offsets {
            let target = Handle(
                u32::try_from(heap.word(handle, *offset)?).map_err(|_| MemoryError::Internal)?,
            );
            let references = buffer_references(heap, handle, *offset)?;
            pending.push_back((target, references));
        }
        graph.insert(handle, offsets);
    }
    Ok(graph)
}

fn shared(heap: &Heap, handle: Handle) -> Result<bool, MemoryError> {
    Ok(matches!(
        heap.header(handle)?.shape_tag,
        2 | pseudolearn_abi::capability_layout::CAPABILITY_SHAPE_TAG
            | pseudolearn_abi::channel_layout::CHANNEL_SHAPE_TAG
    ))
}

fn offsets(
    heap: &Heap,
    handle: Handle,
    reference_buffer: Vec<usize>,
) -> Result<Vec<usize>, MemoryError> {
    match heap.header(handle)?.shape_tag {
        1 => array_offsets(heap, handle),
        VECTOR_SHAPE_TAG => Ok(vec![
            COLLECTION_SCALARS_OFFSET,
            COLLECTION_REFERENCES_OFFSET,
        ]),
        DICTIONARY_SHAPE_TAG => Ok(vec![
            COLLECTION_SCALARS_OFFSET,
            COLLECTION_REFERENCES_OFFSET,
            DICTIONARY_KEYS_OFFSET,
            DICTIONARY_HASHES_OFFSET,
            DICTIONARY_INDEX_OFFSET,
            DICTIONARY_OCCUPIED_OFFSET,
        ]),
        u32::MAX => Ok(reference_buffer),
        pseudolearn_abi::bytes_layout::BYTES_SHAPE_TAG => Ok(Vec::new()),
        _ => Err(MemoryError::Internal),
    }
}

fn array_offsets(heap: &Heap, handle: Handle) -> Result<Vec<usize>, MemoryError> {
    let mut offsets = Vec::new();
    if heap.array_element_kind(handle)? == ValueKind::Reference {
        let total =
            usize::try_from(heap.word(handle, pseudolearn_abi::ARRAY_TOTAL_ELEMENTS_WORD_OFFSET)?)
                .map_err(|_| MemoryError::Internal)?;
        let start = heap.array_payload(handle)?;
        let end = start.checked_add(total).ok_or(MemoryError::Resource)?;
        offsets.extend(start..end);
    }
    Ok(offsets)
}

fn buffer_references(heap: &Heap, owner: Handle, offset: usize) -> Result<Vec<usize>, MemoryError> {
    let tag = heap.header(owner)?.shape_tag;
    if !matches!(tag, VECTOR_SHAPE_TAG | DICTIONARY_SHAPE_TAG) {
        return Ok(Vec::new());
    }
    let dictionary = tag == DICTIONARY_SHAPE_TAG;
    let width = if offset == COLLECTION_REFERENCES_OFFSET {
        crate::collection_layout(heap, owner)?.reference_words
    } else if dictionary
        && offset == DICTIONARY_KEYS_OFFSET
        && heap.word(owner, DICTIONARY_KEY_KIND_OFFSET)?
            == u64::from(pseudolearn_abi::DictionaryKeyKind::String.code())
    {
        1
    } else {
        return Ok(Vec::new());
    };
    active_slots(heap, owner, (dictionary, width))
}

fn active_slots(heap: &Heap, owner: Handle, shape: (bool, u32)) -> Result<Vec<usize>, MemoryError> {
    let (dictionary, width) = shape;
    let count = heap.word(
        owner,
        if dictionary {
            DICTIONARY_USED_OFFSET
        } else {
            COLLECTION_LENGTH_OFFSET
        },
    )?;
    let mut slots = Vec::new();
    for index in 0..count {
        if dictionary && !occupied(heap, owner, index)? {
            continue;
        }
        for field in 0..u64::from(width) {
            let position = index
                .checked_mul(u64::from(width))
                .and_then(|position| position.checked_add(field))
                .and_then(|position| usize::try_from(position).ok())
                .and_then(|position| position.checked_add(COLLECTION_BUFFER_OFFSET))
                .ok_or(MemoryError::Resource)?;
            slots.push(position);
        }
    }
    Ok(slots)
}

fn occupied(heap: &Heap, owner: Handle, index: u64) -> Result<bool, MemoryError> {
    let buffer = Handle(
        u32::try_from(heap.word(owner, DICTIONARY_OCCUPIED_OFFSET)?)
            .map_err(|_| MemoryError::Internal)?,
    );
    Ok(crate::collection::storage::read_word(heap, buffer, index)? != 0)
}
