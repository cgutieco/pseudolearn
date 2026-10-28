pub const CONTINUATION_SHAPE_TAG: u32 = u32::MAX - 10;
pub const CONTINUATION_FUNCTION_OFFSET: usize = 2;
pub const CONTINUATION_STATE_OFFSET: usize = 3;
pub const CONTINUATION_PARENT_OFFSET: usize = 4;
pub const CONTINUATION_RESULT_OFFSET: usize = 5;
pub const CONTINUATION_SCALARS_OFFSET: usize = 6;
pub const CONTINUATION_REFERENCES_OFFSET: usize = 7;
pub const CONTINUATION_HEADER_WORDS: usize = 8;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ContinuationLayout {
    scalar_slots: u32,
    reference_slots: u32,
}

impl ContinuationLayout {
    pub fn new(scalar_slots: u32, reference_slots: u32) -> Option<Self> {
        let total = scalar_slots.checked_add(reference_slots)?;
        (total <= u32::from(u16::MAX)).then_some(Self {
            scalar_slots,
            reference_slots,
        })
    }

    pub fn scalar_slots(self) -> u32 {
        self.scalar_slots
    }

    pub fn reference_slots(self) -> u32 {
        self.reference_slots
    }

    pub fn scalar_offset(self, slot: u32) -> Option<usize> {
        if slot >= self.scalar_slots {
            return None;
        }
        CONTINUATION_HEADER_WORDS.checked_add(usize::try_from(slot).ok()?)
    }

    pub fn reference_offset(self, slot: u32) -> Option<usize> {
        if slot >= self.reference_slots {
            return None;
        }
        CONTINUATION_HEADER_WORDS
            .checked_add(usize::try_from(self.scalar_slots).ok()?)?
            .checked_add(usize::try_from(slot).ok()?)
    }

    pub fn logical_cells(self) -> u64 {
        1_u64
            .saturating_add(u64::from(self.scalar_slots))
            .saturating_add(u64::from(self.reference_slots))
    }

    pub fn physical_words(self) -> Option<usize> {
        CONTINUATION_HEADER_WORDS
            .checked_add(usize::try_from(self.scalar_slots).ok()?)?
            .checked_add(usize::try_from(self.reference_slots).ok()?)
    }
}
