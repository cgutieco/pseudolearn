#![forbid(unsafe_code)]

mod arctangent;
mod binary64;
mod constants;
mod exponential;
mod logarithm;
mod power;
mod power_exact;
mod series;
mod trigonometric;
mod ziv;

#[cfg(test)]
mod binary64_tests;
#[cfg(test)]
mod power_exact_tests;

pub use arctangent::arctangent;
pub use exponential::exponential;
pub use logarithm::natural_logarithm;
pub use power::real_power;
pub use trigonometric::{cosine, sine};
