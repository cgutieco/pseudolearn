#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RandomState {
    pub words: [u64; 4],
}

impl RandomState {
    pub fn seeded(seed: i64) -> Self {
        let mut state = u64::from_ne_bytes(seed.to_ne_bytes());
        let mut words = [0; 4];
        for word in &mut words {
            state = state.wrapping_add(0x9e3779b97f4a7c15);
            let mixed = (state ^ state.wrapping_shr(30)).wrapping_mul(0xbf58476d1ce4e5b9);
            let mixed = (mixed ^ mixed.wrapping_shr(27)).wrapping_mul(0x94d049bb133111eb);
            *word = mixed ^ mixed.wrapping_shr(31);
        }
        Self { words }
    }

    pub fn next_word(&mut self) -> u64 {
        let [first, second, third, fourth] = self.words;
        let result = second.wrapping_mul(5).rotate_left(7).wrapping_mul(9);
        let shift = second.wrapping_shl(17);
        let third = third ^ first;
        let fourth = fourth ^ second;
        let second = second ^ third;
        let first = first ^ fourth;
        self.words = [first, second, third ^ shift, fourth.rotate_left(45)];
        result
    }

    pub fn next_below(&mut self, bound: u64) -> Option<u64> {
        let remainder = u64::MAX
            .checked_rem(bound)?
            .wrapping_add(1)
            .checked_rem(bound)?;
        let accepted = 0_u64.wrapping_sub(remainder);
        loop {
            let word = self.next_word();
            if remainder == 0 || word < accepted {
                return word.checked_rem(bound);
            }
        }
    }

    pub fn next_between(&mut self, low: i64, high: i64) -> Option<i64> {
        if low > high {
            return None;
        }
        let width = high.abs_diff(low);
        let offset = match width.checked_add(1) {
            Some(span) => self.next_below(span)?,
            None => self.next_word(),
        };
        Some(low.wrapping_add_unsigned(offset))
    }

    pub fn next_real(&mut self) -> f64 {
        let integer = self.next_word().wrapping_shr(11);
        let high = u32::try_from(integer.wrapping_shr(32)).unwrap_or(0);
        let low = u32::try_from(integer & 0xffff_ffff).unwrap_or(0);
        (f64::from(high) * 4294967296.0 + f64::from(low)) / 9007199254740992.0
    }
}
