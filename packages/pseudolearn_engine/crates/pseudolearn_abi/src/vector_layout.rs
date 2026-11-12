pub const VECTOR_SHAPE_TAG: u32 = u32::MAX - 1;
pub const COLLECTION_LENGTH_OFFSET: usize = 2;
pub const COLLECTION_CAPACITY_OFFSET: usize = 3;
pub const COLLECTION_VERSION_OFFSET: usize = 4;
pub const COLLECTION_SCALAR_WIDTH_OFFSET: usize = 5;
pub const COLLECTION_REFERENCE_WIDTH_OFFSET: usize = 6;
pub const COLLECTION_SCALARS_OFFSET: usize = 7;
pub const COLLECTION_REFERENCES_OFFSET: usize = 8;
pub const COLLECTION_TYPE_OFFSET: usize = 9;
pub const VECTOR_HEADER_WORDS: usize = 10;
pub const COLLECTION_BUFFER_OFFSET: usize = 2;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct VectorLayout {
    pub scalar_words: u32,
    pub reference_words: u32,
    pub type_identity: u32,
}

impl VectorLayout {
    pub fn element_words(self) -> Option<u32> {
        self.scalar_words.checked_add(self.reference_words)
    }

    pub fn storage_words(self, capacity: u32) -> Option<u64> {
        u64::from(self.element_words()?).checked_mul(u64::from(capacity))
    }

    pub fn logical_cells(self, length: u32) -> Option<u64> {
        u64::from(self.element_words()?.max(1))
            .checked_mul(u64::from(length))?
            .checked_add(1)
    }
}
