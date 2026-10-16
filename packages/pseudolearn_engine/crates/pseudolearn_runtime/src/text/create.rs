use crate::heap::{AllocationRequest, Shape};
use crate::{Heap, MemoryError};
use pseudolearn_abi::{
    CommonHeader, Handle, LITERAL_STATUS_MASK, STRING_FIXED_WORDS_COUNT, TEXT_ASCII_STATUS_MASK,
};

pub fn new_text(
    heap: &mut Heap,
    text: &str,
    literal: bool,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let points = u64::try_from(text.chars().count()).map_err(|_| MemoryError::Resource)?;
    let handle = header(heap, points, literal, roots)?;
    let offset = heap.arena.text.len();
    heap.arena
        .text
        .try_reserve(text.len())
        .map_err(|_| MemoryError::Resource)?;
    heap.arena.text.push_str(text);
    finish_header(heap, handle, (offset, text.len()), points)?;
    Ok(handle)
}

pub fn concat_text(
    heap: &mut Heap,
    left: Handle,
    right: Handle,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    super::concat_parts(
        heap,
        super::TextPart::Text(left),
        super::TextPart::Text(right),
        roots,
    )
}

pub(super) fn header(
    heap: &mut Heap,
    points: u64,
    literal: bool,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let cells = if literal {
        0
    } else {
        points
            .checked_div(8)
            .and_then(|whole| {
                whole.checked_add(u64::from(
                    points
                        .checked_rem(8)
                        .is_some_and(|remainder| remainder != 0),
                ))
            })
            .and_then(|count| count.checked_add(1))
            .ok_or(MemoryError::Resource)?
    };
    heap.allocate(
        AllocationRequest {
            shape: Shape::Text,
            payload: STRING_FIXED_WORDS_COUNT,
            elements: 0,
            auxiliary: 0,
            cells,
            literal,
        },
        roots,
    )
}

pub(super) fn finish_header(
    heap: &mut Heap,
    handle: Handle,
    range: (usize, usize),
    points: u64,
) -> Result<(), MemoryError> {
    let ascii = u64::try_from(range.1).map_err(|_| MemoryError::Resource)? == points;
    let ascii_status = if ascii { TEXT_ASCII_STATUS_MASK } else { 0 };
    let literal_status = if heap.is_literal(handle)? {
        LITERAL_STATUS_MASK
    } else {
        0
    };
    let status = ascii_status | literal_status;
    let [shape_and_flags, identity] = CommonHeader::new(2, status, points).to_words();
    heap.store(handle, 0, shape_and_flags.as_u64())?;
    heap.store(handle, 1, identity.as_u64())?;
    heap.store(
        handle,
        2,
        u64::try_from(range.0).map_err(|_| MemoryError::Resource)?,
    )?;
    heap.store(
        handle,
        3,
        u64::try_from(range.1).map_err(|_| MemoryError::Resource)?,
    )?;
    Ok(())
}
