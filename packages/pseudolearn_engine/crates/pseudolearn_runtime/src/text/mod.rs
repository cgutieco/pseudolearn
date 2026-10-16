mod compact;
mod create;
mod parts;

use crate::{Heap, MemoryError};
use pseudolearn_abi::{
    Handle, STRING_ARENA_BYTE_COUNT_WORD_OFFSET, STRING_ARENA_BYTE_OFFSET_WORD_OFFSET,
};

pub use compact::TextCompaction;
pub use create::{concat_text, new_text};
pub use parts::{TextPart, concat_parts};

#[derive(Default)]
pub(crate) struct TextArena {
    pub text: String,
    pub breadcrumbs: std::collections::BTreeMap<usize, Breadcrumbs>,
}

pub(crate) struct Breadcrumbs {
    pub positions: Vec<usize>,
    pub handle: Handle,
    pub capacity: usize,
}

pub fn text_content(heap: &Heap, handle: Handle) -> Result<&str, MemoryError> {
    text_length(heap, handle)?;
    let start = usize::try_from(heap.word(handle, STRING_ARENA_BYTE_OFFSET_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    let length = usize::try_from(heap.word(handle, STRING_ARENA_BYTE_COUNT_WORD_OFFSET)?)
        .map_err(|_| MemoryError::Internal)?;
    heap.arena
        .text
        .get(start..start.checked_add(length).ok_or(MemoryError::Internal)?)
        .ok_or(MemoryError::Internal)
}

pub fn text_length(heap: &Heap, handle: Handle) -> Result<u64, MemoryError> {
    if handle.is_absent() {
        return Err(MemoryError::Uninitialized);
    }
    if heap.word(handle, 0)? & 0xffff_ffff != 2 {
        return Err(MemoryError::Internal);
    }
    heap.word(handle, 1)
}

pub fn compare_text(
    heap: &Heap,
    left: Handle,
    right: Handle,
) -> Result<std::cmp::Ordering, MemoryError> {
    Ok(text_content(heap, left)?
        .chars()
        .cmp(text_content(heap, right)?.chars()))
}

pub use indexed::text_character;
mod indexed;
