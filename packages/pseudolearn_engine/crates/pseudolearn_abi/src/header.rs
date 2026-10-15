#![forbid(unsafe_code)]

use crate::word::Word;

pub const COMMON_HEADER_WORDS: usize = 2;
pub const COMMON_HEADER_BYTES: usize = 16;
pub const SHAPE_FLAGS_WORD_OFFSET: usize = 0;
pub const IDENTITY_ORDINAL_WORD_OFFSET: usize = 1;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct CommonHeader {
    pub shape_tag: u32,
    pub status_flags: u32,
    pub identity_or_count: u64,
}

impl CommonHeader {
    pub const fn new(shape_tag: u32, status_flags: u32, identity_or_count: u64) -> Self {
        Self {
            shape_tag,
            status_flags,
            identity_or_count,
        }
    }

    pub fn to_words(&self) -> [Word; 2] {
        let lower_part = u64::from(self.shape_tag);
        let upper_part = u64::from(self.status_flags);
        let shifted = upper_part.wrapping_shl(32);
        let first_word = lower_part | shifted;
        [
            Word::from_u64(first_word),
            Word::from_u64(self.identity_or_count),
        ]
    }

    pub fn from_words(words: [Word; 2]) -> Option<Self> {
        let first_bits = words.first()?.as_u64();
        let second_bits = words.get(1)?.as_u64();
        let shape_tag = u32::try_from(first_bits & 0xFFFF_FFFF).unwrap_or(0);
        let status_flags = u32::try_from(first_bits.wrapping_shr(32)).unwrap_or(0);
        Some(Self {
            shape_tag,
            status_flags,
            identity_or_count: second_bits,
        })
    }
}
