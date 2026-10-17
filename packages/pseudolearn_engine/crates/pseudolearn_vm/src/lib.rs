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
pub use machine::{
    ActiveFrameInspection, Cell, Machine, MachineDelta, MachineImage, MachineStateRecord,
    OpcodeProfile, SavedControlFrame, advance_image, clear_machine_events, compose_machine_deltas,
    create_machine, create_owned_machine, machine_cell, machine_change_buffer, machine_defined,
    machine_event_count, machine_events, machine_heap_used_words, machine_output,
    machine_polls_executed, machine_program, machine_reference, machine_remaining_fuel,
    machine_scalar, machine_statements_executed, restore_machine_image, resume_machine,
    revert_image, run, run_loaded, run_profiled, run_with_options, set_machine_output_suppressed,
    set_machine_probed, snapshot_machine, snapshot_machine_lean, suspend_machine,
    take_machine_events,
};
pub use model::MemoryCount;
pub use model::{Fuel, LimitKind, RunExit, RunResult, RuntimeValue, ServiceReason};
pub use options::{RunOptions, TwinMode};
pub use step::{StepAction, advance_step, step_into, step_next, step_out, step_over, step_to_line};
pub use trap::VmTrap;
pub use wire::{decode_plev, encode_plev};

pub(crate) use trap::Fault;
