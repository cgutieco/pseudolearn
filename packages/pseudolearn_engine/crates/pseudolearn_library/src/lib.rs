#![forbid(unsafe_code)]

mod conversion;
mod decimal;
mod error;
mod format;
mod math;
mod precision;
mod rounding;
mod transcendental;

pub use conversion::{integer_to_real, real_to_integer};
pub use decimal::{DecimalError, parse_integer, parse_real};
pub use error::LibraryError;
pub use format::{BooleanLexemes, PrimitiveValue, format_value};
pub use math::{absolute, square_root};
pub use rounding::{round_real, truncate_real};
pub use transcendental::{arctangent, cosine, exponential, natural_logarithm, real_power, sine};
