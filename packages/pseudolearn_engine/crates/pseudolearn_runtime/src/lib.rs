#![forbid(unsafe_code)]

pub use pseudolearn_abi::Handle;

mod arithmetic;
mod array;
mod cell;
mod delta;
mod error;
mod heap;
mod object;
mod random;
mod snapshot;
mod text;
mod value;

pub use array::{
    array_dimensions, new_array, read_element, read_element_1d, write_element, write_element_1d,
};
pub use cell::{MemoryCell, element_cell, field_cell, read_memory_cell, write_memory_cell};
pub use delta::{
    BLOCK_WORDS, BlockDelta, DeltaError, HeapDelta, MapDelta, Sequence, TailDelta, advance_heap,
    compose_heap_deltas, revert_heap,
};
pub use heap::{Heap, ObjectLayout};
pub use object::{
    copy_object, new_object, new_object_shared, object_allocation_cells, object_class,
    object_layout_cells, read_field, write_field,
};
pub use random::RandomState;
pub use snapshot::{
    allocation_ordinal, arena_length, array_element_kind, heap_allocated_cells, heap_live_cells,
    heap_ordinal, heap_used_words, heap_words, is_array_allocation, is_defined_element,
    is_defined_field, is_object_allocation, live_allocation_handles, object_class_identifier,
    object_field_kinds, read_element_raw, read_field_raw, restore_heap_block,
    set_heap_allocated_cells, set_heap_live_cells, set_heap_ordinal, set_heap_used_words,
    truncate_arena,
};
pub use text::{
    TextCompaction, TextPart, compare_text, concat_parts, concat_text, new_text, text_character,
    text_content, text_length,
};
pub use value::{CollectionPolicy, MemoryError, MemoryOptions, ValueKind};

pub use arithmetic::{
    int_add, int_divide, int_modulo, int_multiply, int_negate, int_power, int_subtract, real_add,
    real_divide, real_multiply, real_subtract,
};
pub use error::ArithmeticError;

#[cfg(feature = "telemetry")]
mod statistics;
#[cfg(feature = "telemetry")]
pub use statistics::HeapStatistics;
