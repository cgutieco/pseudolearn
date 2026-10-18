const TWO_POW_32: f64 = 4_294_967_296.0;

pub fn count_to_float(count: usize) -> f64 {
    let value = u64::try_from(count).unwrap_or(u64::MAX);
    let high = u32::try_from(value >> 32).unwrap_or(u32::MAX);
    let low = u32::try_from(value & 0xffff_ffff).unwrap_or(u32::MAX);
    f64::from(high) * TWO_POW_32 + f64::from(low)
}

pub fn mean(values: &[f64]) -> f64 {
    if values.is_empty() {
        return f64::NAN;
    }
    values.iter().sum::<f64>() / count_to_float(values.len())
}

pub fn geometric_mean(values: &[f64]) -> f64 {
    if values.is_empty() || values.iter().any(|value| *value <= 0.0) {
        return f64::NAN;
    }
    let total: f64 = values.iter().map(|value| value.ln()).sum();
    (total / count_to_float(values.len())).exp()
}

pub fn percentile(values: &[f64], fraction: f64) -> f64 {
    if values.is_empty() {
        return f64::NAN;
    }
    let mut sorted = values.to_vec();
    sorted.sort_by(f64::total_cmp);
    let rank = (count_to_float(sorted.len()) * fraction).ceil().max(1.0);
    let position = (0..sorted.len())
        .find(|candidate| count_to_float(candidate.saturating_add(1)) >= rank)
        .unwrap_or(sorted.len().saturating_sub(1));
    sorted.get(position).copied().unwrap_or(f64::NAN)
}

pub fn median(values: &[f64]) -> f64 {
    percentile(values, 0.5)
}

pub struct Sampler {
    state: u64,
}

impl Sampler {
    pub fn seeded(seed: u64) -> Self {
        Self { state: seed }
    }

    fn next_word(&mut self) -> u64 {
        self.state = self.state.wrapping_add(0x9e37_79b9_7f4a_7c15);
        let mut mixed = self.state;
        mixed = (mixed ^ (mixed >> 30)).wrapping_mul(0xbf58_476d_1ce4_e5b9);
        mixed = (mixed ^ (mixed >> 27)).wrapping_mul(0x94d0_49bb_1331_11eb);
        mixed ^ (mixed >> 31)
    }

    pub fn resample(&mut self, values: &[f64]) -> Vec<f64> {
        let bound = u64::try_from(values.len()).unwrap_or(u64::MAX).max(1);
        values
            .iter()
            .map(|_| {
                let position =
                    usize::try_from(self.next_word().checked_rem(bound).unwrap_or(0)).unwrap_or(0);
                values.get(position).copied().unwrap_or(f64::NAN)
            })
            .collect()
    }
}
