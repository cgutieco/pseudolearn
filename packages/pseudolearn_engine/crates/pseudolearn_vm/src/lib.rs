#![forbid(unsafe_code)]

mod dispatch;
mod evaluate;
mod load;
mod machine;
mod model;
mod options;
mod trap;

pub use load::{LoadedProgram, load};
pub use machine::run_with_options;
pub use machine::{OpcodeProfile, run, run_loaded, run_profiled};
pub use model::MemoryCount;
pub use model::{Fuel, RunExit, RunResult, RuntimeValue, ServiceReason};
pub use options::RunOptions;
pub use trap::VmTrap;

pub(crate) use trap::Fault;
