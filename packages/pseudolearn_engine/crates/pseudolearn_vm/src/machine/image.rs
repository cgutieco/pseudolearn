use super::{Machine, MachineStateRecord};
use crate::{ChangeBuffer, Fuel, LoadedProgram, RunOptions, TraceEvent, VmTrap};
use pseudolearn_runtime::{Handle, Heap};

#[derive(Clone, Debug, PartialEq)]
pub struct MachineImage {
    pub state: MachineStateRecord,
    pub(super) heap: Heap,
    pub(super) remaining: Fuel,
    pub(super) output: String,
    pub(super) literals: Vec<Handle>,
    pub(super) inputs: Vec<String>,
    pub(super) diagnostics: Vec<VmTrap>,
    pub(super) events: Vec<TraceEvent>,
    pub(super) events_dropped: usize,
    pub(super) changes: ChangeBuffer,
    pub(super) probed: bool,
    pub(super) input_requested: bool,
    pub(super) output_suppressed: bool,
}

pub fn snapshot_machine(machine: &Machine<'_>) -> MachineImage {
    let image = MachineImage {
        state: machine.capture_machine_state(),
        heap: machine.heap.clone(),
        remaining: machine.remaining,
        output: machine.output.clone(),
        literals: machine.literals.clone(),
        inputs: machine.inputs.clone(),
        diagnostics: machine.diagnostics.clone(),
        events: machine.events.clone(),
        events_dropped: machine.events_dropped,
        changes: machine.change_buffer.clone(),
        probed: machine.probed,
        input_requested: machine.input_requested_emitted,
        output_suppressed: machine.output_suppressed,
    };
    machine.frame_dirty_from.set(machine.frames.len());
    machine.begin_bank_delta_tracking();
    image
}

pub fn snapshot_machine_lean(machine: &Machine<'_>) -> MachineImage {
    let mut state = machine.capture_machine_state();
    state.scalars.truncate(state.scalar_limit);
    state.scalars.shrink_to_fit();
    state.defined.truncate(state.scalar_limit);
    state.defined.shrink_to_fit();
    state.references.truncate(state.reference_limit);
    state.references.shrink_to_fit();
    let mut heap = machine.heap.clone();
    heap.shrink_to_fit();
    let image = MachineImage {
        events_dropped: state.event_count,
        events: Vec::new(),
        state,
        heap,
        remaining: machine.remaining,
        output: machine.output.clone(),
        literals: machine.literals.clone(),
        inputs: machine.inputs.clone(),
        diagnostics: machine.diagnostics.clone(),
        changes: machine.change_buffer.clone(),
        probed: machine.probed,
        input_requested: machine.input_requested_emitted,
        output_suppressed: machine.output_suppressed,
    };
    machine.frame_dirty_from.set(machine.frames.len());
    machine.begin_bank_delta_tracking();
    image
}

pub fn suspend_machine(machine: Machine<'_>) -> MachineImage {
    let mut state = machine.capture_control_record();
    state.frames = super::inspection::capture_saved_frames(&machine);
    state.cells = machine.cells;
    state.scalars = machine.scalars;
    state.references = machine.references;
    state.defined = machine.defined;
    MachineImage {
        state,
        heap: machine.heap,
        remaining: machine.remaining,
        output: machine.output,
        literals: machine.literals,
        inputs: machine.inputs,
        diagnostics: machine.diagnostics,
        events: machine.events,
        events_dropped: machine.events_dropped,
        changes: machine.change_buffer,
        probed: machine.probed,
        input_requested: machine.input_requested_emitted,
        output_suppressed: machine.output_suppressed,
    }
}

pub fn resume_machine<'program>(
    program: &'program LoadedProgram,
    image: MachineImage,
    options: RunOptions,
) -> Result<Machine<'program>, VmTrap> {
    let current_function_index = image.state.current_function_index;
    let current = program
        .inner
        .functions
        .get(current_function_index)
        .cloned()
        .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
    let mut machine = Machine::new_instance(super::initialization::MachineInitialization {
        program: program.clone(),
        current,
        current_function_index,
        fuel: image.remaining,
        options,
    });
    machine.restore_machine_state(&image.state);
    restore_payload(&mut machine, image);
    Ok(machine)
}

fn restore_payload(machine: &mut Machine<'_>, image: MachineImage) {
    machine.heap = image.heap;
    machine.output = image.output;
    machine.literals = image.literals;
    machine.inputs = image.inputs;
    machine.diagnostics = image.diagnostics;
    machine.events = image.events;
    machine.events_dropped = image.events_dropped;
    machine.change_buffer = image.changes;
    machine.probed = image.probed;
    machine.input_requested_emitted = image.input_requested;
    machine.output_suppressed = image.output_suppressed;
}

pub fn restore_machine_image(machine: &mut Machine<'_>, image: &MachineImage) {
    machine.restore_machine_state(&image.state);
    machine.remaining = image.remaining;
    restore_payload(machine, image.clone());
}
