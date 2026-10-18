use crate::engine::AotEngine;
use std::mem::offset_of;

pub const STATUS_CONTINUE: u32 = 0;
pub const STATUS_FAILED: u32 = 1;
pub const STATUS_LIMIT: u32 = 2;

#[repr(C)]
pub struct AotRuntimeContext {
    pub heap_words_pointer: *mut u64,
    pub instruction_remaining: i64,
    pub frame_depth: u32,
    pub frame_limit: u32,
    pub root_top: u32,
    pub root_capacity: u32,
    pub roots_pointer: *mut u32,
    pub fault_site: u32,
    pub fault_status: u32,
    pub result_word: u64,
    pub engine_state: *mut AotEngine,
    pub cells_pointer: *const u8,
    pub cells_length: u64,
    pub heap_used: u64,
    pub heap_limit: u64,
    pub heap_ordinal: u64,
    pub room_cells: i64,
    pub room_threshold: i64,
    pub free_size_mask: u64,
    pub pending_pointer: *mut u64,
    pub pending_length: u64,
    pub pending_capacity: u64,
}

pub const CONTEXT_HEAP_WORDS_OFFSET: usize = offset_of!(AotRuntimeContext, heap_words_pointer);
pub const CONTEXT_INSTRUCTION_REMAINING_OFFSET: usize =
    offset_of!(AotRuntimeContext, instruction_remaining);
pub const CONTEXT_FRAME_DEPTH_OFFSET: usize = offset_of!(AotRuntimeContext, frame_depth);
pub const CONTEXT_FRAME_LIMIT_OFFSET: usize = offset_of!(AotRuntimeContext, frame_limit);
pub const CONTEXT_ROOT_TOP_OFFSET: usize = offset_of!(AotRuntimeContext, root_top);
pub const CONTEXT_ROOTS_OFFSET: usize = offset_of!(AotRuntimeContext, roots_pointer);
pub const CONTEXT_FAULT_SITE_OFFSET: usize = offset_of!(AotRuntimeContext, fault_site);
pub const CONTEXT_FAULT_STATUS_OFFSET: usize = offset_of!(AotRuntimeContext, fault_status);
pub const CONTEXT_RESULT_WORD_OFFSET: usize = offset_of!(AotRuntimeContext, result_word);
pub const CONTEXT_ROOT_CAPACITY_OFFSET: usize = offset_of!(AotRuntimeContext, root_capacity);
pub const CONTEXT_CELLS_POINTER_OFFSET: usize = offset_of!(AotRuntimeContext, cells_pointer);
pub const CONTEXT_CELLS_LENGTH_OFFSET: usize = offset_of!(AotRuntimeContext, cells_length);
pub const CONTEXT_HEAP_USED_OFFSET: usize = offset_of!(AotRuntimeContext, heap_used);
pub const CONTEXT_HEAP_LIMIT_OFFSET: usize = offset_of!(AotRuntimeContext, heap_limit);
pub const CONTEXT_HEAP_ORDINAL_OFFSET: usize = offset_of!(AotRuntimeContext, heap_ordinal);
pub const CONTEXT_ROOM_CELLS_OFFSET: usize = offset_of!(AotRuntimeContext, room_cells);
pub const CONTEXT_ROOM_THRESHOLD_OFFSET: usize = offset_of!(AotRuntimeContext, room_threshold);
pub const CONTEXT_FREE_SIZE_MASK_OFFSET: usize = offset_of!(AotRuntimeContext, free_size_mask);
pub const CONTEXT_PENDING_POINTER_OFFSET: usize = offset_of!(AotRuntimeContext, pending_pointer);
pub const CONTEXT_PENDING_LENGTH_OFFSET: usize = offset_of!(AotRuntimeContext, pending_length);
pub const CONTEXT_PENDING_CAPACITY_OFFSET: usize = offset_of!(AotRuntimeContext, pending_capacity);
