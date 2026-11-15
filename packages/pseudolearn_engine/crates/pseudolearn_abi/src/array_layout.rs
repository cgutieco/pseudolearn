#![forbid(unsafe_code)]

use crate::header::COMMON_HEADER_WORDS;

pub const ARRAY_HEADER_WORDS: usize = COMMON_HEADER_WORDS;
pub const ARRAY_TOTAL_ELEMENTS_WORD_OFFSET: usize = 2;
pub const ARRAY_DENSE_BOUNDARY_WORD_OFFSET: usize = 3;
pub const ARRAY_DEFINITION_MAP_WORD_OFFSET: usize = 4;
pub const ARRAY_DIMENSION_EXTENTS_START_OFFSET: usize = 5;

pub fn array_elements_start_offset(dimension_rank: u32) -> usize {
    if dimension_rank <= 1 {
        ARRAY_DIMENSION_EXTENTS_START_OFFSET
    } else {
        let additional = usize::try_from(dimension_rank).unwrap_or(0);
        ARRAY_DIMENSION_EXTENTS_START_OFFSET.saturating_add(additional)
    }
}
