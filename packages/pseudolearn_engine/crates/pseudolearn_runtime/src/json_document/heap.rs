use super::JsonNode;
use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::COMMON_HEADER_WORDS;
use pseudolearn_abi::json_layout::{
    JSON_BLOCK_HEADER_WORDS, JSON_BLOCK_NODE_COUNT_WORD_OFFSET, JSON_BLOCK_SHAPE_TAG,
    JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET, JSON_NODE_WORD_OFFSETS, JSON_NODE_WORDS,
    JSON_VIEW_BLOCK_WORD_OFFSET, JSON_VIEW_NODE_WORD_OFFSET, JSON_VIEW_SHAPE_TAG,
};

const EMPTY_NODE_INDEX: u64 = u64::MAX;

pub(super) fn new_view(
    heap: &mut Heap,
    block: Handle,
    node: usize,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let mut retained = roots.to_vec();
    retained.push(block);
    let view = heap.allocate(
        AllocationRequest {
            shape: Shape::JsonView,
            payload: COMMON_HEADER_WORDS
                .checked_add(2)
                .ok_or(MemoryError::Resource)?,
            elements: 0,
            auxiliary: 0,
            cells: 1,
            literal: false,
        },
        &retained,
    )?;
    heap.store(view, JSON_VIEW_BLOCK_WORD_OFFSET, u64::from(block.0))?;
    heap.store(
        view,
        JSON_VIEW_NODE_WORD_OFFSET,
        u64::try_from(node).map_err(|_| MemoryError::Resource)?,
    )?;
    Ok(view)
}

pub(super) fn child_view(
    heap: &mut Heap,
    block: Handle,
    selection: (Option<usize>, usize, usize),
    roots: &[Handle],
) -> Result<Option<Handle>, MemoryError> {
    let (first_child, child_count, target) = selection;
    if target >= child_count {
        return Ok(None);
    }
    let child = child_at(heap, block, first_child, target)?;
    child
        .map(|child| new_view(heap, block, child, roots))
        .transpose()
}

