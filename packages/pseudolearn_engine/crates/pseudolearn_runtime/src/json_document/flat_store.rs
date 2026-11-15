use super::JsonNode;
use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::COMMON_HEADER_WORDS;
use pseudolearn_abi::json_layout::{
    JSON_BLOCK_HEADER_WORDS, JSON_BLOCK_NODE_COUNT_WORD_OFFSET, JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET,
    JSON_NODE_WORD_OFFSETS, JSON_NODE_WORDS,
};

const EMPTY_NODE_INDEX: u64 = u64::MAX;

pub(super) fn allocate_block(
    heap: &mut Heap,
    nodes: &[JsonNode],
    text: &[u8],
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let request = block_request(nodes, text)?;
    let payload = request.payload;
    let block = heap.allocate(request, roots)?;
    store_block_contents(heap, block, (nodes, text, payload))?;
    Ok(block)
}

fn block_request(nodes: &[JsonNode], text: &[u8]) -> Result<AllocationRequest, MemoryError> {
    let table_words = nodes
        .len()
        .checked_mul(JSON_NODE_WORDS)
        .and_then(|words| JSON_BLOCK_HEADER_WORDS.checked_add(words))
        .ok_or(MemoryError::Resource)?;
    let text_words = text
        .len()
        .checked_add(7)
        .and_then(|length| length.checked_div(8))
        .ok_or(MemoryError::Resource)?;
    let payload = COMMON_HEADER_WORDS
        .checked_add(table_words)
        .ok_or(MemoryError::Resource)?;
    let cells = u64::try_from(nodes.len())
        .ok()
        .and_then(|count| count.checked_add(u64::try_from(text_words).ok()?))
        .ok_or(MemoryError::Resource)?;
    Ok(AllocationRequest {
        shape: Shape::JsonBlock,
        payload,
        elements: text_words,
        auxiliary: 0,
        cells,
        literal: false,
    })
}

fn store_block_contents(
    heap: &mut Heap,
    block: Handle,
    contents: (&[JsonNode], &[u8], usize),
) -> Result<(), MemoryError> {
    let (nodes, text, payload) = contents;
    heap.store(
        block,
        JSON_BLOCK_NODE_COUNT_WORD_OFFSET,
        u64::try_from(nodes.len()).map_err(|_| MemoryError::Resource)?,
    )?;
    heap.store(
        block,
        JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET,
        u64::try_from(text.len()).map_err(|_| MemoryError::Resource)?,
    )?;
    store_nodes(heap, block, nodes)?;
    store_text(heap, block, payload, text)
}

fn store_nodes(heap: &mut Heap, block: Handle, nodes: &[JsonNode]) -> Result<(), MemoryError> {
    for (index, node) in nodes.iter().enumerate() {
        store_node(heap, block, (index, node))?;
    }
    Ok(())
}

fn store_node(
    heap: &mut Heap,
    block: Handle,
    entry: (usize, &JsonNode),
) -> Result<(), MemoryError> {
    let (index, node) = entry;
    let start = COMMON_HEADER_WORDS
        .checked_add(JSON_BLOCK_HEADER_WORDS)
        .and_then(|start| start.checked_add(index.checked_mul(JSON_NODE_WORDS)?))
        .ok_or(MemoryError::Resource)?;
    let values = [
        u64::from(node.kind.tag()),
        encode_index(node.first_child)?,
        u64::try_from(node.child_count).map_err(|_| MemoryError::Resource)?,
        encode_index(node.next_sibling)?,
        u64::try_from(node.name_offset).map_err(|_| MemoryError::Resource)?,
        u64::try_from(node.name_length).map_err(|_| MemoryError::Resource)?,
        u64::try_from(node.value_offset).map_err(|_| MemoryError::Resource)?,
        u64::try_from(node.value_length).map_err(|_| MemoryError::Resource)?,
    ];
    for (offset, value) in JSON_NODE_WORD_OFFSETS.into_iter().zip(values) {
        heap.store(
            block,
            start.checked_add(offset).ok_or(MemoryError::Resource)?,
            value,
        )?;
    }
    Ok(())
}

fn store_text(
    heap: &mut Heap,
    block: Handle,
    text_start: usize,
    text: &[u8],
) -> Result<(), MemoryError> {
    for (index, byte) in text.iter().copied().enumerate() {
        let word_offset = text_start
            .checked_add(index.checked_div(8).ok_or(MemoryError::Internal)?)
            .ok_or(MemoryError::Resource)?;
        let shift = u32::try_from(index.checked_rem(8).ok_or(MemoryError::Internal)?)
            .map_err(|_| MemoryError::Internal)?
            .checked_mul(8)
            .ok_or(MemoryError::Internal)?;
        let word = heap.word(block, word_offset)?
            | u64::from(byte)
                .checked_shl(shift)
                .ok_or(MemoryError::Internal)?;
        heap.store(block, word_offset, word)?;
    }
    Ok(())
}

fn encode_index(value: Option<usize>) -> Result<u64, MemoryError> {
    match value {
        Some(index) => u64::try_from(index).map_err(|_| MemoryError::Resource),
        None => Ok(EMPTY_NODE_INDEX),
    }
}
