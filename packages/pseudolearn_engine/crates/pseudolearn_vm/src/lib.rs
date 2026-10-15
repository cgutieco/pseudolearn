#![forbid(unsafe_code)]

include!(concat!(env!("OUT_DIR"), "/generated_dispatch.rs"));

mod frame;
mod machine;
mod model;
mod trap;

#[cfg(test)]
mod frame_tests;

pub use machine::{OpcodeProfile, run, run_profiled};
pub use model::{Fuel, RunExit, RunResult, RuntimeValue, ServiceReason};
pub use trap::VmTrap;
