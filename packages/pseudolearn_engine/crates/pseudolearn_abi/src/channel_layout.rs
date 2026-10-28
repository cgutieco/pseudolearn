pub const CHANNEL_SHAPE_TAG: u32 = u32::MAX - 6;
pub const CHANNEL_CAPACITY_OFFSET: usize = 2;
pub const CHANNEL_WIDTH_OFFSET: usize = 3;
pub const CHANNEL_HEADER_WORDS: usize = 4;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ChannelLayout {
    pub capacity: u32,
    pub element_words: u32,
}

impl ChannelLayout {
    pub fn new(capacity: u32, element_words: u32) -> Option<Self> {
        if capacity == 0 {
            return None;
        }
        let layout = Self {
            capacity,
            element_words: element_words.max(1),
        };
        layout.cells()?;
        Some(layout)
    }

    pub fn cells(self) -> Option<u64> {
        u64::from(self.capacity)
            .checked_mul(u64::from(self.element_words))?
            .checked_add(1)
    }
}
