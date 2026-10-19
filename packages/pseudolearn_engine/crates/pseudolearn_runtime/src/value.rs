use pseudolearn_abi::{BOOLEAN_ABSENT_BITS, CHARACTER_ABSENT_BITS, REAL_ABSENT_BITS};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ValueKind {
    Integer,
    Real,
    Boolean,
    Character,
    Reference,
}

impl ValueKind {
    pub const fn absent(self) -> u64 {
        match self {
            Self::Integer | Self::Reference => 0,
            Self::Real => REAL_ABSENT_BITS,
            Self::Boolean => BOOLEAN_ABSENT_BITS,
            Self::Character => CHARACTER_ABSENT_BITS,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MemoryError {
    Resource,
    Internal,
    CellLimit,
    NegativeSize,
    IndexOutOfRange,
    Uninitialized,
    StringPositionOutOfRange,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum CollectionPolicy {
    #[default]
    Automatic,
    Forced,
    Disabled,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct MemoryOptions {
    pub cells: u64,
    pub collection: CollectionPolicy,
    pub collection_minimum: u64,
}

impl Default for MemoryOptions {
    fn default() -> Self {
        Self {
            cells: 1 << 22,
            collection_minimum: 4096,
            collection: CollectionPolicy::Automatic,
        }
    }
}
