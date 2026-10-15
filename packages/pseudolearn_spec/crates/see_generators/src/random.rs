pub(crate) struct Random {
    state: u64,
}

impl Random {
    pub(crate) fn new(seed: u64, sample: u32) -> Self {
        Self {
            state: seed.wrapping_add(u64::from(sample).wrapping_mul(0x9e3779b97f4a7c15)),
        }
    }

    pub(crate) fn next(&mut self, bound: u64) -> u64 {
        self.state = self.state.wrapping_add(0x9e3779b97f4a7c15);
        let mixed =
            (self.state ^ self.state.checked_shr(30).unwrap_or(0)).wrapping_mul(0xbf58476d1ce4e5b9);
        let mixed = (mixed ^ mixed.checked_shr(27).unwrap_or(0)).wrapping_mul(0x94d049bb133111eb);
        (mixed ^ mixed.checked_shr(31).unwrap_or(0))
            .checked_rem(bound)
            .unwrap_or(0)
    }
}
