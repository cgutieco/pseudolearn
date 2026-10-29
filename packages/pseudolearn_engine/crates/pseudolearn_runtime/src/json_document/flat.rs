use super::JsonNode;
use crate::{Handle, Heap, MemoryError};
use serde_json::Value;

const MAXIMUM_JSON_DEPTH: usize = 64;

struct FlatBuilder {
    nodes: Vec<JsonNode>,
    text: Vec<u8>,
    number_tokens: Vec<String>,
    next_number: usize,
}

struct ChildLink {
    depth: usize,
    parent: usize,
    previous: Option<usize>,
}

pub(super) fn allocate_document(
    heap: &mut Heap,
    source: &str,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let value = serde_json::from_str(source).map_err(|_| MemoryError::Internal)?;
    let mut builder = FlatBuilder {
        nodes: Vec::new(),
        text: Vec::new(),
        number_tokens: super::number_tokens::scan_number_tokens(source)?,
        next_number: 0,
    };
    flatten_node(&value, None, 0, &mut builder)?;
    if builder.next_number != builder.number_tokens.len() {
        return Err(MemoryError::Internal);
    }
    super::flat_store::allocate_block(heap, &builder.nodes, &builder.text, roots)
}

fn flatten_node(
    value: &Value,
    name: Option<&str>,
    depth: usize,
    builder: &mut FlatBuilder,
) -> Result<usize, MemoryError> {
    if depth > MAXIMUM_JSON_DEPTH {
        return Err(MemoryError::Resource);
    }
    builder
        .nodes
        .try_reserve(1)
        .map_err(|_| MemoryError::Resource)?;
    let index = builder.nodes.len();
    let (name_offset, name_length) = append_text(name.unwrap_or_default(), &mut builder.text)?;
    let (kind, value_offset, value_length) = scalar_payload(value, builder)?;
    builder.nodes.push(JsonNode {
        kind,
        first_child: None,
        child_count: 0,
        next_sibling: None,
        name_offset,
        name_length,
        value_offset,
        value_length,
    });
    flatten_children(value, depth, index, builder)?;
    Ok(index)
}

fn scalar_payload(
    value: &Value,
    builder: &mut FlatBuilder,
) -> Result<(pseudolearn_abi::json_layout::JsonNodeKind, usize, usize), MemoryError> {
    use pseudolearn_abi::json_layout::JsonNodeKind;

    if matches!(value, Value::Number(_)) {
        return number_payload(builder);
    }
    let (kind, scalar) = match value {
        Value::Null => (JsonNodeKind::Null, None),
        Value::Bool(value) => (
            JsonNodeKind::Boolean,
            Some(if *value {
                "true".to_owned()
            } else {
                "false".to_owned()
            }),
        ),
        Value::Number(_) => return Err(MemoryError::Internal),
        Value::String(value) => (JsonNodeKind::String, Some(value.clone())),
        Value::Array(_) => (JsonNodeKind::Array, None),
        Value::Object(_) => (JsonNodeKind::Object, None),
    };
    match scalar {
        Some(value) => {
            let (offset, length) = append_text(&value, &mut builder.text)?;
            Ok((kind, offset, length))
        }
        None => Ok((kind, 0, 0)),
    }
}

fn number_payload(
    builder: &mut FlatBuilder,
) -> Result<(pseudolearn_abi::json_layout::JsonNodeKind, usize, usize), MemoryError> {
    let token = builder
        .number_tokens
        .get(builder.next_number)
        .ok_or(MemoryError::Internal)?
        .clone();
    builder.next_number = builder
        .next_number
        .checked_add(1)
        .ok_or(MemoryError::Resource)?;
    let (offset, length) = append_text(&token, &mut builder.text)?;
    Ok((
        pseudolearn_abi::json_layout::JsonNodeKind::Number,
        offset,
        length,
    ))
}

fn flatten_children(
    value: &Value,
    depth: usize,
    parent: usize,
    builder: &mut FlatBuilder,
) -> Result<(), MemoryError> {
    match value {
        Value::Array(values) => {
            let mut link = ChildLink {
                depth,
                parent,
                previous: None,
            };
            for value in values {
                append_child(value, None, &mut link, builder)?;
            }
        }
        Value::Object(values) => {
            let mut link = ChildLink {
                depth,
                parent,
                previous: None,
            };
            for (name, value) in values {
                append_child(value, Some(name), &mut link, builder)?;
            }
        }
        _ => {}
    }
    Ok(())
}

fn append_child(
    value: &Value,
    name: Option<&str>,
    link: &mut ChildLink,
    builder: &mut FlatBuilder,
) -> Result<(), MemoryError> {
    let child = flatten_node(
        value,
        name,
        link.depth.checked_add(1).ok_or(MemoryError::Resource)?,
        builder,
    )?;
    if let Some(previous) = link.previous {
        builder
            .nodes
            .get_mut(previous)
            .ok_or(MemoryError::Internal)?
            .next_sibling = Some(child);
    } else {
        builder
            .nodes
            .get_mut(link.parent)
            .ok_or(MemoryError::Internal)?
            .first_child = Some(child);
    }
    link.previous = Some(child);
    let parent_node = builder
        .nodes
        .get_mut(link.parent)
        .ok_or(MemoryError::Internal)?;
    parent_node.child_count = parent_node
        .child_count
        .checked_add(1)
        .ok_or(MemoryError::Resource)?;
    Ok(())
}

fn append_text(value: &str, text: &mut Vec<u8>) -> Result<(usize, usize), MemoryError> {
    let offset = text.len();
    text.try_reserve(value.len())
        .map_err(|_| MemoryError::Resource)?;
    text.extend_from_slice(value.as_bytes());
    Ok((offset, value.len()))
}
