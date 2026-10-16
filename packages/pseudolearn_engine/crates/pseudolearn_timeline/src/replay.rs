use crate::checkpoint::Checkpoint;
use crate::error::TimelineError;
use crate::views::{StateSnapshot, capture_snapshot};
use pseudolearn_vm::{LoadedProgram, Machine, RunExit, RunOptions, machine_events, resume_machine};

pub fn replay_to_event(
    program: &LoadedProgram,
    checkpoint: &Checkpoint,
    target_event: usize,
    options: &RunOptions,
) -> Result<StateSnapshot, TimelineError> {
    let machine = replay_machine_to_event(program, checkpoint, target_event, options)?;
    Ok(capture_snapshot(&machine, target_event))
}

pub(crate) fn replay_machine_to_event<'program>(
    program: &'program LoadedProgram,
    checkpoint: &Checkpoint,
    target_event: usize,
    options: &RunOptions,
) -> Result<Machine<'program>, TimelineError> {
    if target_event < checkpoint.event_index {
        return Err(TimelineError::ReplayFailure);
    }
    let mut machine = resume_machine(program, checkpoint.image.clone(), options.clone())
        .map_err(|_| TimelineError::ReplayFailure)?;
    let target_count = target_event
        .checked_add(1)
        .ok_or(TimelineError::ReplayFailure)?;
    while machine_events(&machine).len() < target_count {
        match machine.step_instruction() {
            None => {}
            Some(RunExit::Service(_)) => return Err(TimelineError::ReplayFailure),
            Some(_) if machine_events(&machine).len() >= target_count => break,
            Some(_) => return Err(TimelineError::ReplayFailure),
        }
    }
    if machine_events(&machine).len() != target_count {
        return Err(TimelineError::ReplayFailure);
    }
    Ok(machine)
}
