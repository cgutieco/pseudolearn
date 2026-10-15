#![forbid(unsafe_code)]

use std::f64::consts::{E, FRAC_PI_2, LN_2, PI};

use crate::math_sampling::Sampler;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MathFunction {
    Exponential,
    Logarithm,
    Sine,
    Cosine,
    Arctangent,
    Power,
}

pub const MATH_FUNCTIONS: [MathFunction; 6] = [
    MathFunction::Exponential,
    MathFunction::Logarithm,
    MathFunction::Sine,
    MathFunction::Cosine,
    MathFunction::Arctangent,
    MathFunction::Power,
];

const TINY: f64 = f64::from_bits(1);
const COMMON_EDGES: [f64; 10] = [
    0.0,
    -0.0,
    TINY,
    -TINY,
    f64::MIN_POSITIVE,
    1.0,
    -1.0,
    0.5,
    f64::MAX,
    -f64::MAX,
];

impl MathFunction {
    pub fn name(self) -> &'static str {
        match self {
            Self::Exponential => "exp",
            Self::Logarithm => "ln",
            Self::Sine => "sin",
            Self::Cosine => "cos",
            Self::Arctangent => "atan",
            Self::Power => "pow",
        }
    }

    pub fn arity(self) -> usize {
        if self == Self::Power { 2 } else { 1 }
    }
}

pub fn arguments(function: MathFunction, count: usize, seed: u64) -> Vec<Vec<f64>> {
    let mut sampler = Sampler::new(seed ^ function_salt(function));
    (0..count)
        .map(|_| match function {
            MathFunction::Exponential => vec![exponential_argument(&mut sampler)],
            MathFunction::Logarithm => vec![logarithm_argument(&mut sampler)],
            MathFunction::Sine | MathFunction::Cosine => vec![trigonometric_argument(&mut sampler)],
            MathFunction::Arctangent => vec![arctangent_argument(&mut sampler)],
            MathFunction::Power => crate::math_power_arguments::power_arguments(&mut sampler),
        })
        .collect()
}

fn function_salt(function: MathFunction) -> u64 {
    function
        .name()
        .bytes()
        .fold(0xCBF2_9CE4_8422_2325, |hash, byte| {
            (hash ^ u64::from(byte)).wrapping_mul(0x100_0000_01B3)
        })
}

fn edge(sampler: &mut Sampler, specific: &[f64]) -> f64 {
    if sampler.next_word() & 1 == 0 {
        sampler.pick(&COMMON_EDGES)
    } else {
        sampler.pick(specific)
    }
}

fn exponential_argument(sampler: &mut Sampler) -> f64 {
    let specific = [
        LN_2,
        709.782_712_893_384,
        709.782_712_893_384_1,
        -745.133_219_101_941_1,
        -745.133_219_101_941_2,
        -708.396_418_532_264_1,
        1.0 / 1_152_921_504_606_846_976.0,
        2.0e-19,
    ];
    match sampler.below(100) {
        0..50 => sampler.uniform(-746.0, 710.0),
        50..85 => sampler.logarithmic(-70, 9),
        85..95 => sampler.finite_bits(),
        _ => edge(sampler, &specific),
    }
}

fn logarithm_argument(sampler: &mut Sampler) -> f64 {
    let specific = [
        2.0,
        E,
        10.0,
        0.1,
        1.0 - 1.0 / 9_007_199_254_740_992.0,
        1.0 + f64::EPSILON,
    ];
    match sampler.below(100) {
        0..45 => sampler.finite_bits().abs(),
        45..70 => sampler.near(1.0, 1 << 20),
        70..90 => sampler.logarithmic(-1022, 1023).abs(),
        _ => edge(sampler, &specific).abs(),
    }
}

fn trigonometric_argument(sampler: &mut Sampler) -> f64 {
    let specific = [
        PI,
        FRAC_PI_2,
        1.0e22,
        1_073_741_824.0,
        1.0 / 1_073_741_824.0,
        1.0 / 2_147_483_648.0,
        355.0,
        6.0e17,
    ];
    match sampler.below(100) {
        0..5 => sampler.finite_bits(),
        5..65 => sampler.logarithmic(-35, 31),
        65..80 => {
            let turns = f64::from(u32::try_from(sampler.below(1 << 20)).unwrap_or(1));
            sampler.near(turns * FRAC_PI_2, 4)
        }
        80..90 => sampler.uniform(-1.0e6, 1.0e6),
        _ => edge(sampler, &specific),
    }
}

fn arctangent_argument(sampler: &mut Sampler) -> f64 {
    let specific = [1.0e300, -1.0e300, 1.0 / 1_073_741_824.0, 2.0, 1.0e16];
    match sampler.below(100) {
        0..20 => sampler.finite_bits(),
        20..80 => sampler.logarithmic(-35, 70),
        80..90 => sampler.near(1.0, 1 << 16),
        _ => edge(sampler, &specific),
    }
}
