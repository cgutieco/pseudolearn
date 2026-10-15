#![forbid(unsafe_code)]

mod conversion;
mod error;
mod math;
mod precision;
mod rounding;
mod transcendental;

pub use conversion::{integer_to_real, real_to_integer};
pub use error::LibraryError;
pub use math::{absolute, square_root};
pub use rounding::{round_real, truncate_real};
pub use transcendental::{arctangent, cosine, exponential, natural_logarithm, real_power, sine};
