#![forbid(unsafe_code)]

mod conversion;
mod error;
mod math;
mod rounding;

pub use conversion::{integer_to_real, real_to_integer};
pub use error::LibraryError;
pub use math::{absolute, square_root};
pub use rounding::{round_real, truncate_real};
