use pseudolearn_vm::{
    Fuel, LoadedProgram, RunExit, RunOptions, create_machine, machine_events,
    set_machine_output_suppressed, set_machine_probed,
};

use crate::checkpoint::{Checkpoint, restore_checkpoint};
use crate::error::TimelineError;
use crate::views::{StateSnapshot, capture_snapshot};

pub fn replay_to_event(
    program: &LoadedProgram,
    checkpoint: &Checkpoint,
    target_event: usize,
    base_options: &RunOptions,
) -> Result<StateSnapshot, TimelineError> {
    let mut replay_options = base_options.clone();
    replay_options.twin_mode = pseudolearn_vm::TwinMode::Probed;
    let mut replay_machine = create_machine(program, Fuel::unlimited(), replay_options)
        .map_err(|_| TimelineError::ReplayFailure)?;
    restore_checkpoint(&mut replay_machine, checkpoint)
        .map_err(|_| TimelineError::ReplayFailure)?;
    set_machine_output_suppressed(&mut replay_machine, true);
    set_machine_probed(&mut replay_machine, true);

    while machine_events(&replay_machine).len() < target_event {
        let exit_outcome = replay_machine.step_instruction();
        if let Some(RunExit::Completed(_) | RunExit::Cancelled | RunExit::Trap(_)) = exit_outcome {
            break;
        }
    }

    Ok(capture_snapshot(&replay_machine, target_event))
}
