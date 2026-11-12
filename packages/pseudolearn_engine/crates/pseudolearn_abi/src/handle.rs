#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct Handle(pub u32);

impl Handle {
    pub const RESERVED_ABSENT: Self = Self(0);

    pub const fn from_u32(word_address: u32) -> Self {
        Self(word_address)
    }

    pub const fn as_u32(&self) -> u32 {
        self.0
    }

    pub const fn is_absent(&self) -> bool {
        self.0 == 0
    }

    pub const fn is_present(&self) -> bool {
        self.0 != 0
    }
}
