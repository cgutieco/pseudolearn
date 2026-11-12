#![forbid(unsafe_code)]

use crate::header::COMMON_HEADER_WORDS;

pub const STRING_HEADER_WORDS: usize = COMMON_HEADER_WORDS;
pub const STRING_ARENA_BYTE_OFFSET_WORD_OFFSET: usize = 2;
pub const STRING_ARENA_BYTE_COUNT_WORD_OFFSET: usize = 3;
pub const STRING_BREADCRUMBS_HANDLE_WORD_OFFSET: usize = 4;
pub const STRING_FIXED_WORDS_COUNT: usize = 5;
