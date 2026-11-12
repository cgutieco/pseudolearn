pub const DICTIONARY_SHAPE_TAG: u32 = u32::MAX - 2;
pub const DICTIONARY_USED_OFFSET: usize = 10;
pub const DICTIONARY_KEY_KIND_OFFSET: usize = 11;
pub const DICTIONARY_KEYS_OFFSET: usize = 12;
pub const DICTIONARY_HASHES_OFFSET: usize = 13;
pub const DICTIONARY_INDEX_OFFSET: usize = 14;
pub const DICTIONARY_INDEX_CAPACITY_OFFSET: usize = 15;
pub const DICTIONARY_OCCUPIED_OFFSET: usize = 16;
pub const DICTIONARY_HEADER_WORDS: usize = 17;
pub const DICTIONARY_EMPTY_INDEX: u32 = u32::MAX;
pub const DICTIONARY_DELETED_INDEX: u32 = u32::MAX - 1;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u32)]
pub enum DictionaryKeyKind {
    Integer,
    Character,
    Boolean,
    Enumeration,
    String,
}

impl DictionaryKeyKind {
    pub fn code(self) -> u32 {
        match self {
            Self::Integer => 0,
            Self::Character => 1,
            Self::Boolean => 2,
            Self::Enumeration => 3,
            Self::String => 4,
        }
    }

    pub fn from_code(code: u32) -> Option<Self> {
        match code {
            0 => Some(Self::Integer),
            1 => Some(Self::Character),
            2 => Some(Self::Boolean),
            3 => Some(Self::Enumeration),
            4 => Some(Self::String),
            _ => None,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct DictionaryLayout {
    pub value: crate::vector_layout::VectorLayout,
    pub key: DictionaryKeyKind,
}

impl DictionaryLayout {
    pub fn storage_words(self, capacity: u32, index_capacity: u32) -> Option<u64> {
        self.value
            .storage_words(capacity)?
            .checked_add(u64::from(capacity).checked_mul(3)?)?
            .checked_add(u64::from(index_capacity))
    }

    pub fn logical_cells(self, length: u32) -> Option<u64> {
        let width = u64::from(self.value.element_words()?.max(1)).checked_add(1)?;
        width.checked_mul(u64::from(length))?.checked_add(1)
    }
}
