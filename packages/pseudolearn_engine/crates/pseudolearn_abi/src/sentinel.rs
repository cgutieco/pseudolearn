#![forbid(unsafe_code)]

use crate::handle::Handle;
use crate::word::Word;

pub const REAL_ABSENT_BITS: u64 = 0x7FF8_0000_0000_0001;
pub const BOOLEAN_ABSENT_BITS: u64 = 2;
pub const CHARACTER_ABSENT_BITS: u64 = 0xFFFF_FFFF;

pub const fn real_absent_word() -> Word {
    Word::from_u64(REAL_ABSENT_BITS)
}

pub const fn boolean_absent_word() -> Word {
    Word::from_u64(BOOLEAN_ABSENT_BITS)
}

pub const fn character_absent_word() -> Word {
    Word::from_u64(CHARACTER_ABSENT_BITS)
}

pub const fn reference_absent_handle() -> Handle {
    Handle::RESERVED_ABSENT
}

pub fn is_real_absent(word: Word) -> bool {
    word.as_f64_bits().is_nan()
}

pub const fn is_boolean_absent(word: Word) -> bool {
    word.as_u64() == BOOLEAN_ABSENT_BITS
}

pub const fn is_character_absent(word: Word) -> bool {
    word.as_u64() == CHARACTER_ABSENT_BITS
}

pub const fn is_reference_absent(handle: Handle) -> bool {
    handle.is_absent()
}
