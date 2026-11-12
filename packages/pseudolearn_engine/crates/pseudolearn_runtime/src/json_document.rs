#![forbid(unsafe_code)]

mod flat;
mod flat_store;
mod heap;
mod number_tokens;
mod render;

use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::json_layout::JsonNodeKind;

pub(super) struct JsonNode {
    pub kind: JsonNodeKind,
    pub first_child: Option<usize>,
    pub child_count: usize,
    pub next_sibling: Option<usize>,
    pub name_offset: usize,
    pub name_length: usize,
    pub value_offset: usize,
    pub value_length: usize,
}

pub fn new_json_document(
    heap: &mut Heap,
    compact_text: &str,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let block = flat::allocate_document(heap, compact_text, roots)?;
    heap::new_view(heap, block, 0, roots)
}

pub fn json_document_text(heap: &Heap, document: Handle) -> Result<String, MemoryError> {
    let (block, node) = heap::view_parts(heap, document)?;
    let mut output = String::new();
    render::write_node(heap, block, node, &mut output)?;
    Ok(output)
}

pub fn json_element_view(
    heap: &mut Heap,
    document: Handle,
    index: i64,
    roots: &[Handle],
) -> Result<Option<Handle>, MemoryError> {
    let (block, node_index) = heap::view_parts(heap, document)?;
    let node = heap::read_node(heap, block, node_index)?;
    if node.kind != JsonNodeKind::Array {
        return Ok(None);
    }
    let index = match usize::try_from(index) {
        Ok(index) => index,
        Err(_) => return Ok(None),
    };
    heap::child_view(
        heap,
        block,
        (node.first_child, node.child_count, index),
        roots,
    )
}

pub fn json_field_view(
    heap: &mut Heap,
    document: Handle,
    name: &str,
    roots: &[Handle],
) -> Result<Option<Handle>, MemoryError> {
    let (block, node_index) = heap::view_parts(heap, document)?;
    let node = heap::read_node(heap, block, node_index)?;
    if node.kind != JsonNodeKind::Object {
        return Ok(None);
    }
    let mut child = node.first_child;
    for _ in 0..node.child_count {
        let child_index = child.ok_or(MemoryError::Internal)?;
        let child_node = heap::read_node(heap, block, child_index)?;
        if heap::read_text(heap, block, child_node.name_offset, child_node.name_length)? == name {
            return heap::new_view(heap, block, child_index, roots).map(Some);
        }
        child = child_node.next_sibling;
    }
    Ok(None)
}

pub fn json_view_parts(heap: &Heap, view: Handle) -> Result<(Handle, u32), MemoryError> {
    let (block, node) = heap::view_parts(heap, view)?;
    Ok((
        block,
        u32::try_from(node).map_err(|_| MemoryError::Internal)?,
    ))
}
