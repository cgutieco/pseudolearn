#![forbid(unsafe_code)]

mod dispatch;
mod evaluate;
mod load;
mod machine;
mod model;
mod trap;

pub use load::{LoadedProgram, load};
pub use machine::{OpcodeProfile, run, run_loaded, run_profiled};
pub use model::{Fuel, RunExit, RunResult, RuntimeValue, ServiceReason};
pub use trap::VmTrap;

pub(crate) use trap::Fault;
