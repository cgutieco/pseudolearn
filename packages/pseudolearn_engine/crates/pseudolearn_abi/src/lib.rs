#![forbid(unsafe_code)]

pub mod array_layout;
pub mod bytes_layout;
pub mod capability_layout;
mod collection_command;
pub mod dictionary_layout;
pub mod io_error_layout;
pub mod vector_layout;
pub use bytes_layout::{
    BYTES_DATA_OFFSET, BYTES_HEADER_WORDS, BYTES_LENGTH_OFFSET, BYTES_SHAPE_TAG, bytes_cell_count,
};
pub use capability_layout::{
    CAPABILITY_HEADER_WORDS, CAPABILITY_SHAPE_TAG, CapabilityKind,
};
pub use io_error_layout::IoErrorKind;
pub use collection_command::CollectionCommand;
pub use dictionary_layout::{DictionaryKeyKind, DictionaryLayout};
pub use vector_layout::VectorLayout;
pub mod frame;
pub mod handle;
pub mod header;
pub mod object_layout;
pub mod record_layout;
pub mod sentinel;
pub mod string_layout;
pub mod word;

pub use array_layout::{
    ARRAY_DEFINITION_MAP_WORD_OFFSET, ARRAY_DENSE_BOUNDARY_WORD_OFFSET,
    ARRAY_DIMENSION_EXTENTS_START_OFFSET, ARRAY_HEADER_WORDS, ARRAY_TOTAL_ELEMENTS_WORD_OFFSET,
    array_elements_start_offset,
};
pub use frame::{CONTROL_FRAME_BYTES, CONTROL_FRAME_WORDS, ControlFrame};
pub use handle::Handle;
pub use header::{
    ARRAY_KIND_STATUS_MASK, ARRAY_KIND_STATUS_SHIFT, ARRAY_RANK_STATUS_MASK,
    ARRAY_RANK_STATUS_SHIFT, COMMON_HEADER_BYTES, COMMON_HEADER_WORDS, CommonHeader,
    IDENTITY_ORDINAL_WORD_OFFSET, LITERAL_STATUS_MASK, OBJECT_PAYLOAD_STATUS_MASK,
    SHAPE_FLAGS_WORD_OFFSET, TEXT_ASCII_STATUS_MASK,
};
pub use object_layout::{
    ClassReferenceOffsets, OBJECT_FIELDS_START_OFFSET_WITH_MASK,
    OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK, OBJECT_HEADER_WORDS, OBJECT_INTEGER_MASK_WORD_OFFSET,
    object_fields_start_offset,
};
pub use record_layout::{
    RECORD_MAXIMUM_LEAVES, RecordBank, RecordLayout, RecordLayoutError, RecordLeaf,
};
pub use sentinel::{
    BOOLEAN_ABSENT_BITS, CHARACTER_ABSENT_BITS, REAL_ABSENT_BITS, boolean_absent_word,
    character_absent_word, is_boolean_absent, is_character_absent, is_real_absent,
    is_reference_absent, real_absent_word, reference_absent_handle,
};
pub use string_layout::{
    STRING_ARENA_BYTE_COUNT_WORD_OFFSET, STRING_ARENA_BYTE_OFFSET_WORD_OFFSET,
    STRING_BREADCRUMBS_HANDLE_WORD_OFFSET, STRING_FIXED_WORDS_COUNT, STRING_HEADER_WORDS,
};
pub use word::Word;

pub mod variant_layout;
pub use variant_layout::{VariantLayout, VariantLayoutError};

mod closure_layout;
pub use closure_layout::ClosureLayout;

mod effect_operation;
pub use effect_operation::{EffectValueKind, EffectOperation, EFFECT_OPERATIONS, find_effect_operation, effect_operation};
