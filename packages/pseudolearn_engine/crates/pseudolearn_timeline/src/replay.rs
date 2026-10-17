use crate::error::TimelineError;
use crate::views::{StateSnapshot, capture_snapshot};
use pseudolearn_vm::{
    LoadedProgram, Machine, MachineImage, RunOptions, machine_event_count, resume_machine,
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

pub fn replay_machine_to_event<'program>(
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
    machine.replace_input_tape(options.inputs.clone());
    while machine_event_count(&machine) < target_count {
        let exit = machine.step_instruction();
        let reached_target = machine_event_count(&machine) >= target_count;
        pseudolearn_vm::clear_machine_events(&mut machine);
        if reached_target {
            break;
        }
        if exit.is_some() {
            return Err(TimelineError::ReplayFailure);
        }
    }
    if machine_event_count(&machine) != target_count {
        return Err(TimelineError::ReplayFailure);
    }
    Ok(machine)
}
