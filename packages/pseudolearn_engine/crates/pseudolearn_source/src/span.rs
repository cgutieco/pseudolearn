#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct Span {
    pub start: u32,
    pub ending: u32,
}

impl Span {
    pub const fn empty() -> Self {
        Self {
            start: 0,
            ending: 0,
        }
    }

    pub const fn new(start: u32, ending: u32) -> Self {
        Self { start, ending }
    }

    pub fn length(&self) -> u32 {
        self.ending.saturating_sub(self.start)
    }

    pub fn is_empty(&self) -> bool {
        self.start >= self.ending
    }

    pub fn cover(&self, other: Self) -> Self {
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
        Self {
            start: minimal_start,
            ending: maximal_ending,
        }
    }
}
