use crate::error::TimelineError;
use crate::views::{StateSnapshot, capture_snapshot};
use pseudolearn_vm::{
    LoadedProgram, Machine, MachineImage, RunExit, RunOptions, machine_event_count, resume_machine,
};

pub fn replay_to_event(
    program: &LoadedProgram,
    image: MachineImage,
    target_event: usize,
    options: &RunOptions,
) -> Result<StateSnapshot, TimelineError> {
    let machine = replay_machine_to_event(program, image, target_event, options)?;
    Ok(capture_snapshot(&machine, target_event))
}

pub(crate) fn replay_machine_to_event<'program>(
    program: &'program LoadedProgram,
    image: MachineImage,
    target_event: usize,
    options: &RunOptions,
) -> Result<Machine<'program>, TimelineError> {
    let target_count = target_event
        .checked_add(1)
        .ok_or(TimelineError::ReplayFailure)?;
    if image.state.event_count > target_count {
        return Err(TimelineError::ReplayFailure);
    }
    let mut machine = resume_machine(program, image, options.clone())
        .map_err(|_| TimelineError::ReplayFailure)?;
    while machine_event_count(&machine) < target_count {
        match machine.step_instruction() {
            None => {}
            Some(RunExit::Service(_)) => return Err(TimelineError::ReplayFailure),
            Some(_) if machine_event_count(&machine) >= target_count => break,
            Some(_) => return Err(TimelineError::ReplayFailure),
        }
    }
    if machine_event_count(&machine) != target_count {
        return Err(TimelineError::ReplayFailure);
    }
    Ok(machine)
}
