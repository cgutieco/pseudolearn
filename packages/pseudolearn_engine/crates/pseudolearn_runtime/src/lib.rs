#![forbid(unsafe_code)]

pub use pseudolearn_abi::{
    CapabilityKind, CollectionCommand, DictionaryKeyKind, DictionaryLayout, Handle, VectorLayout,
};

mod effect_reservation;
mod effect_session;
pub mod effect_tape;
mod tape_abandoned;
mod tape_codec;
mod tape_delivery;
pub mod tape_privacy;
pub mod tape_replay;
pub use effect_session::{EffectRecord, EffectSession, console_record};
mod arithmetic;
mod array;
mod bytes_buffer;
mod capability_table;
mod cell;
mod collection;
mod dictionary;
mod io_error;
mod vector;
pub use bytes_buffer::BytesBuffer;
pub use collection::{
    CollectionWords, collection_check_version, collection_layout, collection_length,
    collection_version, new_dictionary, new_vector,
};
pub use collection::{collection_is_dictionary, collection_key, collection_load_word};
pub use dictionary::{
    dictionary_entry, dictionary_find, dictionary_get, dictionary_lookup, dictionary_next,
    dictionary_remove, dictionary_set, dictionary_window,
};
pub use io_error::IoError;
pub use vector::{vector_get, vector_insert, vector_remove, vector_set};
mod delta;
mod error;
mod heap;
mod inspection_heap;
pub use inspection_heap::clone_heap_bounded;
mod object;
mod random;
mod snapshot;
mod text;
mod value;

pub use capability_table::{
    CapabilityEntry, CapabilityError, CapabilityTable, CapabilityToken, CommitOutcome, EffectPhase,
    ReproducibilityStatus, RightsMask,
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
    allocation_handle, allocation_ordinal, arena_length, array_element_kind, heap_allocated_cells,
    heap_live_cells, heap_ordinal, heap_used_words, heap_words, is_array_allocation,
    is_collection_allocation, is_defined_element, is_defined_field, is_object_allocation,
    live_allocation_handles, object_class_identifier, object_field_kind, object_field_kinds,
    read_element_raw, read_field_raw, restore_heap_block, set_heap_allocated_cells,
    set_heap_live_cells, set_heap_ordinal, set_heap_used_words, truncate_arena,
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
#[cfg(test)]
mod effect_tape_tests;

pub use effect_tape::{EffectTape, ExecutionIdentity, TAPE_SCHEMA_V1, TapeEntry};
pub use tape_abandoned::AbandonedEffect;
pub use tape_codec::{decode_effect_tape, encode_effect_tape, tape_entry_hash};
pub use tape_delivery::{delivery_order, operation_may_write};
pub use tape_replay::{ExecutionMode, ReplayError, TapeReplayProvider};

pub use tape_privacy::{DEFAULT_MAX_TAPE_BYTES, SecretHandle, TapeBudget};

mod managed_bytes;
mod managed_capability;
pub use managed_bytes::{bytes_at, bytes_content, bytes_length, new_bytes};
pub mod json_document;
pub use managed_capability::{capability_token, new_capability};

mod effect_authority;
mod host_effect;
mod host_session;
mod host_validation;
mod http_values;
#[cfg(test)]
mod http_values_tests;
pub use effect_authority::effective_permissions;
pub use host_effect::{
    HostCapability, HostEffectProvider, HostEffectRequest, HostFailure, HostReply, HostValue,
    HttpMethod, HttpRequestValue, HttpResponseValue, JsonFailure, JsonResultValue,
};
pub use host_session::{
    begin_host_effect, configure_host_authority, configure_network_limits, perform_host_effect,
    resolve_host_effect,
};
pub use network_limits::{
    DEFAULT_HTTP_BODY_BYTES, DEFAULT_HTTP_HEADER_BYTES, DEFAULT_HTTP_HEADERS,
    DEFAULT_HTTP_TIMEOUT_NANOS, DEFAULT_HTTP_WIRE_BYTES, DEFAULT_JSON_DEPTH,
    DEFAULT_PENDING_NETWORK, NetworkLimits, pending_limit_exceeded,
};

mod memory_host;
mod memory_host_config;
mod memory_host_files;
mod network_headers;
mod network_limits;
#[cfg(test)]
mod network_limits_tests;
mod network_policy;
#[cfg(test)]
mod network_policy_tests;
mod network_redirect;
#[cfg(test)]
mod network_redirect_tests;
pub use network_redirect::redirect_request;
mod network_url;
pub use memory_host::MemoryHostProvider;

mod host_words;
mod local_effect;
mod local_http_effect;
pub use host_words::{decode_host_value, host_reply_words};
pub use local_effect::local_effect;
pub use pseudolearn_abi::json_layout::JsonNodeKind;
pub use pseudolearn_abi::{EFFECT_OPERATIONS, EffectOperation, EffectValueKind, effect_operation};

mod effect_checkpoint;
pub use effect_checkpoint::{
    EffectCheckpoint, capture_effect_checkpoint, replay_effect_checkpoint,
};

mod task_agenda;
mod task_state;
pub use task_agenda::{
    DEFAULT_TASK_LIMIT, TaskAgenda, TaskAgendaError, TaskCancellation, TaskChannelId,
    TaskExecution, TaskId, TaskLimit, TaskScopeId, TaskScopeJoin, TaskSummary, TaskWaiting,
    TaskWake,
};
pub use task_state::TaskState;

#[cfg(test)]
mod task_agenda_tests;

mod secret_policy;

mod tape_accounting;

mod task_channel;
mod task_failure;
mod wait_queue;
pub use task_channel::{
    ChannelError, ChannelReply, ChannelStep, TaskChannels, buffered_slot, channel_values,
    pending_values, take_buffer_change,
};
pub use task_failure::{TaskFailure, TaskFailures};
#[cfg(test)]
mod task_channel_tests;
#[cfg(test)]
mod task_failure_tests;
#[cfg(test)]
mod wait_queue_tests;

pub use task_agenda::{TaskBlock, TaskProgress, TaskWaitReason, task_progress};
#[cfg(test)]
mod task_deadlock_tests;

pub use task_agenda::{interrupt_owner, scope_children, scope_owner, task_scope, task_wait};

mod channel_storage;
pub use channel_storage::new_channel_storage;
pub use pseudolearn_abi::ChannelLayout;

mod task_quantum;
pub use task_quantum::{TASK_QUANTUM, TaskQuantum};
#[cfg(test)]
mod task_quantum_tests;

mod snapshot_copy;
mod snapshot_graph;
pub use snapshot_copy::{snapshot_copy, snapshot_copy_many};
#[cfg(test)]
mod snapshot_copy_tests;

pub mod continuation;

pub mod channel_references;

pub mod task_storage;
