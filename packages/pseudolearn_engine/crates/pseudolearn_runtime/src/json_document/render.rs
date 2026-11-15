use super::JsonNode;
use super::heap::{read_node, read_text};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::json_layout::JsonNodeKind;

pub(super) fn write_node(
    heap: &Heap,
    block: Handle,
    index: usize,
    output: &mut String,
) -> Result<(), MemoryError> {
    let node = read_node(heap, block, index)?;
    match node.kind {
        JsonNodeKind::Null => output.push_str("null"),
        JsonNodeKind::Boolean | JsonNodeKind::Number => {
            output.push_str(&read_text(
                heap,
                block,
                node.value_offset,
                node.value_length,
            )?);
        }
        JsonNodeKind::String => write_string_value(heap, block, &node, output)?,
        JsonNodeKind::Array | JsonNodeKind::Object => {
            write_children(heap, block, &node, output)?;
        }
    }
    Ok(())
}

fn write_string_value(
    heap: &Heap,
    block: Handle,
    node: &JsonNode,
    output: &mut String,
) -> Result<(), MemoryError> {
    let value = read_text(heap, block, node.value_offset, node.value_length)?;
    output.push_str(&serde_json::to_string(&value).map_err(|_| MemoryError::Internal)?);
    Ok(())
}

fn write_children(
    heap: &Heap,
    block: Handle,
    node: &JsonNode,
    output: &mut String,
) -> Result<(), MemoryError> {
    let object = node.kind == JsonNodeKind::Object;
    output.push(if object { '{' } else { '[' });
    let mut child = node.first_child;
    for index in 0..node.child_count {
        if index > 0 {
            output.push(',');
        }
        let child_index = child.ok_or(MemoryError::Internal)?;
        write_child(heap, block, (child_index, object), output)?;
        child = read_node(heap, block, child_index)?.next_sibling;
    }
    output.push(if object { '}' } else { ']' });
    Ok(())
}

fn write_child(
    heap: &Heap,
    block: Handle,
    child: (usize, bool),
    output: &mut String,
) -> Result<(), MemoryError> {
    let (index, object) = child;
    if object {
        let child = read_node(heap, block, index)?;
        let name = read_text(heap, block, child.name_offset, child.name_length)?;
        output.push_str(&serde_json::to_string(&name).map_err(|_| MemoryError::Internal)?);
        output.push(':');
    }
    write_node(heap, block, index, output)
}
