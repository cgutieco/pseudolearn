#![forbid(unsafe_code)]

use crate::word::Word;

pub const CONTROL_FRAME_WORDS: usize = 2;
pub const CONTROL_FRAME_BYTES: usize = 16;

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct ControlFrame {
    pub function_index: u32,
    pub return_point_ip: u32,
    pub scalar_bank_base: u32,
    pub reference_bank_base: u32,
}

impl ControlFrame {
    pub const fn new(
        function_index: u32,
        return_point_ip: u32,
        scalar_bank_base: u32,
        reference_bank_base: u32,
    ) -> Self {
        Self {
            function_index,
            return_point_ip,
            scalar_bank_base,
            reference_bank_base,
        }
    }

    pub fn to_words(&self) -> [Word; 2] {
        let first_lower = u64::from(self.function_index);
        let first_upper = u64::from(self.return_point_ip).wrapping_shl(32);
        let second_lower = u64::from(self.scalar_bank_base);
        let second_upper = u64::from(self.reference_bank_base).wrapping_shl(32);
        [
            Word::from_u64(first_lower | first_upper),
            Word::from_u64(second_lower | second_upper),
        ]
    }

    pub fn from_words(words: [Word; 2]) -> Option<Self> {
        let first_word = words.first()?.as_u64();
        let second_word = words.get(1)?.as_u64();
        let function_index = u32::try_from(first_word & 0xFFFF_FFFF).unwrap_or(0);
        let return_point_ip = u32::try_from(first_word.wrapping_shr(32)).unwrap_or(0);
        let scalar_bank_base = u32::try_from(second_word & 0xFFFF_FFFF).unwrap_or(0);
        let reference_bank_base = u32::try_from(second_word.wrapping_shr(32)).unwrap_or(0);
        Some(Self {
            function_index,
            return_point_ip,
            scalar_bank_base,
            reference_bank_base,
        })
    }
}
