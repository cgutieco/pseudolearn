#![forbid(unsafe_code)]

pub mod array_layout;
pub mod frame;
pub mod handle;
pub mod header;
pub mod object_layout;
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
    COMMON_HEADER_BYTES, COMMON_HEADER_WORDS, CommonHeader, IDENTITY_ORDINAL_WORD_OFFSET,
    SHAPE_FLAGS_WORD_OFFSET,
};
pub use object_layout::{
    ClassReferenceOffsets, OBJECT_FIELDS_START_OFFSET_WITH_MASK,
    OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK, OBJECT_HEADER_WORDS, OBJECT_INTEGER_MASK_WORD_OFFSET,
    object_fields_start_offset,
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
