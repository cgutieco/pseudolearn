#![forbid(unsafe_code)]

mod dispatch;
mod evaluate;
mod events;
mod load;
mod machine;
mod model;
mod options;
mod step;
mod trap;
mod wire;

pub use events::{ChangeBuffer, EventPayload, TraceClass, TraceEvent};
pub use load::{LoadedProgram, load};
pub use machine::run_with_options;
pub use machine::{OpcodeProfile, run, run_loaded, run_profiled};
pub use model::MemoryCount;
pub use model::{Fuel, LimitKind, RunExit, RunResult, RuntimeValue, ServiceReason};
pub use options::{RunOptions, TwinMode};
pub use step::{StepAction, advance_step, step_into, step_next, step_out, step_over, step_to_line};
pub use trap::VmTrap;
pub use wire::{decode_plev, encode_plev};

pub(crate) use trap::Fault;
