mod config;
mod context;
mod engine;
mod fault;
mod format;
mod guard;
mod input;
mod kinds;
mod math;
mod memory;
mod output;
mod random;
mod session;
mod text;
mod trap;

pub use config::{AotConfig, AotLimits, AotStreams, BooleanWords};
pub use context::{
    AotRuntimeContext, CONTEXT_FAULT_SITE_OFFSET, CONTEXT_FAULT_STATUS_OFFSET,
    CONTEXT_FRAME_DEPTH_OFFSET, CONTEXT_FRAME_LIMIT_OFFSET, CONTEXT_HEAP_WORDS_OFFSET,
    CONTEXT_INSTRUCTION_REMAINING_OFFSET, CONTEXT_RESULT_WORD_OFFSET, CONTEXT_ROOT_TOP_OFFSET,
    CONTEXT_ROOTS_OFFSET, STATUS_CONTINUE, STATUS_FAILED, STATUS_LIMIT,
};
pub use engine::AotEngine;
pub use fault::{FaultRecord, FaultSite, SourceRange, render_fault};
pub use input::rt_aot_read;
pub use kinds::{
    CHARACTER_OPERAND_FLAG, KIND_BOOLEAN, KIND_CHARACTER, KIND_INTEGER, KIND_REAL, KIND_REFERENCE,
    NEWLINE_FLAG, RANK_SHIFT,
};
pub use math::{
    MATH_ARCTANGENT, MATH_COSINE, MATH_EXPONENTIAL, MATH_LOGARITHM, MATH_ROUND, MATH_SINE,
    MATH_TRUNCATE, rt_aot_math_unary, rt_aot_real_power,
};
pub use memory::{rt_aot_array_new, rt_aot_object_copy, rt_aot_object_new};
pub use output::rt_aot_write;
pub use random::rt_aot_random_real;
pub use session::AotSession;
pub use text::{
    TEXT_LENGTH, TEXT_TO_INTEGER, TEXT_TO_REAL, rt_aot_text_character, rt_aot_text_compare,
    rt_aot_text_concat, rt_aot_text_format, rt_aot_text_literal, rt_aot_text_query,
};
pub use trap::rt_aot_fault;
