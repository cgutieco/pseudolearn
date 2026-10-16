use crate::events::TraceEvent;
use crate::load::LoadedProgram;
use crate::machine::Machine;
use crate::machine::cells::Cell;
use crate::{Fuel, RunOptions, VmTrap};

pub fn machine_program<'program>(machine: &Machine<'program>) -> &'program LoadedProgram {
    machine.program
}

pub fn machine_events<'machine>(machine: &'machine Machine<'_>) -> &'machine [TraceEvent] {
    &machine.events
}

pub fn take_machine_events(machine: &mut Machine<'_>) -> Vec<TraceEvent> {
    std::mem::take(&mut machine.events)
}

pub fn machine_output<'machine>(machine: &'machine Machine<'_>) -> &'machine str {
    &machine.output
}

pub fn machine_statements_executed(machine: &Machine) -> u64 {
    machine.statements_executed
}

pub fn machine_polls_executed(machine: &Machine) -> u64 {
    machine.polls_executed
}

pub fn machine_scalar(machine: &Machine, slot: usize) -> Option<u64> {
    machine.scalars.get(slot).copied()
}

pub fn machine_reference(machine: &Machine, slot: usize) -> Option<u32> {
    machine.references.get(slot).copied()
}

pub fn machine_defined(machine: &Machine, slot: usize) -> Option<bool> {
    machine.defined.get(slot).copied()
}

pub fn machine_cell(machine: &Machine, cell_index: usize) -> Option<Cell> {
    machine.cells.get(cell_index).copied()
}

pub fn set_machine_probed(machine: &mut Machine, probed: bool) {
    machine.probed = probed;
}

pub fn set_machine_output_suppressed(machine: &mut Machine, suppressed: bool) {
    machine.output_suppressed = suppressed;
}

pub fn create_machine<'program>(
    program: &'program LoadedProgram,
    fuel: Fuel,
    options: RunOptions,
) -> Result<Machine<'program>, VmTrap> {
    Machine::start(program, fuel, options)
}

impl Machine<'_> {
    pub fn replace_input_tape(&mut self, inputs: Vec<String>) {
        self.inputs = inputs;
    }
    pub fn input_consumed_count(&self) -> usize {
        self.input_index
    }
    pub fn execution_diagnostics(&self) -> &[VmTrap] {
        &self.diagnostics
    }
    pub fn supply_input(&mut self, text: String) {
        self.inputs.push(text);
    }
}
