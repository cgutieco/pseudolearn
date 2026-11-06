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
mod effect_channel;
mod effect_console;
mod effect_document;
mod effect_text_faults;
#[cfg(test)]
mod effect_text_faults_tests;
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
#[cfg(not(feature = "test-host"))]
mod physical_provider;
mod process;
mod process_options;
mod process_report;
mod quoted_text;
mod random;
mod session;
mod snapshot;
mod text;
pub use quoted_text::rt_aot_text_quote;
mod task_baton;
mod task_blocking;
mod task_channels;
mod task_completion;
mod task_deadlock;
mod task_effect_await;
mod task_effects;
mod task_entries;
mod task_landing;
mod task_results;
mod task_roots;
mod task_scheduler;
mod task_state;
mod task_switch;
mod task_threads;
mod task_values;
mod trap;
pub use pseudolearn_runtime::TASK_QUANTUM;
pub use task_channels::{
    CHANNEL_CLOSE, CHANNEL_NEW, CHANNEL_RECEIVE, CHANNEL_SELECT, CHANNEL_SELECTED_PRESENT,
    CHANNEL_SEND, rt_aot_task_channel,
};
pub use task_effect_await::rt_aot_effect_await;
pub use task_entries::{
    rt_aot_task_await, rt_aot_task_scope_join, rt_aot_task_scope_open, rt_aot_task_spawn,
    rt_aot_task_yield,
};
pub use task_landing::{
    rt_aot_task_cancel_point, rt_aot_task_land, rt_aot_task_return, rt_aot_task_scope_boundary,
};
pub use task_results::{rt_aot_task_outcome, rt_aot_task_scope_result, rt_aot_task_value_load};
pub use task_state::TaskDispatcher;

pub use access::{rt_aot_array_load, rt_aot_array_store, rt_aot_object_load, rt_aot_object_store};
pub use cells::{
    CELL_SLOT_BYTES, CELL_SLOT_LOCAL_OFFSET, CELL_SLOT_READABLE_OFFSET, CELL_SLOT_WORD_OFFSET,
    rt_aot_cell_element, rt_aot_cell_field, rt_aot_cell_load, rt_aot_cell_local, rt_aot_cell_store,
};
pub use class_layout::ClassDescriptor;
pub use config::{AotConfig, AotLimits, AotStreams, BooleanWords};
pub use context::{
    AotRuntimeContext, CONTEXT_CALLER_SITE_OFFSET, CONTEXT_CELLS_LENGTH_OFFSET,
    CONTEXT_CELLS_POINTER_OFFSET, CONTEXT_FAULT_SITE_OFFSET, CONTEXT_FAULT_STATUS_OFFSET,
    CONTEXT_FRAME_DEPTH_OFFSET, CONTEXT_FRAME_LIMIT_OFFSET, CONTEXT_FREE_SIZE_MASK_OFFSET,
    CONTEXT_HEAP_LIMIT_OFFSET, CONTEXT_HEAP_ORDINAL_OFFSET, CONTEXT_HEAP_USED_OFFSET,
    CONTEXT_HEAP_WORDS_OFFSET, CONTEXT_INSTRUCTION_REMAINING_OFFSET,
    CONTEXT_PENDING_CAPACITY_OFFSET, CONTEXT_PENDING_LENGTH_OFFSET, CONTEXT_PENDING_POINTER_OFFSET,
    CONTEXT_QUANTUM_MASS_OFFSET, CONTEXT_RESULT_WORD_OFFSET, CONTEXT_ROOM_CELLS_OFFSET,
    CONTEXT_ROOM_THRESHOLD_OFFSET, CONTEXT_ROOT_CAPACITY_OFFSET, CONTEXT_ROOT_TOP_OFFSET,
    CONTEXT_ROOTS_OFFSET, CONTEXT_UNWIND_DEPTH_OFFSET, NO_CALLER_SITE, STATUS_CONTINUE,
    STATUS_FAILED, STATUS_LIMIT, STATUS_UNWIND,
};
pub use effect_channel::{AotHostProvider, EffectChannel};
pub use effect_document::{EffectInput, EffectOutput};
pub use effects::{effect_operation_cells, effect_operation_index, rt_aot_effect_call};
pub use engine::AotEngine;
pub use entry::{pseudolearn_aot_exit, pseudolearn_aot_main};
pub use fault::{FaultRecord, FaultSite, SourceRange, render_fault};
pub use guard::entry_result;
pub use inline_allocation::{
    INLINE_MAXIMUM_PHYSICAL, INLINE_PHYSICAL_SHIFT, INLINE_RECORD_WORDS, InlineObjectImage,
    class_payload_offset, inline_object_image,
};
pub use input::rt_aot_read;
pub use kinds::{
    CHARACTER_OPERAND_FLAG, KIND_BOOLEAN, KIND_CHARACTER, KIND_INTEGER, KIND_REAL, KIND_REFERENCE,
    NEWLINE_FLAG, PROFILE_SHIFT, RANK_SHIFT, STATEMENT_END_FLAG,
};
pub use math::{
    MATH_ARC_COSINE, MATH_ARC_SINE, MATH_ARC_TANGENT2, MATH_ARCTANGENT, MATH_CEILING, MATH_COSINE,
    MATH_EXPONENTIAL, MATH_FLOOR, MATH_LOGARITHM, MATH_LOGARITHM2, MATH_LOGARITHM10,
    MATH_REAL_MAXIMUM, MATH_REAL_MINIMUM, MATH_ROUND, MATH_SINE, MATH_TANGENT, MATH_TRUNCATE,
    rt_aot_integer_power, rt_aot_math_binary, rt_aot_math_unary, rt_aot_real_power,
};
pub use memory::{rt_aot_array_new, rt_aot_object_copy, rt_aot_object_new};
pub use metadata::{ExecutableMetadata, ExecutableSettings};
pub use metadata_codec::{decode_metadata, encode_metadata};
pub use output::rt_aot_write;
pub use process::{
    EXIT_COMPLETED, EXIT_FAILED, EXIT_INTERNAL, EXIT_LIMIT, EXIT_REPLAY, EntryFunction,
    ProcessLaunch, ProcessStreams, run_executable, run_executable_with_effects,
    run_executable_with_tasks,
};
pub use process_options::{ProcessOptions, ProcessOptionsError};
pub use pseudolearn_diagnostics::DiagnosticCode;
pub use random::{rt_aot_random_below, rt_aot_random_between, rt_aot_random_real};
pub use session::{AotSession, settle_session};
pub use snapshot::rt_aot_snapshot_copy;
pub use text::{
    TEXT_LENGTH, TEXT_TO_INTEGER, TEXT_TO_REAL, rt_aot_text_character, rt_aot_text_compare,
    rt_aot_text_concat, rt_aot_text_format, rt_aot_text_literal, rt_aot_text_query,
};
pub use trap::rt_aot_fault;

#[cfg(feature = "telemetry")]
mod statistics;
#[cfg(feature = "telemetry")]
pub use statistics::AotStatistics;
