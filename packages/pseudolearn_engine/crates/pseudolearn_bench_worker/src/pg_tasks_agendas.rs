use crate::pg_tasks_families;
use serde_json::Value;

pub const FAMILY_COUNT: u64 = 8;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Expected {
    pub output: String,
    pub termination: &'static str,
}

#[derive(Clone, Debug)]
pub struct Agenda {
    pub seed: u64,
    pub family: u64,
    pub program: String,
    pub host: Option<Value>,
    pub gc_stress: bool,
    pub expected: Expected,
}

pub struct SplitMix64(u64);

impl SplitMix64 {
    pub fn new(seed: u64) -> Self {
        Self(seed)
    }

    pub fn advance(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let first = (self.0 ^ (self.0 >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        let second = (first ^ (first >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        second ^ (second >> 31)
    }

    pub fn below(&mut self, bound: u64) -> u64 {
        self.advance().checked_rem(bound).unwrap_or(0)
    }

    pub fn between(&mut self, first: u64, last: u64) -> u64 {
        let width = last.saturating_sub(first).saturating_add(1);
        first.saturating_add(self.below(width))
    }

    pub fn shuffled(&mut self, count: u64) -> Vec<u64> {
        let mut order: Vec<u64> = (1..=count).collect();
        let mut remaining = order.len();
        while remaining > 1 {
            let bound = u64::try_from(remaining).unwrap_or(1);
            let picked = usize::try_from(self.below(bound)).unwrap_or(0);
            remaining = remaining.saturating_sub(1);
            order.swap(picked, remaining);
        }
        order
    }
}

pub fn generate(seed: u64) -> Agenda {
    let family = seed.checked_rem(FAMILY_COUNT).unwrap_or(0);
    let mut random = SplitMix64::new(seed);
    pg_tasks_families::build(seed, family, &mut random)
}
