#![forbid(unsafe_code)]

pub(crate) struct Sampler {
    state: u64,
}

impl Sampler {
    pub(crate) fn new(seed: u64) -> Self {
        Self { state: seed }
    }

    pub(crate) fn next_word(&mut self) -> u64 {
        self.state = self.state.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut mixed = self.state;
        mixed = (mixed ^ mixed.wrapping_shr(30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        mixed = (mixed ^ mixed.wrapping_shr(27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        mixed ^ mixed.wrapping_shr(31)
    }

    pub(crate) fn below(&mut self, bound: u64) -> u64 {
        self.next_word().checked_rem(bound).unwrap_or(0)
    }

    pub(crate) fn unit(&mut self) -> f64 {
        let fraction = self.next_word().wrapping_shr(12) | 0x3FF0_0000_0000_0000;
        f64::from_bits(fraction) - 1.0
    }

    pub(crate) fn uniform(&mut self, lower: f64, upper: f64) -> f64 {
        lower + (upper - lower) * self.unit()
    }

    pub(crate) fn finite_bits(&mut self) -> f64 {
        loop {
            let candidate = f64::from_bits(self.next_word());
            if candidate.is_finite() {
                return candidate;
            }
        }
    }

    pub(crate) fn logarithmic(&mut self, lowest: i64, highest: i64) -> f64 {
        let span = u64::try_from(highest.saturating_sub(lowest).saturating_add(1)).unwrap_or(1);
        let offset = i64::try_from(self.below(span)).unwrap_or(0);
        let exponent = lowest.saturating_add(offset).saturating_add(1023);
        let field = u64::try_from(exponent.clamp(1, 2046)).unwrap_or(1);
        let fraction = self.next_word() & 0x000F_FFFF_FFFF_FFFF;
        let sign = self.next_word() & 0x8000_0000_0000_0000;
        f64::from_bits(sign | field.wrapping_shl(52) | fraction)
    }

    pub(crate) fn near(&mut self, center: f64, reach: u64) -> f64 {
        let distance = self.below(reach.saturating_add(1));
        let bits = center.to_bits();
        let moved = if self.next_word() & 1 == 0 {
            bits.saturating_add(distance)
        } else {
            bits.saturating_sub(distance)
        };
        let candidate = f64::from_bits(moved);
        if candidate.is_finite() {
            candidate
        } else {
            center
        }
    }

    pub(crate) fn pick(&mut self, values: &[f64]) -> f64 {
        let index =
            usize::try_from(self.below(u64::try_from(values.len()).unwrap_or(1))).unwrap_or(0);
        values.get(index).copied().unwrap_or(0.0)
    }
}