pub(super) fn view_parts(heap: &Heap, view: Handle) -> Result<(Handle, usize), MemoryError> {
    if heap.header(view)?.shape_tag != JSON_VIEW_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    let block = Handle(
        u32::try_from(heap.word(view, JSON_VIEW_BLOCK_WORD_OFFSET)?)
            .map_err(|_| MemoryError::Internal)?,
    );
    if heap.header(block)?.shape_tag != JSON_BLOCK_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    let node = usize::try_from(heap.word(view, JSON_VIEW_NODE_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    let node_count = node_count(heap, block)?;
    if node >= node_count {
        return Err(MemoryError::Internal);
    }
    Ok((block, node))
}

pub(super) fn read_node(heap: &Heap, block: Handle, index: usize) -> Result<JsonNode, MemoryError> {
    if index >= node_count(heap, block)? {
        return Err(MemoryError::Internal);
    }
    let start = COMMON_HEADER_WORDS
        .checked_add(JSON_BLOCK_HEADER_WORDS)
        .and_then(|start| start.checked_add(index.checked_mul(JSON_NODE_WORDS)?))
        .ok_or(MemoryError::Internal)?;
    let [
        kind_word,
        first_child,
        child_count,
        next_sibling,
        name_offset,
        name_length,
        value_offset,
        value_length,
    ] = node_words(heap, block, start)?;
    let kind = match kind_word {
        0 => pseudolearn_abi::json_layout::JsonNodeKind::Null,
        1 => pseudolearn_abi::json_layout::JsonNodeKind::Boolean,
        2 => pseudolearn_abi::json_layout::JsonNodeKind::Number,
        3 => pseudolearn_abi::json_layout::JsonNodeKind::String,
        4 => pseudolearn_abi::json_layout::JsonNodeKind::Array,
        5 => pseudolearn_abi::json_layout::JsonNodeKind::Object,
        _ => return Err(MemoryError::Internal),
    };
    Ok(JsonNode {
        kind,
        first_child: decode_index(first_child)?,
        child_count: usize::try_from(child_count).map_err(|_| MemoryError::Internal)?,
        next_sibling: decode_index(next_sibling)?,
        name_offset: usize::try_from(name_offset).map_err(|_| MemoryError::Internal)?,
        name_length: usize::try_from(name_length).map_err(|_| MemoryError::Internal)?,
        value_offset: usize::try_from(value_offset).map_err(|_| MemoryError::Internal)?,
        value_length: usize::try_from(value_length).map_err(|_| MemoryError::Internal)?,
    })
}

pub(super) fn read_text(
    heap: &Heap,
    block: Handle,
    offset: usize,
    length: usize,
) -> Result<String, MemoryError> {
    let text_length = usize::try_from(heap.word(block, JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    if offset.checked_add(length).ok_or(MemoryError::Internal)? > text_length {
        return Err(MemoryError::Internal);
    }
    let text_start = text_start(heap, block)?;
    let mut bytes = Vec::new();
    bytes
        .try_reserve_exact(length)
        .map_err(|_| MemoryError::Resource)?;
    for byte_index in offset..offset.checked_add(length).ok_or(MemoryError::Internal)? {
        let word_offset = text_start
            .checked_add(byte_index.checked_div(8).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Internal)?;
        let shift = u32::try_from(byte_index.checked_rem(8).ok_or(MemoryError::Internal)?)
            .map_err(|_| MemoryError::Internal)?
            .checked_mul(8)
            .ok_or(MemoryError::Internal)?;
        let byte = heap
            .word(block, word_offset)?
            .checked_shr(shift)
            .ok_or(MemoryError::Internal)?
            & 0xff;
        bytes.push(u8::try_from(byte).map_err(|_| MemoryError::Internal)?);
    }
    String::from_utf8(bytes).map_err(|_| MemoryError::Internal)
}

fn child_at(
    heap: &Heap,
    block: Handle,
    first_child: Option<usize>,
    target: usize,
) -> Result<Option<usize>, MemoryError> {
    let mut child = first_child.ok_or(MemoryError::Internal)?;
    for _ in 0..target {
        child = read_node(heap, block, child)?
            .next_sibling
            .ok_or(MemoryError::Internal)?;
    }
    Ok(Some(child))
}

fn node_count(heap: &Heap, block: Handle) -> Result<usize, MemoryError> {
    usize::try_from(heap.word(block, JSON_BLOCK_NODE_COUNT_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)
}

fn text_start(heap: &Heap, block: Handle) -> Result<usize, MemoryError> {
    let table_words = node_count(heap, block)?
        .checked_mul(JSON_NODE_WORDS)
        .and_then(|words| JSON_BLOCK_HEADER_WORDS.checked_add(words))
        .ok_or(MemoryError::Internal)?;
    COMMON_HEADER_WORDS
        .checked_add(table_words)
        .ok_or(MemoryError::Internal)
}

fn node_words(heap: &Heap, block: Handle, start: usize) -> Result<[u64; 8], MemoryError> {
    let mut words = [0; 8];
    for (index, offset) in JSON_NODE_WORD_OFFSETS.into_iter().enumerate() {
        let word = word_offset(heap, block, start, offset)?;
        *words.get_mut(index).ok_or(MemoryError::Internal)? = word;
    }
    Ok(words)
}

fn word_offset(
    heap: &Heap,
    block: Handle,
    start: usize,
    offset: usize,
) -> Result<u64, MemoryError> {
    heap.word(
        block,
        start.checked_add(offset).ok_or(MemoryError::Internal)?,
    )
}

fn decode_index(value: u64) -> Result<Option<usize>, MemoryError> {
    if value == EMPTY_NODE_INDEX {
        Ok(None)
    } else {
        usize::try_from(value)
            .map(Some)
            .map_err(|_| MemoryError::Internal)
    }
}
