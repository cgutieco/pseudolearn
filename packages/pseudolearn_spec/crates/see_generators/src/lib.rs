#![forbid(unsafe_code)]

pub mod program;
mod random;

pub use program::{GeneratedProgram, GenerationSeed, generate};
