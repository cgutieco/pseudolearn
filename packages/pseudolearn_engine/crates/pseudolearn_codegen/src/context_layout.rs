#![forbid(unsafe_code)]

use crate::error::CodegenError;
use pseudolearn_aot_rt::{
    CONTEXT_FAULT_STATUS_OFFSET, CONTEXT_FRAME_DEPTH_OFFSET, CONTEXT_FRAME_LIMIT_OFFSET,
    CONTEXT_HEAP_WORDS_OFFSET, CONTEXT_INSTRUCTION_REMAINING_OFFSET, CONTEXT_RESULT_WORD_OFFSET,
    CONTEXT_ROOT_CAPACITY_OFFSET, CONTEXT_ROOT_TOP_OFFSET, CONTEXT_ROOTS_OFFSET,
};

#[derive(Clone, Copy, Debug)]
pub(crate) struct ContextLayout {
    pub(crate) instruction_remaining: i32,
    pub(crate) frame_depth: i32,
    pub(crate) frame_limit: i32,
    pub(crate) fault_status: i32,
    pub(crate) result_word: i32,
    pub(crate) heap_words: i32,
    pub(crate) root_top: i32,
    pub(crate) root_capacity: i32,
    pub(crate) roots_pointer: i32,
}

impl ContextLayout {
    pub(crate) fn new() -> Result<Self, CodegenError> {
        Ok(Self {
            instruction_remaining: offset(CONTEXT_INSTRUCTION_REMAINING_OFFSET)?,
            frame_depth: offset(CONTEXT_FRAME_DEPTH_OFFSET)?,
            frame_limit: offset(CONTEXT_FRAME_LIMIT_OFFSET)?,
            fault_status: offset(CONTEXT_FAULT_STATUS_OFFSET)?,
            result_word: offset(CONTEXT_RESULT_WORD_OFFSET)?,
            heap_words: offset(CONTEXT_HEAP_WORDS_OFFSET)?,
            root_top: offset(CONTEXT_ROOT_TOP_OFFSET)?,
            root_capacity: offset(CONTEXT_ROOT_CAPACITY_OFFSET)?,
            roots_pointer: offset(CONTEXT_ROOTS_OFFSET)?,
        })
    }
}

fn offset(value: usize) -> Result<i32, CodegenError> {
    i32::try_from(value).map_err(|_| CodegenError::InvalidModule("context offset out of range"))
}
