use super::create::{finish_header, header};
use super::{text_content, text_length};
use crate::{Handle, Heap, MemoryError};

#[derive(Clone, Copy)]
pub enum TextPart {
    Text(Handle),
    Character(char),
}

pub fn concat_parts(
    heap: &mut Heap,
    left: TextPart,
    right: TextPart,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let points = length(heap, left)?
        .checked_add(length(heap, right)?)
        .ok_or(MemoryError::Resource)?;
    let mut retained = roots.to_vec();
    for part in [left, right] {
        if let TextPart::Text(handle) = part {
            retained.push(handle);
        }
    }
    let target = header(heap, points, false, &retained)?;
    let bytes = bytes(heap, right)?;
    let (offset, count) = prefix(heap, left)?;
    heap.arena
        .text
        .try_reserve(bytes.len())
        .map_err(|_| MemoryError::Resource)?;
    heap.arena
        .text
        .push_str(std::str::from_utf8(&bytes).map_err(|_| MemoryError::Internal)?);
    let count = count
        .checked_add(bytes.len())
        .ok_or(MemoryError::Resource)?;
    finish_header(heap, target, (offset, count), points)?;
    Ok(target)
}

fn prefix(heap: &mut Heap, part: TextPart) -> Result<(usize, usize), MemoryError> {
    if let TextPart::Text(handle) = part {
        let offset = usize::try_from(heap.word(handle, 2)?).map_err(|_| MemoryError::Internal)?;
        let count = usize::try_from(heap.word(handle, 3)?).map_err(|_| MemoryError::Internal)?;
        if offset.checked_add(count) == Some(heap.arena.text.len()) {
            return Ok((offset, count));
        }
    }
    let bytes = bytes(heap, part)?;
    let offset = heap.arena.text.len();
    heap.arena
        .text
        .try_reserve(bytes.len())
        .map_err(|_| MemoryError::Resource)?;
    heap.arena
        .text
        .push_str(std::str::from_utf8(&bytes).map_err(|_| MemoryError::Internal)?);
    Ok((offset, bytes.len()))
}

fn length(heap: &Heap, part: TextPart) -> Result<u64, MemoryError> {
    match part {
        TextPart::Text(handle) => text_length(heap, handle),
        TextPart::Character(_) => Ok(1),
    }
}

fn bytes(heap: &Heap, part: TextPart) -> Result<Vec<u8>, MemoryError> {
    match part {
        TextPart::Text(handle) => Ok(text_content(heap, handle)?.as_bytes().to_vec()),
        TextPart::Character(character) => Ok(character.to_string().into_bytes()),
    }
}
