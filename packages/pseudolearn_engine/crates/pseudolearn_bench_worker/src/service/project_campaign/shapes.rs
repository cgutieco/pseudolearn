use crate::service::help_campaign::documents::{Generator, SEED};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Shape {
    Chain,
    Star,
    Diamond,
    Library,
}

impl Shape {
    pub const ALL: [Shape; 4] = [Shape::Chain, Shape::Star, Shape::Diamond, Shape::Library];

    pub fn name(self) -> &'static str {
        match self {
            Shape::Chain => "chain",
            Shape::Star => "star",
            Shape::Diamond => "diamond",
            Shape::Library => "library",
        }
    }

    pub fn package_of(self, index: usize) -> &'static str {
        if self == Shape::Library && index > 0 {
            "lib"
        } else {
            "app"
        }
    }

    pub fn callees(self, index: usize, count: usize) -> Vec<usize> {
        match (self, index) {
            (Shape::Chain, 0) => vec![1],
            (Shape::Chain, _) if index.saturating_add(1) < count => vec![index.saturating_add(1)],
            (Shape::Star | Shape::Library, 0) => (1..count).collect(),
            (Shape::Diamond, 0) => (2..count).collect(),
            (Shape::Diamond, _) if index >= 2 => vec![1],
            _ => Vec::new(),
        }
    }

    pub fn expected_total(self, constants: &[u64]) -> u64 {
        let count = constants.len();
        let total: u64 = constants.iter().sum();
        match self {
            Shape::Diamond => {
                let bottom = constants.get(1).copied().unwrap_or(0);
                let width = u64::try_from(count.saturating_sub(2)).unwrap_or(0);
                total.saturating_add(bottom.saturating_mul(width.saturating_sub(1)))
            }
            _ => total,
        }
    }
}

pub fn constants(count: usize, salt: u64) -> Vec<u64> {
    let mut generator = Generator::new(SEED.wrapping_add(salt));
    (0..count)
        .map(|_| 1_u64.saturating_add(u64::try_from(generator.below(97)).unwrap_or(0)))
        .collect()
}
