mod access;
mod cell_frames;
mod cells;
mod collections;
pub use cell_frames::{rt_aot_cell_mark, rt_aot_cell_release};
pub use collections::{COLLECTION_PACKET_WORDS, rt_aot_collection};
pub use pseudolearn_abi::{CollectionCommand, DictionaryKeyKind};
mod class_layout;
mod config;
mod context;
mod effects;
mod engine;
mod entry;
mod fault;
mod format;
mod guard;
mod inline_allocation;
mod input;
mod kinds;
mod math;
mod memory;
mod metadata;
mod metadata_codec;
mod output;
mod process;
mod process_report;
mod quoted_text;
mod random;
mod session;
mod text;
pub use quoted_text::rt_aot_text_quote;
mod trap;

pub use access::{rt_aot_array_load, rt_aot_array_store, rt_aot_object_load, rt_aot_object_store};
pub use cells::{
    CELL_SLOT_BYTES, CELL_SLOT_LOCAL_OFFSET, CELL_SLOT_READABLE_OFFSET, CELL_SLOT_WORD_OFFSET,
    rt_aot_cell_element, rt_aot_cell_field, rt_aot_cell_load, rt_aot_cell_local, rt_aot_cell_store,
};
pub use class_layout::ClassDescriptor;
pub use config::{AotConfig, AotLimits, AotStreams, BooleanWords};
pub use context::{
    AotRuntimeContext, CONTEXT_CELLS_LENGTH_OFFSET, CONTEXT_CELLS_POINTER_OFFSET,
    CONTEXT_FAULT_SITE_OFFSET, CONTEXT_FAULT_STATUS_OFFSET, CONTEXT_FRAME_DEPTH_OFFSET,
    CONTEXT_FRAME_LIMIT_OFFSET, CONTEXT_FREE_SIZE_MASK_OFFSET, CONTEXT_HEAP_LIMIT_OFFSET,
    CONTEXT_HEAP_ORDINAL_OFFSET, CONTEXT_HEAP_USED_OFFSET, CONTEXT_HEAP_WORDS_OFFSET,
    CONTEXT_INSTRUCTION_REMAINING_OFFSET, CONTEXT_PENDING_CAPACITY_OFFSET,
    CONTEXT_PENDING_LENGTH_OFFSET, CONTEXT_PENDING_POINTER_OFFSET, CONTEXT_RESULT_WORD_OFFSET,
    CONTEXT_ROOM_CELLS_OFFSET, CONTEXT_ROOM_THRESHOLD_OFFSET, CONTEXT_ROOT_CAPACITY_OFFSET,
    CONTEXT_ROOT_TOP_OFFSET, CONTEXT_ROOTS_OFFSET, STATUS_CONTINUE, STATUS_FAILED, STATUS_LIMIT,
};
pub use engine::AotEngine;
pub use entry::pseudolearn_aot_main;
pub use effects::rt_aot_effect_call;
pub use fault::{FaultRecord, FaultSite, SourceRange, render_fault};
pub use inline_allocation::{
    INLINE_MAXIMUM_PHYSICAL, INLINE_PHYSICAL_SHIFT, INLINE_RECORD_WORDS, InlineObjectImage,
    class_payload_offset, inline_object_image,
};
pub use input::rt_aot_read;
pub use kinds::{
    CHARACTER_OPERAND_FLAG, KIND_BOOLEAN, KIND_CHARACTER, KIND_INTEGER, KIND_REAL, KIND_REFERENCE,
    NEWLINE_FLAG, PROFILE_SHIFT, RANK_SHIFT,
};
pub use math::{
    MATH_ARCTANGENT, MATH_COSINE, MATH_EXPONENTIAL, MATH_LOGARITHM, MATH_ROUND, MATH_SINE,
    MATH_TRUNCATE, rt_aot_integer_power, rt_aot_math_unary, rt_aot_real_power,
};
pub use memory::{rt_aot_array_new, rt_aot_object_copy, rt_aot_object_new};
pub use metadata::{ExecutableMetadata, ExecutableSettings};
pub use metadata_codec::{decode_metadata, encode_metadata};
pub use output::rt_aot_write;
pub use process::{
    EXIT_COMPLETED, EXIT_FAILED, EXIT_INTERNAL, EXIT_LIMIT, EntryFunction, ProcessStreams,
    run_executable,
};
pub use pseudolearn_diagnostics::DiagnosticCode;
pub use random::rt_aot_random_real;
pub use session::{AotSession, settle_session};
pub use text::{
    TEXT_LENGTH, TEXT_TO_INTEGER, TEXT_TO_REAL, rt_aot_text_character, rt_aot_text_compare,
    rt_aot_text_concat, rt_aot_text_format, rt_aot_text_literal, rt_aot_text_query,
};
pub use trap::rt_aot_fault;

#[cfg(feature = "telemetry")]
mod statistics;
#[cfg(feature = "telemetry")]
pub use statistics::AotStatistics;
