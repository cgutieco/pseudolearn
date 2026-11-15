#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct Span {
    pub source_id: SourceId,
    pub start: u32,
    pub ending: u32,
}

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct SourceId(u32);

impl SourceId {
    pub const STANDALONE: Self = Self(0);

    pub const fn new(value: u32) -> Self {
        Self(value)
    }

    pub const fn value(self) -> u32 {
        self.0
    }
}

impl Span {
    pub const fn empty() -> Self {
        Self {
            source_id: SourceId::STANDALONE,
            start: 0,
            ending: 0,
        }
    }

    pub const fn new(start: u32, ending: u32) -> Self {
        Self {
            source_id: SourceId::STANDALONE,
            start,
            ending,
        }
    }

    pub const fn in_source(source_id: SourceId, start: u32, ending: u32) -> Self {
        Self {
            source_id,
            start,
            ending,
        }
    }

    pub fn length(&self) -> u32 {
        self.ending.saturating_sub(self.start)
    }

    pub fn is_empty(&self) -> bool {
        self.start >= self.ending
    }

    pub fn cover(&self, other: Self) -> Option<Self> {
        if self.source_id != other.source_id {
            return None;
        }
        let minimal_start = if self.start < other.start {
            self.start
        } else {
            other.start
        };
        let maximal_ending = if self.ending > other.ending {
            self.ending
        } else {
            other.ending
        };
        Some(Self {
            source_id: self.source_id,
            start: minimal_start,
            ending: maximal_ending,
        })
    }
}
