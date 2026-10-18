#![forbid(unsafe_code)]

use crate::error::CodegenError;
use pseudolearn_aot_rt::{
    CONTEXT_CELLS_LENGTH_OFFSET, CONTEXT_CELLS_POINTER_OFFSET, CONTEXT_FAULT_STATUS_OFFSET,
    CONTEXT_FRAME_DEPTH_OFFSET, CONTEXT_FRAME_LIMIT_OFFSET, CONTEXT_FREE_SIZE_MASK_OFFSET,
    CONTEXT_HEAP_LIMIT_OFFSET, CONTEXT_HEAP_ORDINAL_OFFSET, CONTEXT_HEAP_USED_OFFSET,
    CONTEXT_HEAP_WORDS_OFFSET, CONTEXT_INSTRUCTION_REMAINING_OFFSET,
    CONTEXT_PENDING_CAPACITY_OFFSET, CONTEXT_PENDING_LENGTH_OFFSET, CONTEXT_PENDING_POINTER_OFFSET,
    CONTEXT_RESULT_WORD_OFFSET, CONTEXT_ROOM_CELLS_OFFSET, CONTEXT_ROOM_THRESHOLD_OFFSET,
    CONTEXT_ROOT_CAPACITY_OFFSET, CONTEXT_ROOT_TOP_OFFSET, CONTEXT_ROOTS_OFFSET,
};

#[derive(Clone, Copy, Debug)]
pub(crate) struct AllocationLayout {
    pub(crate) used: i32,
    pub(crate) limit: i32,
    pub(crate) ordinal: i32,
    pub(crate) room_cells: i32,
    pub(crate) room_threshold: i32,
    pub(crate) free_size_mask: i32,
    pub(crate) pending_pointer: i32,
    pub(crate) pending_length: i32,
    pub(crate) pending_capacity: i32,
}

#[derive(Clone, Copy, Debug)]
pub(crate) struct ContextLayout {
    pub(crate) allocation: AllocationLayout,
    pub(crate) instruction_remaining: i32,
    pub(crate) frame_depth: i32,
    pub(crate) frame_limit: i32,
    pub(crate) fault_status: i32,
    pub(crate) result_word: i32,
    pub(crate) heap_words: i32,
    pub(crate) root_top: i32,
    pub(crate) root_capacity: i32,
    pub(crate) roots_pointer: i32,
    pub(crate) cells_pointer: i32,
    pub(crate) cells_length: i32,
}

impl ContextLayout {
    pub(crate) fn new() -> Result<Self, CodegenError> {
        Ok(Self {
            allocation: AllocationLayout {
                used: offset(CONTEXT_HEAP_USED_OFFSET)?,
                limit: offset(CONTEXT_HEAP_LIMIT_OFFSET)?,
                ordinal: offset(CONTEXT_HEAP_ORDINAL_OFFSET)?,
                room_cells: offset(CONTEXT_ROOM_CELLS_OFFSET)?,
                room_threshold: offset(CONTEXT_ROOM_THRESHOLD_OFFSET)?,
                free_size_mask: offset(CONTEXT_FREE_SIZE_MASK_OFFSET)?,
                pending_pointer: offset(CONTEXT_PENDING_POINTER_OFFSET)?,
                pending_length: offset(CONTEXT_PENDING_LENGTH_OFFSET)?,
                pending_capacity: offset(CONTEXT_PENDING_CAPACITY_OFFSET)?,
            },
            instruction_remaining: offset(CONTEXT_INSTRUCTION_REMAINING_OFFSET)?,
            frame_depth: offset(CONTEXT_FRAME_DEPTH_OFFSET)?,
            frame_limit: offset(CONTEXT_FRAME_LIMIT_OFFSET)?,
            fault_status: offset(CONTEXT_FAULT_STATUS_OFFSET)?,
            result_word: offset(CONTEXT_RESULT_WORD_OFFSET)?,
            heap_words: offset(CONTEXT_HEAP_WORDS_OFFSET)?,
            root_top: offset(CONTEXT_ROOT_TOP_OFFSET)?,
            root_capacity: offset(CONTEXT_ROOT_CAPACITY_OFFSET)?,
            roots_pointer: offset(CONTEXT_ROOTS_OFFSET)?,
            cells_pointer: offset(CONTEXT_CELLS_POINTER_OFFSET)?,
            cells_length: offset(CONTEXT_CELLS_LENGTH_OFFSET)?,
        })
    }
}

fn offset(value: usize) -> Result<i32, CodegenError> {
    i32::try_from(value).map_err(|_| CodegenError::InvalidModule("context offset out of range"))
}
