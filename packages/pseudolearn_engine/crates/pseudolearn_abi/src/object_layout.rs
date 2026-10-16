#![forbid(unsafe_code)]

use crate::header::COMMON_HEADER_WORDS;

pub const OBJECT_HEADER_WORDS: usize = COMMON_HEADER_WORDS;
pub const OBJECT_INTEGER_MASK_WORD_OFFSET: usize = 2;
pub const OBJECT_FIELDS_START_OFFSET_WITH_MASK: usize = 3;
pub const OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK: usize = 2;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ClassReferenceOffsets {
    pub offsets: &'static [u32],
}

impl ClassReferenceOffsets {
    pub const fn new(offsets: &'static [u32]) -> Self {
        Self { offsets }
    }

    pub fn count(&self) -> usize {
        self.offsets.len()
    }
}

pub fn object_fields_start_offset(fields: usize, dense: bool) -> Option<usize> {
    if dense {
        Some(OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK)
    } else {
        fields
            .checked_add(63)?
            .checked_div(64)?
            .checked_add(OBJECT_HEADER_WORDS)
    }
}
