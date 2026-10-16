use super::{Machine, MachineStateRecord};
use crate::{ChangeBuffer, Fuel, LoadedProgram, RunOptions, TraceEvent, VmTrap};
use pseudolearn_runtime::{Handle, Heap};

#[derive(Clone, Debug, PartialEq)]
pub struct MachineImage {
    pub state: MachineStateRecord,
    heap: Heap,
    remaining: Fuel,
    output: String,
    literals: Vec<Handle>,
    inputs: Vec<String>,
    diagnostics: Vec<VmTrap>,
    events: Vec<TraceEvent>,
    changes: ChangeBuffer,
    probed: bool,
    input_requested: bool,
    output_suppressed: bool,
}

pub fn snapshot_machine(machine: &Machine<'_>) -> MachineImage {
    MachineImage {
        state: capture_full_banks(machine),
        heap: machine.heap.clone(),
        remaining: machine.remaining,
        output: machine.output.clone(),
        literals: machine.literals.clone(),
        inputs: machine.inputs.clone(),
        diagnostics: machine.diagnostics.clone(),
        events: machine.events.clone(),
        changes: machine.change_buffer.clone(),
        probed: machine.probed,
        input_requested: machine.input_requested_emitted,
        output_suppressed: machine.output_suppressed,
    }
}

pub fn suspend_machine(machine: Machine<'_>) -> MachineImage {
    let state = capture_full_banks(&machine);
    MachineImage {
        state,
        heap: machine.heap,
        remaining: machine.remaining,
        output: machine.output,
        literals: machine.literals,
        inputs: machine.inputs,
        diagnostics: machine.diagnostics,
        events: machine.events,
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
    let current = program
        .functions
        .get(image.state.current_function_index)
        .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
    let mut machine = Machine::new_instance(program, current, image.remaining, options);
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

fn capture_full_banks(machine: &Machine<'_>) -> MachineStateRecord {
    let mut state = machine.capture_machine_state();
    state.scalars.clone_from(&machine.scalars);
    state.references.clone_from(&machine.references);
    state.defined.clone_from(&machine.defined);
    state
}
