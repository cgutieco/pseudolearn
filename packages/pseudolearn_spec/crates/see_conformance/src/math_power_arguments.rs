#![forbid(unsafe_code)]

use crate::math_sampling::Sampler;

const EDGE_PAIRS: [(f64, f64); 16] = [
    (0.0, 3.0),
    (-0.0, 3.0),
    (-0.0, 2.0),
    (0.0, -1.0),
    (2.0, -1074.0),
    (2.0, -1075.0),
    (2.0, 1023.0),
    (2.0, 1024.0),
    (7.0, 0.0),
    (1.0, 1.0e300),
    (-1.0, 1_152_921_504_606_846_976.0),
    (10.0, 308.0),
    (10.0, -324.0),
    (-2.0, 0.5),
    (9.0, 1.5),
    (3.0, 34.0),
];

pub fn power_arguments(sampler: &mut Sampler) -> Vec<f64> {
    let (base, exponent) = match sampler.below(100) {
        0..40 => (
            sampler.logarithmic(-10, 10).abs(),
            sampler.uniform(-60.0, 60.0),
        ),
        40..55 => (
            sampler.logarithmic(-10, 10).abs(),
            small_integer(sampler, 40),
        ),
        55..65 => (
            -sampler.logarithmic(-5, 5).abs(),
            small_integer(sampler, 30),
        ),
        65..75 => perfect_power(sampler),
        75..85 => (sampler.near(1.0, 1 << 12), sampler.logarithmic(10, 60)),
        85..90 => (sampler.finite_bits(), sampler.finite_bits()),
        _ => {
            let index = usize::try_from(sampler.below(16)).unwrap_or(0);
            EDGE_PAIRS.get(index).copied().unwrap_or((2.0, 2.0))
        }
    };
    vec![base, exponent]
}

fn small_integer(sampler: &mut Sampler, limit: u64) -> f64 {
    let magnitude = f64::from(u32::try_from(sampler.below(limit.saturating_add(1))).unwrap_or(0));
    if sampler.next_word() & 1 == 0 {
        magnitude
    } else {
        -magnitude
    }
}

fn perfect_power(sampler: &mut Sampler) -> (f64, f64) {
    let root = f64::from(
        u32::try_from(sampler.below(1 << 20))
            .unwrap_or(1)
            .saturating_add(2),
    );
    let numerator = f64::from(
        u32::try_from(sampler.below(40))
            .unwrap_or(0)
            .saturating_mul(2)
            .saturating_add(1),
    );
    if sampler.next_word() & 1 == 0 {
        (root * root, numerator / 2.0)
    } else {
        (root * root * root * root, numerator / 4.0)
    }
}
