#![forbid(unsafe_code)]

pub use pseudolearn_abi::{
    CapabilityKind, CollectionCommand, DictionaryKeyKind, DictionaryLayout, Handle, VectorLayout,
};

pub mod effect_tape;
pub mod tape_privacy;
pub mod tape_replay;
mod tape_codec;
mod effect_session;
pub use effect_session::{EffectRecord, EffectSession, console_record};
mod arithmetic;
mod array;
mod bytes_buffer;
mod cell;
mod capability_table;
mod collection;
mod dictionary;
mod io_error;
mod vector;
pub use bytes_buffer::BytesBuffer;
pub use io_error::IoError;
pub use collection::{
    CollectionWords, collection_check_version, collection_layout, collection_length,
    collection_version, new_dictionary, new_vector,
};
pub use collection::{collection_is_dictionary, collection_key, collection_load_word};
pub use dictionary::{
    dictionary_entry, dictionary_find, dictionary_get, dictionary_lookup, dictionary_next,
    dictionary_remove, dictionary_set,
};
pub use vector::{vector_get, vector_insert, vector_remove, vector_set};
mod delta;
mod error;
mod heap;
mod object;
mod random;
mod snapshot;
mod text;
mod value;

pub use capability_table::{
    CapabilityEntry, CapabilityError, CapabilityTable, CapabilityToken, CommitOutcome,
    EffectPhase, ReproducibilityStatus, RightsMask,
};

pub use array::{
    array_dimensions, new_array, read_element, read_element_1d, write_element, write_element_1d,
};
pub use cell::{MemoryCell, element_cell, field_cell, read_memory_cell, write_memory_cell};
pub use delta::{
    BLOCK_WORDS, BlockDelta, DeltaError, HeapDelta, MapDelta, Sequence, TailDelta, advance_heap,
    compose_heap_deltas, revert_heap,
};
pub use heap::{Heap, InlineBlock, InlineWindow, ObjectLayout};
pub use object::{
    copy_object, new_object, new_object_shared, object_allocation_cells, object_class,
    object_layout_cells, read_field, write_field,
};
pub use random::RandomState;
pub use snapshot::{
    allocation_ordinal, arena_length, array_element_kind, heap_allocated_cells, heap_live_cells,
    heap_ordinal, heap_used_words, heap_words, is_array_allocation, is_collection_allocation,
    is_defined_element, is_defined_field, is_object_allocation, live_allocation_handles,
    object_class_identifier, object_field_kinds, read_element_raw, read_field_raw,
    restore_heap_block, set_heap_allocated_cells, set_heap_live_cells, set_heap_ordinal,
    set_heap_used_words, truncate_arena,
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

#[cfg(test)]
mod collection_tests;

pub use effect_tape::{EffectTape, ExecutionIdentity, TapeEntry, TAPE_SCHEMA_V1};
pub use tape_replay::{ExecutionMode, ReplayError, TapeReplayProvider};
pub use tape_codec::{decode_effect_tape, encode_effect_tape, tape_entry_hash};

pub use tape_privacy::{DEFAULT_MAX_TAPE_BYTES, SecretHandle, TapeBudget};

mod managed_bytes;
mod managed_capability;
pub use managed_bytes::{new_bytes, bytes_length, bytes_at, bytes_content};
pub use managed_capability::{new_capability, capability_token};

mod host_effect;
mod host_session;
mod host_validation;
mod effect_authority;
pub use host_effect::{HostValue, HostCapability, HostFailure, HostReply, HostEffectRequest, HostEffectProvider};
pub use host_session::{configure_host_authority, begin_host_effect, resolve_host_effect, perform_host_effect};
pub use effect_authority::effective_permissions;

mod memory_host;
mod memory_host_files;
mod memory_host_config;
pub use memory_host::MemoryHostProvider;

mod host_words;
mod local_effect;
pub use host_words::{decode_host_value, host_reply_words};
pub use local_effect::local_effect;
pub use pseudolearn_abi::{EffectOperation, EffectValueKind, EFFECT_OPERATIONS, effect_operation};

mod effect_checkpoint;
pub use effect_checkpoint::{EffectCheckpoint, capture_effect_checkpoint, replay_effect_checkpoint};

mod secret_policy;

mod tape_accounting;
